//
//  PYConnection+ProfileAndInfos.m
//  Pods
//
//  Created by Perki on 24.06.14.
//
//

#import "PYConnection+ProfileAndInfos.h"
#import "PYConnection+CacheForGetAPIRequest.h"
#import "PYAPIConstants.h"
#import "PYClient+Utils.h"

@implementation PYConnection (ProfileAndInfos)

/**
 * get the online access Infos of this connection.
 * This update the accessInfos propertie of the connection
 */
-(void)accessInfosWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *infos))accessInfos
                   refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                            failureHandler:(void (^) (NSError *error))failureHandler {
    
    
    [self apiRequestGetOnlineOrFromCache:kROUTE_ACCESSINFOS
                 refreshCacheIfOlderThan:maxAge
                                 success:accessInfos
                                 failure:failureHandler];
}

/**
 * get the online profile of this connection
 * This update the profilePublic propertie of the connection
 */
-(void)profilePublicWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *profile))profile
                     refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                              failureHandler:(void (^) (NSError *error))failureHandler {
    
    [self apiRequestGetOnlineOrFromCache:kROUTE_PROFILEPUBLIC refreshCacheIfOlderThan:maxAge
                                 success:^(NSDate *cachedAt, NSDictionary *responseDict) {
                                     NSDictionary *rDictionary = responseDict[kPYAPIResponseProfile];
                                     if (profile) {
                                         return profile(cachedAt, rDictionary);
                                     }
                                 } failure:failureHandler];
    
}

/**
 * get the online app profile of this connection
 * This update the profileApp propertie of the connection
 */
-(void)profileAppWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *profile))profile
                  refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                           failureHandler:(void (^) (NSError *error))failureHandler {
    
    [self apiRequestGetOnlineOrFromCache:kROUTE_PROFILEAPP refreshCacheIfOlderThan:maxAge
                                 success:^(NSDate *cachedAt, NSDictionary *responseDict) {
                                     NSDictionary *rDictionary = responseDict[kPYAPIResponseProfile];
                                     if (profile) {
                                         return profile(cachedAt, rDictionary);
                                     }
                                 } failure:failureHandler];
}
@end
