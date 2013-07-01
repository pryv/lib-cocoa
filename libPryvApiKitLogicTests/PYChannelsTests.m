//
//  PYChannelsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelsTests.h"

@implementation PYChannelsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testChannels
{
    [self.access getAllChannelsWithRequestType:PYRequestTypeSync gotCachedChannels:^(NSArray *cachedChannelList) {
        
    } gotOnlineChannels:^(NSArray *onlineChannelList) {
        STAssertTrue(onlineChannelList.count > 0, @"Something is wrong with method because we need to have some online channels");
        
        NSArray *channelsFromCache = [PYChannelsCachingUtillity getChannelsFromCache];
        STAssertTrue(onlineChannelList.count == channelsFromCache.count, @"New channels didn't cached automatically");
        
    } errorHandler:^(NSError *error) {
        
    }];

}

- (void)tearDown
{
    [super tearDown];
}


@end
