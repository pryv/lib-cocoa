//
//  PYAccessTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAccessTests.h"

@implementation PYAccessTests

@synthesize access = _access;
@synthesize channelForTest = _channelForTest;


- (void)setUp
{
    [super setUp];
    self.access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];

}

- (void)testGettingChannels
{
    [self.access getAllChannelsWithRequestType:PYRequestTypeSync gotCachedChannels:^(NSArray *cachedChannelList) {
        
    } gotOnlineChannels:^(NSArray *onlineChannelList) {
        STAssertTrue(onlineChannelList.count > 0, @"Something is wrong with method because we ned to have some online channels");
        
        for (PYChannel *channel in onlineChannelList) {
            //Nenad_test channel
            if ([channel.channelId isEqualToString:@"TVKoK036of"]) {
                STAssertNotNil(channel, @"Error with creating channel object");
                self.channelForTest = channel;
            }
        }
        
    } errorHandler:^(NSError *error) {
        
    }];
    
    
    [self.channelForTest getAllFoldersWithRequestType:PYRequestTypeSync filterParams:nil gotCachedFolders:NULL gotOnlineFolders:^(NSArray *onlineFolderList) {
        
    } errorHandler:^(NSError *error) {
        
    }];
}

- (void)tearDown
{
    [_access release];
    [_channelForTest release];
    [super tearDown];

}

@end
