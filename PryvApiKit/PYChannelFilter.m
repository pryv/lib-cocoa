//
//  PYChannelFilter.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/13/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelFilter.h"
#import "PYChannelsCachingUtillity.h"
#import "PYChannelFilterUtility.h"

@implementation PYChannelFilter

@synthesize connection = _connection;
@synthesize channelState = _channelState;
@synthesize limit = _limit;
@synthesize lastRefresh = _lastRefresh;

- (id)initWithAccess:(PYConnection *)access
            andState:(PYChannelState)channelState
               limit:(NSUInteger)limit
{
    if (self = [super init]) {
        _connection = access;
        _channelState = channelState;
        _limit = limit;
    }
    return self;
}

- (void)getChannelsWithRequestType:(PYRequestType)reqType
                      filterParams:(NSDictionary *)filter
                 gotCachedChannels:(void (^) (NSArray *cachedChannelList))cachedChannels
                 gotOnlineChannels:(void (^) (NSArray *pnlineChannelList))onlineChannels
                    successHandler:(void (^) (NSArray *channelsToAdd, NSArray *channelsToRemove, NSArray *channelsModified))syncDetails
                      errorHandler:(void (^)(NSError *error))errorHandler;

{
    // get all channels cached matching this filter
    NSArray *allChannelsFromCache = [PYChannelsCachingUtillity getChannelsFromCache];
    NSArray* filteredChannelsFromCache = [PYChannelFilterUtility filterCachedChannels:allChannelsFromCache withFilter:self];
    cachedChannels(filteredChannelsFromCache);
    
    [_connection getChannelsWithRequestType:reqType
                                 filter:[PYChannelFilterUtility filteredChannels:self]
                         successHandler:^(NSArray *onlineChannelList) {
                             self.lastRefresh = [[NSDate date] timeIntervalSince1970];
                             
                             NSMutableArray *channelsToAdd = [[[NSMutableArray alloc] init] autorelease];
                             NSMutableArray *channelsToRemove = [[[NSMutableArray alloc] init] autorelease];
                             NSMutableArray *channelsModified = [[[NSMutableArray alloc] init] autorelease];
                             
                             [PYChannelFilterUtility createChannelsSyncDetails:onlineChannelList
                                                             offlineChannels:filteredChannelsFromCache
                                                               channelsToAdd:channelsToAdd
                                                            channelsToRemove:channelsToRemove
                                                            channelsModified:channelsModified];
                             
                             syncDetails(channelsToAdd, channelsToRemove, channelsModified);

        
                         } errorHandler:errorHandler];    
}


@end
