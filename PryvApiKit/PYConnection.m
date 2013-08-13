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

#import "PYConnection.h"
#import "PYClient.h"
#import "PYConstants.h"
#import "PYChannel+JSON.h"
#import "PYEventsCachingUtillity.h"
#import "PYStreamsCachingUtillity.h"
#import "PYChannelsCachingUtillity.h"
#import "PYStream.h"
#import "PYStream+JSON.h"

@implementation PYConnection

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize apiDomain = _apiDomain;
@synthesize apiScheme = _apiScheme;
@synthesize serverTimeInterval = _serverTimeInterval;
@synthesize connectionReachability = _connectionReachability;
@synthesize eventsNotSync = _eventsNotSync;
@synthesize foldersNotSync = _foldersNotSync;
@synthesize attachmentsCountNotSync = _attachmentsCountNotSync;
@synthesize attachmentSizeNotSync = _attachmentSizeNotSync;
@synthesize lastTimeServerContact = _lastTimeServerContact;

- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token {
    self = [super init];
    if (self) {
        self.userID = username;
        self.accessToken = token;
        self.apiDomain = [PYClient defaultDomain];
        self.apiScheme = kPYAPIScheme;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
        self.connectionReachability = [Reachability reachabilityForInternetConnection];
        [self.connectionReachability startNotifier];
        [self pyAccessStatus:self.connectionReachability];
        [self deserializeNonSyncList];
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

- (void)addFolder:(PYStream *)folder toUnsyncList:(NSError *)error
{
    /*When we deserialize unsync list (when app starts) we will know what folders are not sync with these informations:
     They have one of these flags or combination of them
     notSyncAdd
     notSyncModify
     */
    [self.foldersNotSync addObject:folder];
    
}


- (void)deserializeNonSyncList
{
    NSArray *allEventsFromCache = [PYEventsCachingUtillity getEventsFromCache];
    
    for (PYEvent *event in allEventsFromCache) {
        if (event.notSyncAdd || event.notSyncModify || event.notSyncTrashOrDelete) {
            [self.eventsNotSync addObject:event];
        }
    }
    
    NSArray *nonSyncFoldersArray = [PYStreamsCachingUtillity getStreamsFromCache];
    
    for (PYStream *folder in nonSyncFoldersArray) {
        if (folder.notSyncAdd || folder.notSyncModify) {
            [self.foldersNotSync addObject:folder];
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

- (NSMutableSet *)foldersNotSync
{
    if (!_foldersNotSync) {
        _foldersNotSync = [[NSMutableSet alloc] init];
    }
    
    return _foldersNotSync;
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
        [self getAllChannelsWithRequestType:PYRequestTypeAsync gotCachedChannels:NULL gotOnlineChannels:^(NSArray *onlineChannelList) {
            
            //Sync ALL events and folders
            for (PYChannel *channel in onlineChannelList) {
                [channel syncNotSynchedFoldersIfAny];
                [channel syncNotSynchedEventsIfAny];
            }
            
        } errorHandler:^(NSError *error) {
            
        }];
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
    return [NSString stringWithFormat:@"%@://%@%@", self.apiScheme, self.userID, self.apiDomain];
}

- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler {
    
    if (path == nil) path = @"";
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@",[self apiBaseUrl],path];
//    NSDictionary* headers = @{@"Authorization": self.accessToken};
    NSDictionary *headers = [NSDictionary dictionaryWithObject:self.accessToken forKey:@"Authorization"];

    [PYClient apiRequest:fullPath headers:headers requestType:reqType method:method postData:postData attachments:attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     NSNumber* serverTime = [[response allHeaderFields] objectForKey:@"Server-Time"];
                     if (serverTime == nil) {
                          NSLog(@"Error cannot find Server-Time in headers");
                         
                         NSDictionary *errorInfoDic = [NSDictionary dictionaryWithObject:@"Error cannot find Server-Time in headers"
                                                                                  forKey:@"message"];
                         NSError *errorToReturn =
                         [[[NSError alloc] initWithDomain:PryvSDKDomain code:1000 userInfo:errorInfoDic] autorelease];
                         failureHandler(errorToReturn);

                     } else {
                         _lastTimeServerContact = [[NSDate date] timeIntervalSince1970];
                         _serverTimeInterval = _lastTimeServerContact - [serverTime doubleValue];
                         
                         if (successHandler) {
                             successHandler(request,response,JSON);
                         }
                     }
                    
                 }
                 failure:failureHandler];
}

#pragma mark - PrYv API Channel get all (GET /channnels)

- (void)getAllChannelsWithRequestType:(PYRequestType)reqType
                    gotCachedChannels:(void (^) (NSArray *cachedChannelList))cachedChannels
                    gotOnlineChannels:(void (^) (NSArray *onlineChannelList))onlineChannels
                         errorHandler:(void (^)(NSError *error))errorHandler;

{
    //Return current cached channels
    NSArray *allChannelsFromCache = [PYChannelsCachingUtillity getChannelsFromCache];
    [allChannelsFromCache makeObjectsPerformSelector:@selector(setConnection:) withObject:self];
    if (cachedChannels) {
        NSUInteger currentNumberOfChannelsInCache = [PYChannelsCachingUtillity getChannelsFromCache].count;
        if (currentNumberOfChannelsInCache > 0) {
            //if there are cached channels return it, when get response return in onlineList
            cachedChannels(allChannelsFromCache);
        }
    }

    //This method should retrieve always online channels and channelsToAdd, channelsModified, channelsToRemove (for visual details) - not yet implemented due to web service limitations
    [self getChannelsWithRequestType:reqType
                              filter:nil
                      successHandler:^(NSArray *channelsList) {
                            if (onlineChannels) {
                                onlineChannels(channelsList);
                            }
                      }
                        errorHandler:errorHandler];

}

- (void)getChannelsWithRequestType:(PYRequestType)reqType
                            filter:(NSDictionary*)filterDic
                    successHandler:(void (^) (NSArray *eventList))onlineChannelList
                      errorHandler:(void (^)(NSError *error))errorHandler
{
    //This method should retrieve always online channels and need to cache (sync) online channels

    [self apiRequest:[PYClient getURLPath:kROUTE_CHANNELS withParams:filterDic]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSMutableArray *channelList = [[NSMutableArray alloc] init];
                 for(NSDictionary *channelDictionary in JSON){
                     PYChannel *channelObject = [PYChannel channelFromJson:channelDictionary];
                     channelObject.connection = self;
                     [channelList addObject:channelObject];
                 }
                 if(onlineChannelList){
                     [PYChannelsCachingUtillity cacheChannels:JSON];
                     onlineChannelList([channelList autorelease]);
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }
     ];

}

- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedChannels:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineChannels:(void (^) (NSArray *onlineStreamList))onlineStreams
                         errorHandler:(void (^)(NSError *error))errorHandler;

{
    //Return current cached channels
    NSArray *allChannelsFromCache = [PYStreamsCachingUtillity getStreamsFromCache];
    [allChannelsFromCache makeObjectsPerformSelector:@selector(setConnection:) withObject:self];
    if (cachedStreams) {
        NSUInteger currentNumberOfChannelsInCache = [PYChannelsCachingUtillity getChannelsFromCache].count;
        if (currentNumberOfChannelsInCache > 0) {
            //if there are cached channels return it, when get response return in onlineList
            cachedStreams(allChannelsFromCache);
        }
    }
    
    //This method should retrieve always online channels and channelsToAdd, channelsModified, channelsToRemove (for visual details) - not yet implemented due to web service limitations
    [self getStreamsWithRequestType:reqType
                              filter:nil
                      successHandler:^(NSArray *channelsList) {
                          if (onlineStreams) {
                              onlineStreams(channelsList);
                          }
                      }
                        errorHandler:errorHandler];
    
}

- (void)getStreamsWithRequestType:(PYRequestType)reqType
                            filter:(NSDictionary*)filterDic
                    successHandler:(void (^) (NSArray *eventList))onlineChannelList
                      errorHandler:(void (^)(NSError *error))errorHandler
{
    //This method should retrieve always online channels and need to cache (sync) online channels
    
    [self apiRequest:[PYClient getURLPath:kROUTE_STREAMS withParams:filterDic]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 
                 NSMutableArray *channelList = [[NSMutableArray alloc] init];
                 for(NSDictionary *channelDictionary in JSON){
                     PYStream *streamObject = [PYStream streamFromJSON:channelDictionary];
                     streamObject.connection = self;
                     [channelList addObject:streamObject];
                 }
                 if(onlineChannelList){
                     [PYStreamsCachingUtillity cacheStreams:JSON];
                     onlineChannelList([channelList autorelease]);
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }
     ];
    
}

//##########################

- (void)editChannelWithRequestType:(PYRequestType)reqType
                         channelId:(NSString *)channelId
                              data:(NSDictionary *)data
                    successHandler:(void (^)())successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler
{
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_CHANNELS, channelId]
         requestType:reqType
              method:PYRequestMethodPUT
            postData:data
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 if(successHandler){
                     successHandler();
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }];
}

- (void)deleteChannelWithRequestType:(PYRequestType)reqType
                           channelId:(NSString *)channelId
                      successHandler:(void (^)())successHandler
                        errorHandler:(void (^)(NSError *error))errorHandler
{
    
    [self apiRequest:[NSString stringWithFormat:@"%@/%@",kROUTE_CHANNELS, channelId]
             requestType:reqType
                  method:PYRequestMethodDELETE
                postData:nil
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     if(successHandler){
                         successHandler();
                     }
                 } failure:^(NSError *error){
                     if(errorHandler){
                         errorHandler(error);
                     }
                 }];
    
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
                 NSLog(@"successfully authorized and synchronized with server time: %f ", _serverTimeInterval);
           if (successHandler)
                     successHandler(_serverTimeInterval);
     
             } failure:^(NSError *error) {
                 if (errorHandler)
                     errorHandler(error);
                 
                 
             }];
}



@end
