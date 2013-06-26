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
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    NSLog(@"isOnline %d",access.isOnline);
    NSLog(@"log");
    
//    PYEvent *event = [PYEventsCachingUtillity getEventFromCacheWithEventId:@"eT3iGs4W05"];
    
    [access getAllChannelsWithRequestType:PYRequestTypeSync
                        gotCachedChannels:^(NSArray *cachedChannelList) {
        NSLog(@"cachedChannelList %@",cachedChannelList);
        
        for (PYChannel *channel in cachedChannelList) {
            //Nenad_test channel
            if ([channel.channelId isEqualToString:@"TVKoK036of"]) {
                
//                [channel getAllEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *cachedEventList) {
//                    
//                } gotOnlineEvents:^(NSArray *onlineEventList) {
//                    
//                } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];

//                PYEvent *event = [[PYEvent alloc] init];
//                event.value = @"attachment value1";
//                event.eventFormat = @"txt";
//                event.eventClass = @"note";
//                NSString *imageDataPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
//                NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
//                PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Default123" fileName:@"SomeFileName123"];
//                [event addAttachment:att];
//                
//                
//                [channel createEvent:event
//                         requestType:PYRequestTypeSync
//                      successHandler:^(NSString *newEventId, NSString *stoppedId) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];
            }
        }
    
    
            
    } gotOnlineChannels:^(NSArray *onlineChannelList) {
        

        for (PYChannel *channel in onlineChannelList) {
            
            //Nenad_test channel
            if ([channel.channelId isEqualToString:@"TVKoK036of"]) {
                
//                PYEvent *event = [[PYEvent alloc] init];
//                event.value = @"attachment value1";
//                event.eventFormat = @"txt";
//                event.eventClass = @"note";
//                NSString *imageDataPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
//                NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
//                PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Default" fileName:@"SomeFileName"];
//                [event addAttachment:att];
                
                
//                [channel createEvent:event
//                         requestType:PYRequestTypeSync
//                      successHandler:^(NSString *newEventId, NSString *stoppedId) {
//                          
//                      } errorHandler:^(NSError *error) {
//                          
//                      }];

//                [channel getAllEventsWithRequestType:PYRequestTypeSync gotCachedEvents:^(NSArray *cachedEventList) {
//                    
//                } gotOnlineEvents:^(NSArray *onlineEventList) {
//                    
//                } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
//                    
//                } errorHandler:^(NSError *error) {
//                    
//                }];

            }
        }
        
    } errorHandler:^(NSError *error) {
        NSLog(@"isOnline %d",access.isOnline);
    }];
    
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
