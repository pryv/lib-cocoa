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
    // Insert code here to initialize your application
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    
    [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
        NSLog(@"channel list %@",channelList);
        
    }errorHandler:^(NSError *error) {
        
    }];
    

}

@end
