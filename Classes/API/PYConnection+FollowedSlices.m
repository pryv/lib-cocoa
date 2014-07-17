//
//  PYConnection+FollowedSlices.m
//  Pods
//
//  Created by Perki on 18.06.14.
//
//

#import "PYConnection+FollowedSlices.h"
#import "PYConnection+CacheForGetAPIRequest.h"
#import "PYAPIConstants.h"
#import "PYClient+Utils.h"

@implementation PYConnection (FollowedSlices)

-(void)followedSlicesWithSuccessHandler:(void (^) (NSDate* cachedAt, NSArray *slicesList))slicesList
                refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                                failure:(void (^) (NSError *error))failureHandler;

{
    
    [self apiRequestGetOnlineOrFromCache:kROUTE_FOLLOWEDSLICES refreshCacheIfOlderThan:maxAge
                                 success:^(NSDate *cachedAt, NSDictionary *responseDict) {
        NSArray *rArray = responseDict[kPYAPIResponseFollowedSlices];
        if (slicesList) {
            return slicesList(cachedAt, rArray);
            
        }

    } failure:failureHandler];
  }

@end
