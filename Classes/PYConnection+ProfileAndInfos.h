//
//  PYConnection+ProfileAndInfos.h
//  Pods
//
//  Created by Perki on 24.06.14.
//
//

#import "PYConnection.h"

@interface PYConnection (ProfileAndInfos)

/**
 * get the online access Infos of this connection.
 * This update the accessInfos propertie of the connection
 */
-(void)accessInfosWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *infos))accessInfos
             refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                      failureHandler:(void (^) (NSError *error))failureHandler;

/**
 * get the online profile of this connection
 * This update the profilePublic propertie of the connection
 */
-(void)profilePublicWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *profile))profile
               refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                        failureHandler:(void (^) (NSError *error))failureHandler;

/**
 * get the online app profile of this connection
 * This update the profileApp propertie of the connection
 */
-(void)profileAppWithSuccessHandler:(void (^) (NSDate* cachedAt, NSDictionary *profile))profile
            refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                     failureHandler:(void (^) (NSError *error))failureHandler;


@end
