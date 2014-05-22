//
//  PYConnection.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

NSString const *kUnsyncEventsEventKey       = @"pryv.unsyncevents.Event";
NSString const *kUnsyncEventsRequestKey     = @"pryv.unsyncevents.Request";
//NSString const *kUnsyncEventsRequestTypeKey = @"pryv.unsyncevents.RequestType";

#import "PYConstants.h"
#import "PYConnection.h"
#import "PYStream+JSON.h"
#import "PYEvent.h"
#import "PYEvent+Sync.h"
#import "PYAttachment.h"
#import "PYConnection+DataManagement.h"
#import "PYConnection+FetchedStreams.h"
#import "PYCachingController.h"
#import "PYReachability.h"
#import "PYCachingController+Event.h"
#import "PYCachingController+Stream.h"
#import "PYUtils.h"

@interface PYConnection ()

@property (nonatomic, readwrite) NSTimeInterval serverTimeInterval;


@end

@implementation PYConnection

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize apiDomain = _apiDomain;
@synthesize apiScheme = _apiScheme;
@synthesize apiPort = _apiPort;
@synthesize apiExtraPath = _apiExtraPath;
@synthesize serverTimeInterval = _serverTimeInterval;
@synthesize connectionReachability = _connectionReachability;
@synthesize streamsNotSync = _streamsNotSync;
@synthesize attachmentsCountNotSync = _attachmentsCountNotSync;
@synthesize attachmentSizeNotSync = _attachmentSizeNotSync;
@synthesize lastTimeServerContact = _lastTimeServerContact;
@synthesize cache = _cache;
@synthesize fetchedStreamsMap = _fetchedStreamsMap;
@synthesize fetchedStreamsRoots = _fetchedStreamsRoots;


- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.userID = username;
        self.accessToken = token;
        self.apiDomain = [PYClient defaultDomain];
        self.apiScheme = kPYAPIScheme;
        self.apiExtraPath = @"";
        self.apiPort = 443;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
        self.connectionReachability = [PYReachability reachabilityForInternetConnection];
        [self.connectionReachability startNotifier];
        self.cache = [[[PYCachingController alloc] initWithCachingId:self.idCaching] autorelease];
        [self pyAccessStatus:self.connectionReachability];
        [self setupDeserializeNonSyncList];
    }
    return self;
}

- (void)dealloc
{
    [_userID release];
    _userID = nil;
    [_accessToken release];
    _accessToken = nil;
    [_apiDomain release];
    _apiDomain = nil;
    [_apiScheme release];
    _apiScheme = nil;
    [_connectionReachability release];
    _connectionReachability = nil;
    [_streamsNotSync release];
    _streamsNotSync = nil;
    [_cache release];
    _cache = nil;
    [_apiExtraPath release];
    _apiExtraPath = nil;
    [_fetchedStreamsMap release];
    _fetchedStreamsMap = nil;
    [_fetchedStreamsRoots release];
    _fetchedStreamsRoots = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (BOOL)isOnline
{
    return _online;
}

#pragma mark streams

/**
 Be sure that some structure of the stream as been fetched
 */
-(void) streamsEnsureFetched:(void(^)(NSError *error))done {
    if (_fetchedStreamsMap) {
        return done(nil);
    }
    //Return current cached streams
    NSArray *allStreamsFromCache = [self streamsFromCache];
    if (allStreamsFromCache.count > 0) {
        self.fetchedStreamsRoots = allStreamsFromCache;
        [self updateFetchedStreamsMap];
    }
    [self streamsOnlineWithFilterParams:nil successHandler:^(NSArray *streamsList) {
        done(nil);
    } errorHandler:^(NSError *error) {
        done(error);
    }];
}



- (void)addStream:(PYStream *)stream toUnsyncList:(NSError *)error
{
    /*When we deserialize unsync list (when app starts) we will know what streams are not sync with these informations:
     They have one of these flags or combination of them
     notSyncAdd
     notSyncModify
     */
    [self.streamsNotSync addObject:stream];
    
}

#pragma mark streams

- (NSArray*)allEventsFromCache
{
    NSArray *allEventsFromCache = [self.cache eventsFromCache];
    // set connection property on events
    [allEventsFromCache makeObjectsPerformSelector:@selector(setConnection:) withObject:self];
    return allEventsFromCache;
}

- (NSArray*)eventsNotSync
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    PYEvent* event;
    for (event in [self allEventsFromCache]) {
        if ([event toBeSyncSkipCacheTest]) {
            [result addObject:event];
        }
    }
    return [result autorelease];
}


/**
 * Load event form cache.. Part of this init
 */
- (void)setupDeserializeNonSyncList
{
    

    NSArray *nonSyncStreamsArray = [self.cache allStreamsFromCache];
    
    for (PYStream *stream in nonSyncStreamsArray) {
        if (stream.notSyncAdd || stream.notSyncModify) {
            [self.streamsNotSync addObject:stream];
        }
    }
    
    
}



