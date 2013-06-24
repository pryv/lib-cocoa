//
//  PYChannelsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelsCachingUtillity.h"
#import "PYCachingController.h"
#import "PYJSONUtility.h"

@implementation PYChannelsCachingUtillity

+ (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

+ (void)cacheChannel:(NSDictionary *)channel WithKey:(NSString *)key
{
    NSString *channelKey = [NSString stringWithFormat:@"channel_%@",key];
    [[PYCachingController sharedManager] cacheData:[PYJSONUtility getDataFromJSONObject:channel] withKey:channelKey];
}

+ (void)cacheChannels:(NSArray *)channels
{
    if ([self cachingEnabled]) {
        for (NSDictionary *channelDic in channels) {
//            [self cacheEvent:eventDic WithKey:eventDic[@"id"]];
            [self cacheChannel:channelDic WithKey:[channelDic objectForKey:@"id"]];
        }
        
    }
}

+ (NSArray *)getChannelsFromCache
{
    return [[PYCachingController sharedManager] getAllChannelsFromCache];
}

+ (PYChannel *)getChannelFromCacheWithChannelId:(NSString *)channelId
{
    NSString *channelKey = [NSString stringWithFormat:@"channel_%@",channelId];
    return [[PYCachingController sharedManager] getChannelWithKey:channelKey];

}


@end
