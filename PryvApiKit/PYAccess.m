//
//  PYAccess.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

NSString const *kUnsyncEventsEventKey       = @"pryv.unsyncevents.Event";
NSString const *kUnsyncEventsRequestKey     = @"pryv.unsyncevents.Request";
//NSString const *kUnsyncEventsRequestTypeKey = @"pryv.unsyncevents.RequestType";

#import "PYAccess.h"
#import "PYClient.h"
#import "PYConstants.h"
#import "PYChannel+JSON.h"
#import "PYEventsCachingUtillity.h"

@implementation PYAccess

@synthesize userID = _userID;
@synthesize accessToken = _accessToken;
@synthesize apiDomain = _apiDomain;
@synthesize apiScheme = _apiScheme;
@synthesize serverTimeInterval = _serverTimeInterval;
@synthesize connectionReachability = _connectionReachability;
@synthesize eventsNotSync = _eventsNotSync;
@synthesize attachmentsCountNotSync = _attachmentsCountNotSync;
@synthesize attachmentSizeNotSync = _attachmentSizeNotSync;
@synthesize lastTimeServerContact = _lastTimeServerContact;

- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token {
    self = [super init];
    if (self) {
        _userID = username;
        _accessToken = token;
        _apiDomain = [PYClient defaultDomain];
        _apiScheme = kPYAPIScheme;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object: nil];
        self.connectionReachability = [Reachability reachabilityForInternetConnection];
        [self.connectionReachability startNotifier];
        [self pyAccessStatus:self.connectionReachability];


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

- (void)addEvent:(PYEvent *)event toUnsyncListIfNeeds:(NSError *)error
{
    if (error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost) {
        NSLog(@"No internet error, put this event in non sync list and cache it if caching is enabled for library");
        NSMutableURLRequest *request = [error.userInfo objectForKey:PryvRequestKey];
        NSLog(@"request.bodyLength %d",request.HTTPBody.length);
        event.time = [[NSDate date] doubleValue];
        NSDictionary *nonSyncEventObject = @{kUnsyncEventsEventKey : event,
                                             kUnsyncEventsRequestKey : request,
                                             };
        [self.eventsNotSync addObject:nonSyncEventObject];
        
    }

}

- (void)serializeNonSyncList:(NSDictionary *)nonSyncList
{
    for (NSDictionary *nonSyncEventObject in nonSyncList) {
        PYEvent *eventForCache = nonSyncEventObject[kUnsyncEventsEventKey];
        [PYEventsCachingUtillity cacheUnsyncEvent:eventForCache];
        [PYEventsCachingUtillity cacheURLRequest:nonSyncEventObject[kUnsyncEventsRequestKey] forEventId:eventForCache.eventId];
        //getNSURLRequest
    }
}

- (void)deserializeNonSyncList
{
    NSArray *nonSyncEventsArray = [PYEventsCachingUtillity getUnsyncEventsFromCache];
    
    for (PYEvent *unsyncEvent in nonSyncEventsArray) {
        NSURLRequest *unsyncURLReq = [PYEventsCachingUtillity getNSURLRequestForEventId:unsyncEvent.eventId];
        NSDictionary *nonSyncEventObject = @{kUnsyncEventsEventKey : unsyncEvent,
                                             kUnsyncEventsRequestKey : unsyncURLReq,
                                             };

        [self.eventsNotSync addObject:nonSyncEventObject];

    }
    
}

- (NSMutableArray *)eventsNotSync
{
    if (!_eventsNotSync) {
        _eventsNotSync = [[NSMutableArray alloc] init];
    }
    
    return _eventsNotSync;
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
        if (self.eventsNotSync && self.eventsNotSync.count > 0) {
            for (NSArray *eventRequest in self.eventsNotSync) {
//                eventRequest[0]
            }
        }
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

- (void)batchSyncEventsWithoutAttachment
{
    
    NSMutableArray *nonSyncEvents = [[[NSMutableArray alloc] init] autorelease];
    [nonSyncEvents addObjectsFromArray:self.eventsNotSync];
    
    for (NSDictionary *eventDic in nonSyncEvents) {
        
        PYEvent *eventToSync = [eventDic objectForKey:kUnsyncEventsEventKey];
        
        if (!eventToSync.attachments.count) {
            NSURLRequest *request = [eventDic objectForKey:kUnsyncEventsRequestKey];
            
//        PYRequestType reqType = [eventDic[kUnsyncEventsRequestTypeKey] intValue];
            [PYClient sendRequest:request withReqType:PYRequestTypeAsync success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"JSON %@",JSON);
                
                eventToSync.synchedAt = [[NSDate date] doubleValue];
                
                [self.eventsNotSync removeObject:eventDic];
                NSLog(@"self.eventsNotSync list after sync %@",self.eventsNotSync);
            } failure:^(NSError *error) {
                NSLog(@"syncEvents error %@",error);
            }];

        }
    }
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
    NSDictionary* headers = @{@"Authorization": self.accessToken};

    [PYClient apiRequest:fullPath headers:headers requestType:reqType method:method postData:postData attachments:attachments
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     NSNumber* serverTime = [[response allHeaderFields] objectForKey:@"Server-Time"];
                     if (serverTime == nil) {
                          NSLog(@"Error cannot find Server-Time in headers");
         
                         NSError *errorToReturn =
                         [[[NSError alloc] initWithDomain:PryvSDKDomain code:1000 userInfo:@{@"message":@"Error cannot find Server-Time in headers"}] autorelease];
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

- (void)getChannelsWithRequestType:(PYRequestType)reqType
                      filterParams:(NSDictionary *)filter
                    successHandler:(void (^)(NSArray *))successHandler
                      errorHandler:(void (^)(NSError *))errorHandler
{
   

    [self apiRequest:[PYClient urlPath:kROUTE_CHANNELS withParams:filter]
         requestType:reqType
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSMutableArray *channelList = [[NSMutableArray alloc] init];
                 for(NSDictionary *channelDictionary in JSON){
                     PYChannel *channelObject = [PYChannel channelFromJson:channelDictionary];
                     channelObject.access = self;
                     [channelList addObject:channelObject];
                 }
                 if(successHandler){
                     successHandler(channelList);
                 }
             } failure:^(NSError *error){
                 if(errorHandler){
                     errorHandler(error);
                 }
             }
     ];
}

//#pragma mark - PrYv API Channel create (POST /channnels)

//- (void)createChannelWithRequestType:(PYRequestType)reqType
//                             channel:(PYChannel *)newChannel
//                      successHandler:(void (^)(PYChannel *channel))successHandler
//                        errorhandler:(void (^)(NSError *error))errorHandler
//{
//    NSString *pathString = @"/channels";
//
//    NSDictionary *postData = [PYChannel jsonFromChannel:newChannel];
//
//    [[self class] apiRequest:pathString requestType:reqType method:PYRequestMethodPOST postData:postData success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"JSON %@", JSON);
//        NSString *channelId = [JSON objectForKey:@"id"];
//        newChannel.channelId = channelId;
//        if(successHandler){
//            successHandler(newChannel);
//        }
//    } failure:^(NSError *error){
//        if(errorHandler){
//            errorHandler(error);
//        }
//    }];
//}

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
    
    [self apiRequest:@"/"
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
