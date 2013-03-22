//
//  PYChannelClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PYApiConnectionClient.h"

@interface PYChannelClient : PYApiConnectionClient

//+ (PYChannelClient *)sharedClient;

// ---------------------------------------------------------------------------------------------------------------------
// @name Channel operations
// ---------------------------------------------------------------------------------------------------------------------


- (void)getChannelsWithSuccessHandler:(void (^)(NSArray *channelList))successHandler
                         errorHandler:(void (^)(NSError *error))errorHandler;


@end