- (NSMutableSet *)streamsNotSync
{
    if (!_streamsNotSync) {
        _streamsNotSync = [[NSMutableSet alloc] init];
    }
    
    return _streamsNotSync;
}

- (void)syncNotSynchedStreamsIfAny
{
    NSMutableArray *nonSyncStreams = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncStreams addObjectsFromArray:[self.streamsNotSync allObjects]];
    for (PYStream *stream in nonSyncStreams) {
        
        //the condition is not correct : set self.Id to shut error up, should be parentId
        //        if ([stream.parentId compare:self.Id] == NSOrderedSame) {
        
        
        //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
        stream.isSyncTriedNow = YES;
        
        if (stream.hasTmpId) {
            if (stream.notSyncModify) {
                NSLog(@"stream has tmpId and it's mofified -> do nothing. If stream doesn't have server id it needs to be added to server and that is all what is matter. Modified object will update PYStream object in cache and in unsyncList");
                
            }
            NSLog(@"stream has tmpId and it's added");
            if (stream.notSyncAdd) {
                NSString *tempId = [NSString stringWithString:stream.streamId];
                stream.streamId = @"";
                [self streamCreate:stream
                    successHandler:^(NSString *createdStreamId) {
                        //If succedded remove from unsyncSet and add call syncStreamWithServer
                        //In that method we were search for stream with <createdStreamId> and we should done mapping between server and temp id in cache
                        stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                        stream.streamId = [NSString stringWithString:tempId];
                        
                        
                        
                        
                        [self.streamsNotSync removeObject:stream];
                        //We have success here. Stream is cached in streamCreate:withRequestType: method, remove old stream with tmpId from cache
                        //He will always have tmpId here but just in case for testing (defensive programing)
                        
                    } errorHandler:^(NSError *error) {
                        stream.isSyncTriedNow = NO;
                        NSLog(@"SYNC error: creating stream failed.");
                        NSLog(@"%@",error);
                    }];
            }
            
        }else{
            NSLog(@"In this case stream has server id");
            
            if (stream.notSyncModify) {
                NSLog(@"for modifified unsync streams with serverId we have to provide only modified values, not full event object");
                
                NSDictionary *modifiedPropertiesDic = stream.modifiedStreamPropertiesAndValues;
                PYStream *modifiedStream = [[PYStream alloc] init];
                modifiedStream.isSyncTriedNow = YES;
                
                [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                    [modifiedStream setValue:value forKey:property];
                }];
                
                [self streamSaveModifiedAttributeFor:modifiedStream forStreamId:stream.streamId successHandler:^{
                    
                    //We have success here. Stream is cached in streamSaveModifiedAttributeFor:forStreamId method
                    stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                    [self.streamsNotSync removeObject:stream];
                    
                } errorHandler:^(NSError *error) {
                    modifiedStream.isSyncTriedNow = NO;
                    stream.isSyncTriedNow = NO;
                }];
            }
        }
    }
    // }
}


  // to be batched
- (void)syncNotSynchedEventsIfAny:(void(^)(int successCount, int overEventCount))done
{
    

    NSArray* eventNotSync = self.eventsNotSync;
    
   int eventCounter = (int)eventNotSync.count;
   __block int successCounter = 0;
 
    
    dispatch_group_t group = dispatch_group_create();
    
    for (PYEvent *event in eventNotSync) {
        dispatch_group_enter(group);
        //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
        event.isSyncTriedNow = YES;
        
        if ([event toBeDeleteOnSync]) {
            [self eventTrashOrDelete:event
                      successHandler:^{
                          event.isSyncTriedNow = NO;
                          successCounter++;
                          dispatch_group_leave(group);
                      } errorHandler:^(NSError *error) {
                          event.isSyncTriedNow = NO;
                          dispatch_group_leave(group);
                      }];
        } else if (event.hasTmpId) { // create
            
            [self eventCreate:event
               successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdEvent) {
                   event.isSyncTriedNow = NO;
                   successCounter++;
                   dispatch_group_leave(group);
               } errorHandler:^(NSError *error) {
                   //reset flag if fail, very IMPORTANT
                   event.isSyncTriedNow = NO;
                   NSLog(@"SYNC error: creating event failed");
                   NSLog(@"%@",error);
                   dispatch_group_leave(group);
               }];
        } else { // update
            NSLog(@"In this case event has server id");
            [self eventSaveModifications:event
                successHandler:^(NSString *stoppedId) {
                    event.isSyncTriedNow = NO;
                    successCounter++;
                    dispatch_group_leave(group);
                } errorHandler:^(NSError *error) {
                    event.isSyncTriedNow = NO;
                    dispatch_group_leave(group);
                }];
        }
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (done) {
            done(successCounter, eventCounter);
        }
    });
    dispatch_release(group);
}


