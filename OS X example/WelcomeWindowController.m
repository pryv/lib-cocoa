//
//  WelcomeWindowWindowController.m
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "WelcomeWindowController.h"
#import "SigninWindowController.h"
#import "PryvApiKit.h"
#import "PYConnection.h"
#import "AppDelegate.h"
#import "User.h"

@interface WelcomeWindowController ()

@end

@implementation WelcomeWindowController
@synthesize signinButton;

- (IBAction)signinButtonPressed:(id)sender {
    if(!signinWindowController)
        signinWindowController = [[SigninWindowController alloc] initWithWindowNibName:@"SigninWindowController"];
    [signinWindowController showWindow:self];    
}

- (IBAction)getStreams:(id)sender {    
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        [connection getAllStreamsWithRequestType:PYRequestTypeAsync
                               gotCachedChannels:^(NSArray *cachedChannelList) {
                                   NSLog(@"CACHED STREAMS : ");
                                   [cachedChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Cached : %@ (%@)",[obj name], [obj streamId]);
                                   }];
                               } gotOnlineChannels:^(NSArray *onlineChannelList) {
                                   NSLog(@"ONLINE STREAMS : ");
                                   [onlineChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Online : %@ (%@)",[obj name], [obj streamId]);
                                   }];
                               } errorHandler:^(NSError *error) {
                                   NSLog(@"%@",error);
                               }];
    }else{
        NSLog(@"No user connected !");
    }
}
@end
