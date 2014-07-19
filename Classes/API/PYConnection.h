//
//  PYConnection.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"


FOUNDATION_EXPORT NSString *const kPYConnectionOfflineUsername;


FOUNDATION_EXPORT NSString *const kPYConnectionOptionFetchStructure;
FOUNDATION_EXPORT NSString *const kPYConnectionOptionFetchAccessInfos;

FOUNDATION_EXPORT NSString *const kPYConnectionOptionValueYes;
FOUNDATION_EXPORT NSString *const kPYConnectionOptionValueNo;

@class PYReachability;
@class PYEvent;
@class PYStream;
@class PYFilter;
@class PYCachingController;
@class PYOnlineController;

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
    BOOL _onlineStatus;
    NSMutableSet *_streamsNotSync;
    NSUInteger _attachmentsCountNotSync;
    NSInteger _attachmentSizeNotSync;
    
    PYCachingController *_cache;
    PYOnlineController *_online;
    
    
@private
    NSTimeInterval _serverTimeInterval;
    NSMutableDictionary* _fetchedStreamsMap;
    NSArray* _fetchedStreamsRoots;
    NSMutableDictionary* _options;
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
@property (nonatomic, retain) PYOnlineController *online;
@property (nonatomic, copy) NSMutableDictionary *options;

@property (nonatomic, retain) NSMutableDictionary *cacheForGetAPIRequests;

@property (nonatomic, readonly) NSTimeInterval serverTimeInterval;
@property (nonatomic, copy) NSMutableDictionary* fetchedStreamsMap;
@property (nonatomic, copy) NSArray* fetchedStreamsRoots;

//online/offline
@property (nonatomic, retain) NSMutableSet *streamsNotSync;

//ids
/**
 * unique ID that define the connection in the form http[s]://<host>/[path/]?auth=<token>
 */
@property (nonatomic, readonly) NSString *idURL;
@property (nonatomic, readonly) NSString *idCaching;

/**
 * Initalize a newly created object with a username and accessToken. 
 * Connection can be initalized offline first with kPYConnectionOfflineUsername as username. The token will be used a serial number for this connection.
 * @param username pryv's user id for this connection.
 * @param token access token for this connection.
 */
- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token;


/**
 * Options are
 * kPYConnectionOptionFetchStructure auto / none
 * kPYConnectionOptionFetchAccess auto / none
 */
- (void) setUpWithOptions:(NSDictionary*)optionDict andCallBack:(void(^)(NSError *error))done;

/**
 * return true if option is activated for key
 */
- (BOOL) optionIsActivatedForKey:(NSString*)optionKey;


/**
 * Synchronized with a designed account a connection was initalized as in offline first mode. 
 */
- (void) setOnlineModeWithUsername:(NSString *)username andAccessToken:(NSString *)token;

/**
 * Return the url used for this connection. Attention! inconsistent if in Offline first mode.
 */
- (NSString *)apiBaseUrl;



#pragma mark - streams


/**
 Add stream to unsync list. If app tryed to create, modify or trash stream and it fails due to no internet access it will be added to unsync list
 */
- (void)addStream:(PYStream *)stream toUnsyncList:(NSError *)error;

/**
 Low level method for web service communication
 */
- (void)apiRequest:(NSString *)path
            method:(PYRequestMethod)method
          postData:(NSDictionary *)postData
       attachments:(NSArray *)attachments
           success:(PYClientSuccessBlockDict)successHandler
           failure:(PYClientFailureBlock)failureHandler;

/**
 Update cached data in the scope of the cache filter
 */
-(void) updateCache:(void(^)(NSError *error))done;

/**
 * Update cached data in the scope of the cache filter is greater than the passed filter
 * @return NO is the cache.filter does not cover this filter
 */
-(BOOL) updateCache:(void(^)(NSError *error))done ifCacheIncludes:(PYFilter*)filter;



#pragma mark - cache

/**
 Be sure that some structure of the stream as been fetched
 */
-(void) streamsEnsureFetched:(void(^)(NSError *error))done;

#pragma marl - cache events

/** all events form cache ... to be refactored **/
- (NSArray*)allEvents;

#pragma mark - connectivity

/**
 *
 */
@property (nonatomic, readonly, getter = isOnline) BOOL onlineStatus;





@end
