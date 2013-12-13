//
//  PYConnection.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@class Reachability;
@class PYEvent;
@class PYStream;

@interface PYConnection : NSObject
{
    NSString *_userID;
    NSString *_accessToken;
    NSString *_apiScheme;
    NSString *_apiDomain;
    NSTimeInterval _serverTimeInterval;
    NSTimeInterval _lastTimeServerContact;
    
    Reachability *_connectionReachability;
    BOOL _online;
    NSMutableSet *_eventsNotSync;
    NSMutableSet *_streamsNotSync;
    NSUInteger _attachmentsCountNotSync;
    NSInteger _attachmentSizeNotSync;
}

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *apiScheme;
@property (nonatomic, copy) NSString *apiDomain;
@property (nonatomic, readonly) NSTimeInterval serverTimeInterval;
@property (nonatomic, readonly) NSTimeInterval lastTimeServerContact;
@property (nonatomic, retain) Reachability *connectionReachability;

//online/offline
@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, retain) NSMutableSet *eventsNotSync;
@property (nonatomic, retain) NSMutableSet *streamsNotSync;
@property (nonatomic, readonly) NSUInteger attachmentsCountNotSync;
@property (nonatomic, readonly) NSInteger attachmentSizeNotSync;



- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token;

- (NSString *)apiBaseUrl;
/**
 Add event to unsync list. If app tryed to create, modify or trash event and it fails due to no internet access it will be added to unsync list
 */
- (void)addEvent:(PYEvent *)event toUnsyncList:(NSError *)error;
/**
 Add stream to unsync list. If app tryed to create, modify or trash stream and it fails due to no internet access it will be added to unsync list
 */
- (void)addStream:(PYStream *)stream toUnsyncList:(NSError *)error;

/**
 Sync all streams from list
 */
- (void)syncNotSynchedStreamsIfAny;

/**
 Sync all events from list
 */
- (void)syncNotSynchedEventsIfAny;

/**
 Low level method for web service communication
 */
- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;

/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTime))successHandler
                     errorHandler:(void(^)(NSError *error))errorHandler;

@end
