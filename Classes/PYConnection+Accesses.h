//
//  PYConnection+Accesses.h
//  Pods
//
//  Created by Perki on 16.06.14.
//
//

#import "PYConnection.h"

@interface PYConnection (Accesses)

-(void)accessesOnlineWithSuccessHandler:(void (^) (NSArray *accessesList))onlineAccessesList
                           errorHandler:(void (^) (NSError *error))errorHandler;

@end
