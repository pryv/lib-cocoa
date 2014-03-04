//
//  WebViewController.m
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "WebViewController.h"
#import "PryvApiKit.h"
#import "User.h"
#import "AppDelegate.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYStream.h"
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
    
    //[PYClient setDefaultDomainStaging];
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

- (void) pyWebLoginSuccess:(PYConnection*)pyConnection {
    AppDelegate *app =[AppDelegate sharedInstance];
    app.user = [[User alloc]
                initWithUsername:[NSString stringWithString:pyConnection.userID]
                andToken:[NSString stringWithString:pyConnection.accessToken]];
  
    NSLog(@"Signin With Success %@ %@",pyConnection.userID,pyConnection.accessToken);
    [pyConnection synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
    
}

- (void) pyWebLoginAborted:(NSString*)reason {
    NSLog(@"Signin Aborded: %@",reason);
}

- (void) pyWebLoginError:(NSError*)error {
    NSLog(@"Signin Error: %@",error);
}


@end
