//
//  PYChannelFilterUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/13/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

/**
 @discussion
 This class will be used in the future when web service support these functionalities
 */

#import <Foundation/Foundation.h>
#import "PYChannelFilter.h"

@interface PYChannelFilterUtility : NSObject

+ (NSArray *)filterCachedChannels:(NSArray *)cachedChannelsArray withFilter:(PYChannelFilter *)filter;
+ (NSDictionary *)filteredChannels:(PYChannelFilter *)filter;

+ (void)createChannelsSyncDetails:(NSArray *)onlineChannelList
                  offlineChannels:(NSArray *)cachedChannels
                    channelsToAdd:(NSMutableArray *)channelsToAdd
                 channelsToRemove:(NSMutableArray *)channelsToRemove
                 channelsModified:(NSMutableArray *)channelsModified;

@end
