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

+ (void)cacheChannels:(NSArray *)channels;

+ (NSArray *)getChannelsFromCache;
+ (PYChannel *)getChannelFromCacheWithChannelId:(NSString *)channelId;


@end
