//
//  PYConnection+FollowedSlices.h
//  Pods
//
//  Created by Perki on 18.06.14.
//
//

#import "PYConnection.h"

@interface PYConnection (FollowedSlices)

/**
 * retrieve the followedSlices online or from cache.
 * @param maxAge If <= 0 try to fetch online
 */
-(void)followedSlicesWithSuccessHandler:(void (^) (NSDate* cachedAt, NSArray *slicesList))slicesList
                refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                                failure:(void (^) (NSError *error))failure;

@end
