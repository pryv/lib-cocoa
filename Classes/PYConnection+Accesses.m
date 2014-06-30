//
//  PYConnection+Accesses.m
//  Pods
//
//  Created by Perki on 16.06.14.
//
//

#import "PYConnection+Accesses.h"
#import "PYConnection+CacheForGetAPIRequest.h"
#import "PYConstants.h"
#import "PYClient+Utils.h"

@implementation PYConnection (Accesses)

-(void)accessesWithSuccessHandler:(void (^) (NSDate* cachedAt, NSArray *accessesList))accessesList
          refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                   failureHandler:(void (^) (NSError *error))failureHandler {
    
    [self apiRequestGetOnlineOrFromCache:kROUTE_ACCESSES refreshCacheIfOlderThan:maxAge
                                 success:^(NSDate *cachedAt, NSDictionary *responseDict) {
                                     NSArray *rArray = responseDict[kPYAPIResponseAccesses];
                                     if (accessesList) {
                                         return accessesList(cachedAt, rArray);
                                         
                                     }
                                     
                                 } failure:failureHandler];
    
}
@end
