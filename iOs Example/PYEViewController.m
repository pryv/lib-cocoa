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
#import "PYEAppTests.h"


@interface PYEViewController () <PYWebLoginDelegate>

@end

@implementation PYEViewController 

@synthesize signinButton;

- (void)dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)siginButtonPressed: (id) sender  {
    NSLog(@"Signin Started");
    
    
    NSArray *keys = [NSArray arrayWithObjects:kPYAPIConnectionRequestStreamId,
                                                kPYAPIConnectionRequestLevel,
                                                nil];
    
    NSArray *objects = [NSArray arrayWithObjects:   kPYAPIConnectionRequestAllStreams,
                                                    kPYAPIConnectionRequestManageLevel,
                                                    nil];
    
    NSArray *permissions = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjects:objects
                                                                                forKeys:keys]];
    
    [PYClient setDefaultDomainStaging];
    
    __unused
    PYWebLoginViewController *webLoginController =
        [PYWebLoginViewController requestConnectionWithAppId:@"pryv-sdk-ios-example"
                                              andPermissions:permissions
                                                    delegate:self];

}

#pragma mark --PYWebLoginDelegate

- (UIViewController *)pyWebLoginGetController {
    return self;
}

- (void)pyWebLoginSuccess:(PYConnection*)pyAccess {
    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
}

- (void)pyWebLoginAborted:(NSString*)reason {
    NSLog(@"Signin Aborted: %@",reason);
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

#pragma mark - tests

- (IBAction)startTestPressed:(id)sender {
    PYEAppTests* test = [[PYEAppTests alloc] init];
    [test startTests];
    
    //-- no release
}

@end
