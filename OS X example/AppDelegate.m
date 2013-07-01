//
//  AppDelegate.m
//  OS X example
//
//  Created by Nenad Jelic on 4/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "AppDelegate.h"
#import "PryvApiKit.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [PYClient setDefaultDomainStaging];
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    [access getAllChannelsWithRequestType:PYRequestTypeAsync gotCachedChannels:NULL gotOnlineChannels:^(NSArray *onlineChannelList) {
        NSLog(@"online channels list %@",onlineChannelList);
    } errorHandler:NULL];
}

@end
