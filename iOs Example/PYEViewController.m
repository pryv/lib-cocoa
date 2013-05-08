//
//  PYEViewController.m
//  iOs Example
//
//  Created by Pierre-Mikael Legris on 06.02.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEViewController.h"
#import "PryvApiKit.h"
#import "PryvWebLoginViewController.h"

@interface PYEViewController () <PYWebLoginDelegate>

@end

@implementation PYEViewController 

@synthesize signinButton;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PryvClient setDefaultDomainStaging];
        
    PryvAccess *access = [PryvClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    [access getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList) {
        
        for (PryvChannel *channel in channelList) {
            
            
            if ([channel.channelId isEqualToString:@"position"]) {
                
                [channel getAllEventsWithRequestType:PYRequestTypeAsync successHandler:^(NSArray *eventList) {
                    
                    
                } errorHandler:^(NSError *error) {
                    NSLog(@"get all events error is %@",error);
                }];
                
                PryvEventType *eventType = [[PryvEventType alloc] initWithClass:PYEventClassNote andFormat:PYEventFormatTxt];
                NSString *noteTextValue = @"newww432";
                PryvEventNote *noteEvent = [[PryvEventNote alloc] initWithType:eventType
                                                                 noteValue:noteTextValue
                                                                  folderId:nil
                                                                      tags:nil
                                                               description:nil
                                                                clientData:nil];
                NSString *imgName = @"image003";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"jpg"];
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];

                PryvAttachment *att = [[PryvAttachment alloc] initWithFileData:imageData
                                                                      name:imgName
                                                                  fileName:@"image003.jpg"];
                [noteEvent addAttachment:att];
                
                
                NSString *pdfName = @"Pryv_ecosystem";
                NSString *pdfPath = [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"];
                NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];

                PryvAttachment *att1 = [[PryvAttachment alloc] initWithFileData:pdfData
                                                                      name:pdfName
                                                                  fileName:@"Pryv_ecosystem.pdf"];
                [noteEvent addAttachment:att1];


                [channel createEvent:noteEvent requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"success %@", newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"error %@",error);
                }];

                
                
//                [channel setModifiedEventAttributesObject:noteEvent
//                                               forEventId:@"VPRioMho45"
//                                              requestType:PYRequestTypeSync
//                                           successHandler:^(NSString *stoppedId) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];
//                
//                [channel startPeriodEvent:noteEvent requestType:PYRequestTypeSync successHandler:^(NSString *createdFolderId) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];

                
//                [channel getRunningPeriodEventsWithRequestType:PYRequestTypeSync successHandler:^(NSArray *arrayOfEvents) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];
                
//                [channel stopPeriodEventWithId:@"VV6i4_7t4Jdd" onDate:nil requestType:PYRequestTypeSync successHandler:^(NSString *stoppedEventId) {
//                    
//                } errorHandler:^(NSError *error) {
//
//                }];
                
//                [channel getFoldersWithRequestType:PYRequestTypeAsync
//                                      filterParams:@{@"includeHidden": @"true", @"state" : @"all"}
//                                    successHandler:^(NSArray *folderList) {
//                                        
//                                        NSLog(@"folder list %@",folderList);
//                                    } errorHandler:^(NSError *error) {
//                                        NSLog(@"error is %@",error);
//                                    }];

                

            }
            
            


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
    
    NSArray *permissions = @[ @{ @"channelId": @"*", @"level": @"manage"}];
    
    [PryvClient setDefaultDomainStaging];
    [PryvWebLoginViewController requesAccessWithAppId:@"pryv-sdk-ios-example"
                                     andPermissions:permissions
                                           delegate:self];

}

#pragma mark --PYWebLoginDelegate

- (UIViewController *) pyWebLoginGetController {
    return self;
}

- (void) pyWebLoginSuccess:(PryvAccess*)pyAccess {
    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
}

- (void) pyWebLoginAborded:(NSString*)reason {
    NSLog(@"Signin Aborded: %@",reason);
}

#pragma mark -- 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
