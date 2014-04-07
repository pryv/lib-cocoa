//
//  PYConnection.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@class PYReachability;
@class PYEvent;
@class PYStream;
@class PYCachingController;

@interface PYConnection : NSObject
{
    NSString *_userID;
    NSString *_accessToken;
    NSString *_apiScheme;
    NSString *_apiDomain;
    NSUInteger _apiPort;
    NSString *_apiExtraPath;
    
    NSTimeInterval _lastTimeServerContact;
    
    PYReachability *_connectionReachability;
    BOOL _online;
    NSMutableSet *_streamsNotSync;
    NSUInteger _attachmentsCountNotSync;
    NSInteger _attachmentSizeNotSync;
    
    PYCachingController *_cache;
    
    
    
@private
    NSTimeInterval _serverTimeInterval;
    NSMutableDictionary* _fetchedStreamsMap;
    NSArray* _fetchedStreamsRoots;
}

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *apiScheme;
@property (nonatomic, copy) NSString *apiDomain;
@property (nonatomic) NSUInteger apiPort;
@property (nonatomic, copy) NSString *apiExtraPath;
@property (nonatomic, readonly) NSTimeInterval lastTimeServerContact;
@property (nonatomic, retain) PYReachability *connectionReachability;
@property (nonatomic, retain) PYCachingController *cache;

@property (nonatomic, readonly) NSTimeInterval serverTimeInterval;
@property (nonatomic, copy) NSMutableDictionary* fetchedStreamsMap;
@property (nonatomic, copy) NSArray* fetchedStreamsRoots;

//online/offline
@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, retain) NSMutableSet *streamsNotSync;
@property (nonatomic, readonly) NSUInteger attachmentsCountNotSync;
@property (nonatomic, readonly) NSInteger attachmentSizeNotSync;

//ids
/**
 * unique ID that define the connection in the form http[s]://<host>/[path/]?auth=<token>
 */
@property (nonatomic, readonly) NSString *idURL;
@property (nonatomic, readonly) NSString *idCaching;



- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token;

- (NSString *)apiBaseUrl;

/**
 * Get all event known by cache
 */
- (NSArray *)allEventsFromCache;

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
- (void)syncNotSynchedEventsIfAny:(void(^)(int successCount, int overEventCount))done;

/**
 Low level method for web service communication
 */
- (void)apiRequest:(NSString *)path
       requestType:(PYRequestType)reqType
            method:(PYRequestMethod)method
          postData:(NSDictionary *)postData
       attachments:(NSArray *)attachments
           success:(PYClientSuccessBlockDict)successHandler
           failure:(PYClientFailureBlock)failureHandler;

/**
 Be sure that some structure of the stream as been fetched
 */
-(void) streamsEnsureFetched:(void(^)(NSError *error))done;



/**
 @discussion
 this method simply connect to the Pryv API and synchronize with the localTime
 Delta time in seconds between server and machine is returned
 This method will be called when you start the manager
 
 GET /
 
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTimeInterval))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler;





@end
