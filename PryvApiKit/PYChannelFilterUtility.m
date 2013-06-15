//
//  PYChannelFilterUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/13/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelFilterUtility.h"

@implementation PYChannelFilterUtility

+ (void)createChannelsSyncDetails:(NSArray *)onlineChannelList
                  offlineChannels:(NSArray *)cachedChannels
                    channelsToAdd:(NSMutableArray *)channelsToAdd
                 channelsToRemove:(NSMutableArray *)channelsToRemove
                 channelsModified:(NSMutableArray *)channelsModified
{
    //TODO Can't be done now because there is no ETag or any other info that I can use to identify channel state
}

+ (NSDictionary *)filteredChannels:(PYChannelFilter *)filter
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    
    switch (filter.channelState) {
        case PYChannelStateAll:
            [dic setObject:@"all" forKey:@"state"];
            break;
        case PYChannelStateDefault:
            [dic setObject:@"default" forKey:@"state"];
            break;
        case PYChannelStateTrashed:
            [dic setObject:@"trashed" forKey:@"state"];
            break;
        default:
            break;
    }
    
    return dic;
}

+ (NSArray *)filterCachedChannels:(NSArray *)cachedChannelsArray withFilter:(PYChannelFilter *)filter
{
    NSArray *result = [cachedChannelsArray filteredArrayUsingPredicate:[self cachedChannelsPredicateWithFilter:filter]];
    if (result.count > filter.limit)
    {
        NSArray *limitedArray = [result subarrayWithRange:NSMakeRange(0, filter.limit)];
        return  limitedArray;
    }
    return result;
}

+ (NSPredicate *)cachedChannelsPredicateWithFilter:(PYChannelFilter *)filter
{
    //TODO :Not tested and not fully implemented
    NSPredicate *channelPredicate = nil;
    
    switch (filter.channelState) {
        case PYChannelStateAll:{
        //trashed LIKE[cd] %@, filter.trashed
            channelPredicate = [NSPredicate predicateWithFormat:@"*"];
            break;
        }
        case PYChannelStateDefault:
        {
            channelPredicate = [NSPredicate predicateWithFormat:@"trashed LIKE[cd] %@", @""];
            break;
        }
        case PYChannelStateTrashed:
        {
            channelPredicate = [NSPredicate predicateWithFormat:@"trashed == %@", @YES];
            break;
        }
        default:
            break;
    }
    
    return channelPredicate;
}

@end
