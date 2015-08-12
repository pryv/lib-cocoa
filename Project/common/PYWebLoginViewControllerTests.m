//
//  PYWebLoginViewControllerTests.m
//  PryvApiKit
//
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"

#import "PYConnection.h"
#import "PYTestsUtils.h"
#import "PYTestConstants.h"

#import <WebKit/WebKit.h>
#import <Cocoa/Cocoa.h>

@interface PYWebLoginViewControllerTests : PYBaseConnectionTests <PYWebLoginDelegate>
@end

@implementation PYWebLoginViewControllerTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{
    // insert teardown here
    
    [super tearDown];
}


- (void)testWebLogin
{
    NSLog(@"Signin Started");

    WebView *webView = [[WebView alloc] init];
    
    NSArray *keys = [NSArray arrayWithObjects:  kPYAPIConnectionRequestStreamId,
                     kPYAPIConnectionRequestLevel,
                     nil];
    
    NSArray *objects = [NSArray arrayWithObjects:   kPYAPIConnectionRequestAllStreams,
                        kPYAPIConnectionRequestManageLevel,
                        nil];
    
    
    NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects
                                                                                forKeys:keys]];
    
    //[PYClient setDefaultDomainStaging];
    __unused
    PYWebLoginViewController *webLoginController =
        [PYWebLoginViewController requestConnectionWithAppId:@"pryv-sdk-macosx-tests"
                                              andPermissions:permissions
                                                    delegate:self
                                                 withWebView:&webView];
    
    
    [webLoginController handlePollSuccess:@{@"status" : @"ACCEPTED", @"username": kPYAPITestAccount , @"token": kPYAPITestAccessToken}];
    
    
}


- (void) pyWebLoginSuccess:(PYConnection*)pyConnection {
    
    NSLog(@"Signin With Success %@ %@",pyConnection.userID,pyConnection.accessToken);
    
}

- (void) pyWebLoginAborted:(NSString*)reason {
    NSLog(@"Signin Aborted: %@",reason);
}

- (void) pyWebLoginError:(NSError*)error {
    NSLog(@"Signin Error: %@",error);
}

@end

