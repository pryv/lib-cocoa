//
//  PYChannelsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
@class PYChannel;
#import <Foundation/Foundation.h>

@interface PYChannelsCachingUtillity : NSObject

/**
 Cache channel json objects on disk
 */
+ (void)cacheChannels:(NSArray *)channels;
/**
 Get all PYChannel objects from disk
 */
+ (NSArray *)getChannelsFromCache;
/**
 Get PYChannel from disk for key(channelId)
 */
+ (PYChannel *)getChannelFromCacheWithChannelId:(NSString *)channelId;


@end
