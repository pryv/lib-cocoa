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
    
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
        
        for (PYChannel *channel in channelList) {
            [channel getFoldersWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *folderList) {
                [channel createFolderWithId:@"sdfsdfsdfsdfsdf" name:@"Konstantin" parentId:@"38c749a01e3720c43306b73369c3565b21cdf30c" isHidden:NO isTrashed:NO customClientData:nil withRequestType:PYRequestTypeSync successHandler:^(NSString *createdFolderId) {
                    
                } errorHandler:^(NSError *error) {
                    
                }];
            } errorHandler:^(NSError *error) {
                
            }];

        }
        
        
    } errorHandler:^(NSError *error) {
        
    }];
    
    
//    [[PYApiConnectionClient sharedPYApiConnectionClient] startClientWithUserId:@"perkikiki"
//                                                         oAuthToken:kPYUserTempToken
//                                                     successHandler:^(NSTimeInterval serverTime)
//     {
//         NSLog(@"success");
//     }errorHandler:^(NSError *error) {
//        NSLog(@"");
//    }];
//
//    NSString *channelId = @"position";
//    
//    NSMutableDictionary *channelData = [[NSMutableDictionary alloc] init];
//    [channelData setObject:@"Position2" forKey:@"name"];
//
//    NSMutableDictionary *clientData = [[NSMutableDictionary alloc] init];
//    [clientData setObject:@"value" forKey:@"key"];
//    [channelData setObject:clientData forKey:@"clientData"];
//        
//    [[PYChannelClient sharedPYChannelClient] editChannelWithRequestType:PYRequestTypeSync channelId:channelId data:channelData successHandler:^(){
//        NSLog(@"edit success");
//    } errorHandler:^(NSError *error){
//        NSLog(@"edit error %@", error);
//    }];
//    
//    [[PYFolderClient sharedPYFolderClient] getFoldersWithRequestType:PYRequestTypeAsync
//                                                filterParams:nil
//                                              successHandler:^(NSArray *folderList)
//     {
//         NSLog(@"folder list %@",folderList);
//     }errorHandler:^(NSError *error) {
//         NSLog(@"error %@",error);
//     }];
//    
//    
//    [[PYChannelClient sharedPYChannelClient] getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList)
//    {
//        NSLog(@"channel list %@", channelList);
//    } errorHandler:^(NSError *error) {
//        NSLog(@"error %@", error);
//    }];
//    
//
//    NSLog(@"end of viewDidLoad");
}

- (IBAction)siginButtonPressed: (id) sender  {
    NSLog(@"Signin Started");

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
