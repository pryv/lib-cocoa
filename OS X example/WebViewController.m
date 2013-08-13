//
//  WebViewController.m
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "WebViewController.h"
#import "PryvApiKit.h"
//#import "PYWebLoginViewController.h"

@interface WebViewController () <PYWebLoginDelegate>

@end

@implementation WebViewController

@synthesize webView;

-(void)awakeFromNib{
    
    NSLog(@"Signin Started");
    
    NSArray *keys = [NSArray arrayWithObjects:  kPYAPIConnectionRequestStreamId,
                     kPYAPIConnectionRequestLevel,
                     nil];
    
    NSArray *objects = [NSArray arrayWithObjects:   kPYAPIConnectionRequestAllStreams,
                        kPYAPIConnectionRequestManageLevel,
                        nil];

    
    NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects
                                                                                forKeys:keys]];
    
    [PYClient setDefaultDomainStaging];
    [PYWebLoginViewController requestConnectionWithAppId:@"pryv-sdk-macosx-example"
                                      andPermissions:permissions
                                            delegate:self
                                         withWebView:&webView];
}

-(void)windowWillClose:(NSNotification *)notification{
    //[self pyWebLoginNotVisible:notification];
    //NSLog(@"Notification posted");
}

//- (void) pyWebLoginNotVisible:(NSNotification *)notification {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kPYWebViewLoginNotVisibleNotification object:self];
//}

- (void) pyWebLoginSuccess:(PYConnection*)pyAccess {
    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
    [pyAccess getAllChannelsWithRequestType:PYRequestTypeAsync gotCachedChannels:^(NSArray *cachedChannelList) {
            [cachedChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"%@ (%@)",[obj name], [obj channelId]);
            }];
    } gotOnlineChannels:^(NSArray *onlineChannelList) {
        [onlineChannelList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@ (%@)",[obj name], [obj channelId]);
        }];
    } errorHandler:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}
- (void) pyWebLoginAborded:(NSString*)reason {
    NSLog(@"Signin Aborded: %@",reason);
}

- (void) pyWebLoginError:(NSError*)error {
    NSLog(@"Signin Error: %@",error);
}


@end