#pragma mark - Reachability

//Called by Reachability whenever status changes.

- (void)reachabilityChanged:(NSNotification *)notif
{
	PYReachability* curReach = [notif object];
	NSParameterAssert([curReach isKindOfClass:[PYReachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        //No internet
        NSLog(@"No internet");
        _online = NO;
    }else{
        //HAVE Internet
        NSLog(@"HAVE internet");
        _online = YES;
        //[self syncNotSynchedStreamsIfAny];
        [self syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
            NSLog(@"synched %i events", successCount);
        }];
    }
}

- (void)pyAccessStatus:(PYReachability *)currReach
{
    if (currReach == self.connectionReachability) {
        if (currReach.currentReachabilityStatus == NotReachable) {
            NSLog(@"No internet, cannot create access");
            _online = NO;
        }else{
            NSLog(@"HAVE internet access created");
            _online = YES;
        }
    }
}

- (NSUInteger)attachmentsCountNotSync
{
    NSUInteger attCount = 0;
    for (NSDictionary *eventDic in self.eventsNotSync) {
        PYEvent *event = [eventDic objectForKey:kUnsyncEventsEventKey];
        if (event.attachments.count > 0) {
            attCount += event.attachments.count;
        }
    }
    
    return attCount;
}

- (NSInteger)attachmentSizeNotSync
{
    NSUInteger attSize = 0;
    for (NSDictionary *eventDic in self.eventsNotSync) {
        PYEvent *event = [eventDic objectForKey:kUnsyncEventsEventKey];
        for (PYAttachment *attachment in event.attachments) {
            attSize += attachment.fileData.length; //numberOfBytes
        }
    }
    
    return attSize;
}

- (NSString *)apiBaseUrl;
{
    return [NSString stringWithFormat:@"%@://%@%@:%@/%@", self.apiScheme, self.userID, self.apiDomain, @(self.apiPort), self.apiExtraPath];
}


- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (path == nil) path = @"";
    if (!self.accessToken) {
        if (failureHandler) {
            failureHandler([NSError errorWithDomain:@"PYConnection.accessToken is nil" code:1000 userInfo:nil]);
        }
        return;
    }
    NSString* fullPath = [NSString stringWithFormat:@"%@%@",[self apiBaseUrl],path];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:self.accessToken forKey:@"Authorization"];
    
    [PYClient apiRequest:fullPath
                 headers:headers
             requestType:reqType
                  method:method
                postData:postData
             attachments:attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                     
                     
                     NSDictionary* metas = responseDict[kPYAPIResponseMeta];
                     NSNumber* serverTime = nil;
                     if (metas != nil ) {
                         serverTime = [NSNumber numberWithDouble:[metas[kPYAPIResponseMetaServerTime] doubleValue]] ;
                     }
                     
                     if (serverTime == nil) {
                         NSLog(@"Error cannot find Server-Time in headers path: %@", fullPath);
                         
                         
                         /*
                          NSDictionary *errorInfoDic = @{ @"message" : @"Error cannot find Server-Time in headers"};
                          
                          NSError *errorToReturn =
                          [[[NSError alloc] initWithDomain:PryvSDKDomain code:1000 userInfo:errorInfoDic] autorelease];
                          failureHandler(errorToReturn);
                          */
                     } else {
                         _lastTimeServerContact = [[NSDate date] timeIntervalSince1970];
                         _serverTimeInterval = _lastTimeServerContact - [serverTime doubleValue];
                         
                         
                     }
                     
                     if (successHandler) {
                         successHandler(request, response, responseDict);
                     }
                     
                 }
                 failure:failureHandler];
    
}

#pragma mark - PrYv API authorize and get server time (GET /)

/**
 * probably useless as now all requests synchronize
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTimeInterval))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler{
    
    [self apiRequest:@"/profile/app" //TODO: handle app profiles for improved user experience
         requestType:PYRequestTypeAsync
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseValue) {
                 NSLog(@"Successfully authorized and synchronized with server time: %f ", _serverTimeInterval);
                 if (successHandler)
                     successHandler(_serverTimeInterval);
                 
             } failure:^(NSError *error) {
                 if (errorHandler)
                     errorHandler(error);
                 
                 
             }];
}

- (NSString*) idURL
{
    return [NSString stringWithFormat:@"%@?auth=%@", [self apiBaseUrl], self.accessToken];
}

- (NSString*) idCaching
{
    return [NSString
            stringWithFormat:@"%@_%@%@_%@_%@",
            [PYUtils md5FromString:self.idURL],
            self.userID, self.apiDomain, self.apiExtraPath, self.accessToken];
}




@end
