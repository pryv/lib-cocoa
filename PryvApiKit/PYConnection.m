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
#import "PYAttachment.h"
#import "PYConnection+DataManagement.h"
#import "PYCachingController.h"
#import "Reachability.h"
#import "PYCachingController+Event.h"
#import "PYCachingController+Stream.h"
#import "PYUtils.h"

@implementation PYConnection

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize apiDomain = _apiDomain;
@synthesize apiScheme = _apiScheme;
@synthesize apiPort = _apiPort;
@synthesize apiExtraPath = _apiExtraPath;
@synthesize serverTimeInterval = _serverTimeInterval;
@synthesize connectionReachability = _connectionReachability;
@synthesize eventsNotSync = _eventsNotSync;
@synthesize streamsNotSync = _streamsNotSync;
@synthesize attachmentsCountNotSync = _attachmentsCountNotSync;
@synthesize attachmentSizeNotSync = _attachmentSizeNotSync;
@synthesize lastTimeServerContact = _lastTimeServerContact;
@synthesize cache = _cache;

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
        self.connectionReachability = [Reachability reachabilityForInternetConnection];
        [self.connectionReachability startNotifier];
        self.cache = [[[PYCachingController alloc] initWithConnection:self] autorelease];
        [self pyAccessStatus:self.connectionReachability];
        [self initDeserializeNonSyncList];
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
    [_eventsNotSync release];
    _eventsNotSync = nil;
    [_streamsNotSync release];
    _streamsNotSync = nil;
    [_cache release];
    _cache = nil;
    [_apiExtraPath release];
    _apiExtraPath = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (BOOL)isOnline
{
    return _online;
}

