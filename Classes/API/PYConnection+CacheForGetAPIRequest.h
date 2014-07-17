//
//  PYConnection+CacheForGetAPIRequest.h
//  Pods
//
//  Created by Perki on 30.06.14.
//
//  Helper that caches can cache some API request

#import "PYConnection.h"

@interface PYConnection (CacheForGetAPIRequest)

/**
 * Makes an API requests and caches the response, if success
 */
- (void) apiRequestGetOnlineAndCache:(NSString *)path
                             success:(void(^)(NSDictionary *JSON))successHandler
                             failure:(PYClientFailureBlock)failureHandler;



/**
 * Makes an API Get requests if not in cache or try to refresh if latest is older that the delay stated.
 * @param ageInSeconds set to <= 0 to use cached version anyway
 */
- (void) apiRequestGetOnlineOrFromCache:(NSString *)path
                refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                                success:(void(^)(NSDate *cachedAt, NSDictionary *JSON))successHandler
                                failure:(PYClientFailureBlock)failureHandler;


@end
