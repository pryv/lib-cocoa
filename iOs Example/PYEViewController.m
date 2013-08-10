//
//  PYEViewController.m
//  iOs Example
//
//  Created by Pierre-Mikael Legris on 06.02.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEViewController.h"
#import "PryvApiKit.h"
#import "PYWebLoginViewController.h"

@interface PYEViewController () <PYWebLoginDelegate>

@end

@implementation PYEViewController 

@synthesize signinButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PYClient setDefaultDomainStaging];
    
    PYConnection *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
        
    [access getAllChannelsWithRequestType:PYRequestTypeSync
                        gotCachedChannels:^(NSArray *cachedChannelList) {
        NSLog(@"cachedChannelList %@",cachedChannelList);
        
        for (PYChannel *channel in cachedChannelList) {
            //Nenad_test channel
            if ([channel.channelId isEqualToString:@"TVKoK036of"]) {
                
            }
        }
    
    
            
    } gotOnlineChannels:^(NSArray *onlineChannelList) {
        

        for (PYChannel *channel in onlineChannelList) {
            
            //Nenad_test channel
            if ([channel.channelId isEqualToString:@"TVKoK036of"]) {
                
            }
        }
        
    } errorHandler:^(NSError *error) {
        NSLog(@"isOnline %d",access.isOnline);
    }];
    
}

- (IBAction)siginButtonPressed: (id) sender  {
    NSLog(@"Signin Started");
    
//    NSArray *permissions = @[ @{ @"channelId": @"*", @"level": @"manage"}];
    
    NSArray *objects = [NSArray arrayWithObjects:@"*", @"manage", nil];
    NSArray *keys = [NSArray arrayWithObjects:@"channelId", @"level", nil];
    
    NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
    
    [PYClient setDefaultDomainStaging];
    [PYWebLoginViewController requestAccessWithAppId:@"pryv-sdk-ios-example"
                                     andPermissions:permissions
                                           delegate:self];

}

#pragma mark --PYWebLoginDelegate

- (UIViewController *) pyWebLoginGetController {
    return self;
}

- (void) pyWebLoginSuccess:(PYConnection*)pyAccess {
    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
}
- (void) pyWebLoginAborded:(NSString*)reason {
    NSLog(@"Signin Aborded: %@",reason);
}

- (void) pyWebLoginError:(NSError*)error {
    NSLog(@"Signin Error: %@",error);
}


#pragma mark -- 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