- (void)addEvent:(PYEvent *)event toUnsyncList:(NSError *)error
{
    /*When we deserialize unsync list (when app starts) we will know what events are not sync with these informations:
     They have one of these flags or combination of them
     notSyncAdd
     notSyncModify
     notSyncTrashOrDelete
     */
    [self.eventsNotSync addObject:event];
    
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


/**
 * Load event form cache.. Part of this init
 */
- (void)initDeserializeNonSyncList
{
    NSArray *allEventsFromCache = [self.cache eventsFromCache];
    
    for (PYEvent *event in allEventsFromCache) {
        if (event.notSyncAdd || event.notSyncModify || event.notSyncTrashOrDelete) {
            [self.eventsNotSync addObject:event];
        }
    }
    
    NSArray *nonSyncStreamsArray = [self.cache streamsFromCache];
    
    for (PYStream *stream in nonSyncStreamsArray) {
        if (stream.notSyncAdd || stream.notSyncModify) {
            [self.streamsNotSync addObject:stream];
        }
    }
    
    
}

- (NSMutableSet *)eventsNotSync
{
    if (!_eventsNotSync) {
        _eventsNotSync = [[NSMutableSet alloc] init];
    }
    
    return _eventsNotSync;
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
                [self createStream:stream
                   withRequestType:PYRequestTypeAsync
                    successHandler:^(NSString *createdStreamId) {
                        //If succedded remove from unsyncSet and add call syncStreamWithServer
                        //In that method we were search for stream with <createdStreamId> and we should done mapping between server and temp id in cache
                        stream.synchedAt = [[NSDate date] timeIntervalSince1970];
                        stream.streamId = [NSString stringWithString:tempId];
                        
                        [self.streamsNotSync removeObject:stream];
                        //We have success here. Stream is cached in createStream:withRequestType: method, remove old stream with tmpId from cache
                        //He will always have tmpId here but just in case for testing (defensive programing)
                        [self.cache removeStream:stream];
                        
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
                
                [self setModifiedStreamAttributesObject:modifiedStream forStreamId:stream.streamId requestType:PYRequestTypeAsync successHandler:^{
                    
                    //We have success here. Stream is cached in setModifiedStreamAttributesObject:forStreamId method
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

- (void)syncNotSynchedEventsIfAny
{
    NSMutableArray *nonSyncEvents = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncEvents addObjectsFromArray:[self.eventsNotSync allObjects]];
    NSLog(@"Not syncEvents: %@",nonSyncEvents);
    for (PYEvent *event in nonSyncEvents) {
        
        //this is flag for situation where we failed again to sync event. When come to failure block we won't cache this event again
        event.isSyncTriedNow = YES;
        
        if (event.hasTmpId == YES) {
            
            if (event.notSyncModify || event.notSyncTrashOrDelete) {
                NSLog(@"event has tmpId and it's mofified or trashed do nothing. If event doesn't have server id it needs to be added to server and that is all what is matter. Modified or trashed or deleted object will update PYEvent object in cache and in unsyncList");
                
            }
            NSLog(@"event has tmpId and it's added");
            if (event.notSyncAdd) {
                NSString *tempId = [event.eventId copy];
                event.eventId = nil;
                NSLog(@"%@",event);
                [self createEvent:event
                      requestType:PYRequestTypeAsync
                   successHandler:^(NSString *newEventId, NSString *stoppedId) {
                       
                       //If succedded remove from unsyncSet and add call syncEventWithServer(PTEventFilterUtitliy)
                       //In that method we were search for event with <newEventId> and we should done mapping between server and temp id in cache
                       event.synchedAt = [[NSDate date] timeIntervalSince1970];
                       event.eventId = tempId;
                       event.notSyncAdd = NO;
                       event.hasTmpId = NO;
                       
                       [self.eventsNotSync enumerateObjectsUsingBlock:^(PYEvent *obj, BOOL *stop) {
                           if([obj.eventId isEqualToString:event.eventId] || obj.time == event.time)
                           {
                               [self.eventsNotSync removeObject:obj];
                               *stop = YES;
                           }
                       }];
                       
                       //We have success here. Event is cached in createEvent:requestType: method, remove old event with tmpId from cache
                       //He will always have tmpId here but just in case for testing (defensive programing)
                       [self.cache removeEvent:event];
                       
                   } errorHandler:^(NSError *error) {
                       //reset flag if fail, very IMPORTANT
                       event.isSyncTriedNow = NO;
                       event.eventId = tempId;
                       NSLog(@"SYNC error: creating event failed");
                       NSLog(@"%@",error);
                   }];
            }
            
        }else{
            NSLog(@"In this case event has server id");
            
            if (event.notSyncModify) {
                NSLog(@"for modifified unsync events with serverId we have to provide only modified values, not full event object");
                
                NSDictionary *modifiedPropertiesDic = event.modifiedEventPropertiesAndValues;
                PYEvent *modifiedEvent = [[PYEvent alloc] init];
                modifiedEvent.isSyncTriedNow = YES;
                
                [modifiedPropertiesDic enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
                    [modifiedEvent setValue:value forKey:property];
                }];
                
                [self setModifiedEventAttributesObject:modifiedEvent
                                        successHandler:^(NSString *stoppedId) {
                                            
                                            //We have success here. Event is cached in setModifiedEventAttributesObject:forEventId method
                                            
                                            event.synchedAt = [[NSDate date] timeIntervalSince1970];
                                            [self.eventsNotSync removeObject:event];
                                            
                                        } errorHandler:^(NSError *error) {
                                            modifiedEvent.isSyncTriedNow = NO;
                                            event.isSyncTriedNow = NO;
                                            
                                        }];
            }
            
            if (event.notSyncTrashOrDelete) {
                [self trashOrDeleteEvent:event
                         withRequestType:PYRequestTypeAsync
                          successHandler:^{
                              
                          } errorHandler:^(NSError *error) {
                              event.isSyncTriedNow = NO;
                          }];
            }
        }
        //}
    }
}


#pragma mark - Reachability

//Called by Reachability whenever status changes.

- (void)reachabilityChanged:(NSNotification *)notif
{
	Reachability* curReach = [notif object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
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
        [self syncNotSynchedEventsIfAny];
    }
}

- (void)pyAccessStatus:(Reachability *)currReach
{
    if (currReach == self.connectionReachability) {
        if (currReach.currentReachabilityStatus == NotReachable) {
            NSLog(@"No internet, cannot create access");
            _online = NO;
        }else{
            NSLog(@"HAVE internet acces created");
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
    return [NSString stringWithFormat:@"%@://%@%@:%i/%@", self.apiScheme, self.userID, self.apiDomain, self.apiPort, self.apiExtraPath];
}


- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (path == nil) path = @"";
    NSString* fullPath = [NSString stringWithFormat:@"%@%@",[self apiBaseUrl],path];
    NSDictionary *headers = [NSDictionary dictionaryWithObject:self.accessToken forKey:@"Authorization"];
    
   [PYClient apiRequest:fullPath
                 headers:headers
             requestType:reqType
                  method:method
                postData:postData
             attachments:attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    
                     
                     NSDictionary* headerFields = [response allHeaderFields];
                     NSNumber* serverTime = nil;
                     if (headerFields != nil ) {
                        serverTime = [NSNumber numberWithDouble:[[headerFields objectForKey:@"Server-Time"] doubleValue]] ;
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
                         successHandler(request,response,JSON);
                     }
                     
                 }
                 failure:failureHandler];
    
}

#pragma mark - PrYv API authorize and get server time (GET /)

/**
 * probably useless as now all requests synchronize
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTime))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler{
    
    [self apiRequest:@"/profile/app" //TODO: handle app profiles for improved user experience
         requestType:PYRequestTypeAsync
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
