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

@interface PYEViewController () <PYWebLoginDelegate>

@end

@implementation PYEViewController 

@synthesize signinButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [PYClient setDefaultDomainStaging];
    
//    NSLog(@"events from cache %@",[PYEventsCachingUtillity getEventsFromCache]);
    
//    PYEvent *event = [PYEventsCachingUtillity getEventFromCacheWithEventId:@"eeKNFIBOnJ" isUnsync:NO];
//    NSLog(@"event for key is %@",event);
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    NSLog(@"isOnline %d",access.isOnline);
    NSLog(@"log");
    
    [access getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList) {
        
        for (PYChannel *channel in channelList) {
        
            if ([channel.channelId isEqualToString:@"position"]) {
            
                [channel getAllEventsWithRequestType:PYRequestTypeSync successHandler:^(NSArray *eventList) {
                    NSLog(@"eventList is %@",eventList);
                } errorHandler:^(NSError *error) {
                    NSLog(@"get all events error is %@",error);
                }];
                
//                PYEvent *event = [[PYEvent alloc] init];
//                event.tags = @[@"tagclass",@"tagformat"];
//                event.value = @"test general value";
//                event.eventClass = @"note";
//                event.eventFormat = @"txt";
//                event.tags = @[@"tag1", @"tag2", @"ttag", @"ttart"];
//                [channel createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
//                    NSLog(@"success %@", newEventId);
//                } errorHandler:^(NSError *error) {
//                    NSLog(@"error %@",error);
////                    NSMutableURLRequest *request = [error.userInfo objectForKey:PryvRequestKey];
//                    //                    NSLog(@"request.bodyLength %d",request.HTTPBody.length);
//                }];
                
                NSDate *today = [NSDate date];
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                //get 2 days before yesterday
//                [components setDay:-1];
                [components setHour:-1];
                NSDate *fromTime = [cal dateByAddingComponents:components toDate:today options:0];
                NSDate *toTime = today;

                PYEventFilter *eventFilter = [[PYEventFilter alloc] initWithChannel:channel
                                                                           fromTime:[fromTime timeIntervalSince1970]
                                                                             toTime:[toTime timeIntervalSince1970]
                                                                              limit:10
                                                                     onlyFoldersIDs:nil
                                                                               tags:@[@"tag1, tag2", @"ytar"]];
                
                [eventFilter getEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *eventList) {
                    NSLog(@"cached eventList %@",eventList);
                } gotOnlineEvents:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
                    NSLog(@"eventsToAdd %@",eventsToAdd);
                    NSLog(@"eventsToRemove %@",eventsToRemove);
                    NSLog(@"eventModified %@",eventModified);
                } errorHandler:^(NSError *error) {
                    NSLog(@"error is %@",error);
                }];
                
//
//
//                NSString *imgName = @"Default";
//                NSString *filePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
//                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
//                
//                PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData
//                                                                      name:imgName
//                                                                  fileName:@"Default.png"];
//                [event addAttachment:att];
//
//                
                
//                [channel createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
//                    NSLog(@"success %@", newEventId);
//                } errorHandler:^(NSError *error) {
//                    NSLog(@"error %@",error);
//                    NSMutableURLRequest *request = [error.userInfo objectForKey:PryvRequestKey];
//                    NSLog(@"request.bodyLength %d",request.HTTPBody.length);
//                }];

                
                
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
        NSLog(@"getChannels error %@",error);
//        NSLog(@"isOnline %d",access.isOnline);

    }];
    
    PYAccess *access2 = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:@"PeySaPzMsM"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [access2 getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
            for (PYChannel *pyChannel in channelList)
            {
                NSLog(@"channel: %@",pyChannel.name);
            }
        } errorHandler:^(NSError *error) {
            NSLog(@"error: %@",error);
        }];
    });
    
//    PYAccess *access2 = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:@"Ve69mGqqX5"];
//    [access2 getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList) {
//        
//        for (PYChannel *channel in channelList) {            
//            if ([channel.channelId isEqualToString:@"position"]) {
//                
//                
//            }
//        }
//        
//        
//    } errorHandler:^(NSError *error) {
//        
//        NSLog(@"error is %@",error);
//    }];
    
    
    
    [access batchSyncEventsWithoutAttachment];
}

- (IBAction)siginButtonPressed: (id) sender  {
    NSLog(@"Signin Started");
    
    NSArray *permissions = @[ @{ @"channelId": @"*", @"level": @"manage"}];
    
    [PYClient setDefaultDomainStaging];
    [PYWebLoginViewController requesAccessWithAppId:@"pryv-sdk-ios-example"
                                     andPermissions:permissions
                                           delegate:self];

}

#pragma mark --PYWebLoginDelegate

- (UIViewController *) pyWebLoginGetController {
    return self;
}

- (void) pyWebLoginSuccess:(PYAccess*)pyAccess {
    NSLog(@"Signin With Success %@ %@",pyAccess.userID,pyAccess.accessToken);
    [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
}
- (void) pyWebLoginAborded:(NSString*)reason {
    NSLog(@"Signin Aborded: %@",reason);
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

@end
