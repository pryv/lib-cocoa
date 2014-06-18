//
//  PYConnection+FollowedSlices.h
//  Pods
//
//  Created by Perki on 18.06.14.
//
//

#import "PYConnection.h"

@interface PYConnection (FollowedSlices)

-(void)followedSlicesOnlineWithSuccessHandler:(void (^) (NSArray *slicesList))onlineSlicesList
                           errorHandler:(void (^) (NSError *error))errorHandler;

@end
