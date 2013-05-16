//
//  AppDelegate.m
//  OS X example
//
//  Created by Nenad Jelic on 4/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "AppDelegate.h"
#import "PryvApiKit.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
//    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
//    
//    [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
//        NSLog(@"channel list %@",channelList);
//        
//    }errorHandler:^(NSError *error) {
//        
//    }];
    
    [PYClient setDefaultDomainStaging];
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    NSLog(@"isOnline %d",access.isOnline);
    NSLog(@"log");
    
    
    [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
        
        for (PYChannel *channel in channelList) {
            
            
            if ([channel.channelId isEqualToString:@"position"]) {
                
                [channel getAllEventsWithRequestType:PYRequestTypeSync successHandler:^(NSArray *eventList) {
                    
                    NSLog(@"eventList is %@",eventList);
                } errorHandler:^(NSError *error) {
                    NSLog(@"get all events error is %@",error);
                }];
                
                PYEvent *event = [[PYEvent alloc] init];
                event.tags = @[@"tagSync",@"tag2Sync"];
                event.value = @"test general value";
                event.type = @{@"class": @"note", @"format" : @"txt"};
                
                NSString *imgName = @"Default";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"png"];
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                
                PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData
                                                                      name:imgName
                                                                  fileName:@"Default.png"];
                [event addAttachment:att];
                
                
                [channel createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"success %@", newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"error %@",error);
                    NSMutableURLRequest *request = [error.userInfo objectForKey:PryvRequestKey];
                    NSLog(@"request.bodyLength %ld",request.HTTPBody.length);
                }];
                
                [channel createEvent:event requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"success %@", newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"error %@",error);
                    NSMutableURLRequest *request = [error.userInfo objectForKey:PryvRequestKey];
                    NSLog(@"request.bodyLength %ld",(unsigned long)request.HTTPBody.length);
                }];
                
                
                
            }
            
            
            
            
        }
        
        
    } errorHandler:^(NSError *error) {
        
    }];

    

}

@end
