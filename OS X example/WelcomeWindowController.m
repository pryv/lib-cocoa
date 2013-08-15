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
#import "PYConnection+DataManagement.h"
#import "AppDelegate.h"
#import "User.h"
#import "PYStreamsCachingUtillity.h"

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
    NSLog(@"Username : %@",[[[AppDelegate sharedInstance] user] username]);
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        [connection getAllStreamsWithRequestType:PYRequestTypeAsync
                               gotCachedStreams:^(NSArray *cachedStreamList) {
                                   NSLog(@"CACHED STREAMS : ");
                                   [cachedStreamList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Cached : %@ (%@)",[obj name], [obj streamId]);
                                   }];
                               } gotOnlineStreams:^(NSArray *onlineStreamList) {
                                   NSLog(@"ONLINE STREAMS : ");
                                   [onlineStreamList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                       NSLog(@"Online : %@ (%@)",[obj name], [obj streamId]);
                                   }];
                               } errorHandler:^(NSError *error) {
                                   NSLog(@"%@",error);
                               }];
    }else{
        NSLog(@"No user connected !");
    }
}

- (IBAction)createTestStream:(id)sender {
    
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user] username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYStream *stream = [[PYStream alloc] init];
        stream.name = @"OSX_Example_test";
        stream.streamId = @"osx_example_test";
        stream.singleActivity = NO;
        stream.children = @[];
        stream.connection = connection;
        [connection createStream:stream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
            NSLog(@"New stream ID : %@",createdStreamId);
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
        [stream release];
        stream = nil;
    }else{
        NSLog(@"No user connected !");
    }
}

- (IBAction)trashTestStream:(id)sender {
    if ([[[AppDelegate sharedInstance] user] username]) {
        NSString *username = [NSString stringWithString:[[[AppDelegate sharedInstance] user]
                                                         username]];
        NSString *token = [NSString stringWithString:[[[AppDelegate sharedInstance] user] token]];
        
        [PYClient setDefaultDomainStaging];
        PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
        
        PYStream *stream = [PYStreamsCachingUtillity
                            getStreamFromCacheWithStreamId:@"osx_example_test"];
        [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
            [connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
                [PYStreamsCachingUtillity removeStream:stream];
                NSLog(@"Stream deleted.");
            } errorHandler:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        } errorHandler:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }else{
        NSLog(@"No user connected !");
    }
}
@end
