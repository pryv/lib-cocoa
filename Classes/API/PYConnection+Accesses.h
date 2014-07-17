//
//  PYConnection+Accesses.h
//  Pods
//
//  Created by Perki on 16.06.14.
//
//

#import "PYConnection.h"

@interface PYConnection (Accesses)

-(void)accessesWithSuccessHandler:(void (^) (NSDate* cachedAt, NSArray *accessesList))accessesList
          refreshCacheIfOlderThan:(NSTimeInterval)maxAge
                   failureHandler:(void (^) (NSError *error))failureHandler;

@end
