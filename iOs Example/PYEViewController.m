//
//  PYEViewController.m
//  iOs Example
//
//  Created by Pierre-Mikael Legris on 06.02.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEViewController.h"
#import "PryvApiKit.h"

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

    NSString *channelId = @"position";
    
    NSMutableDictionary *channelData = [[NSMutableDictionary alloc] init];
    [channelData setObject:@"Position2" forKey:@"name"];

    NSMutableDictionary *clientData = [[NSMutableDictionary alloc] init];
    [clientData setObject:@"value" forKey:@"key"];
    [channelData setObject:clientData forKey:@"clientData"];
        
    [[PYChannelClient channelClient] editChannelWithRequestType:PYRequestTypeSync channelId:channelId data:channelData successHandler:^(){
        NSLog(@"edit success");
    } errorHandler:^(NSError *error){
        NSLog(@"edit error %@", error);
    }];
    
//    [[PYFolderClient folderClient] getFoldersWithRequestType:PYRequestTypeAsync
//                                                filterParams:@"state=default&includeHidden=true"
//                                              successHandler:^(NSArray *folderList)
//     {
//         NSLog(@"folder list %@",folderList);
//     }errorHandler:^(NSError *error) {
//         NSLog(@"error %@",error);
//     }];
//    
    
    [[PYChannelClient channelClient] getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList)
    {
        NSLog(@"channel list %@", channelList);
    } errorHandler:^(NSError *error) {
        NSLog(@"error %@", error);
    }];
    

    NSLog(@"end of viewDidLoad");
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
