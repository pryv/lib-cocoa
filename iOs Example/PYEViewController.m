//
//  PYEViewController.m
//  iOs Example
//
//  Created by Pierre-Mikael Legris on 06.02.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEViewController.h"
#import "PryvApiKit.h"
//#import "PYChannelClient.h"
//#import "PYApiClient.h"
//#import <libPryvApiKit.a>

@interface PYEViewController ()

@end

@implementation PYEViewController

@synthesize signinButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[PYApiConnectionClient sharedClient] startClientWithUserId:@"perkikiki"
                                                         oAuthToken:kPYUserTempToken
                                                          channelId:kPrYvApplicationChannelId
                                                     successHandler:^(NSTimeInterval serverTime)
     {
         NSLog(@"success");
     }errorHandler:^(NSError *error) {
        NSLog(@"");
    }];
    
    [[PYFolderClient folderClient] getFoldersWithRequestType:PYRequestTypeAsync
                                                filterParams:@"state=default&includeHidden=true"
                                              successHandler:^(NSArray *folderList)
     {
         NSLog(@"folder list %@",folderList);
     }errorHandler:^(NSError *error) {
         NSLog(@"error %@",error);
     }];

    NSLog(@"sdfsd");
}

- (IBAction)siginButtonPressed: (id) sender  {
    NSLog(@"Signin Started");
    [PYApiConnectionClient sharedClient];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
