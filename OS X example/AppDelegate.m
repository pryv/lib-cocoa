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
    
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    [access getChannelsWithRequestType:PYRequestTypeAsync filterParams:nil successHandler:^(NSArray *channelList) {
        
        for (PYChannel *channel in channelList) {
            
            
            if ([channel.channelId isEqualToString:@"position"]) {
                
                [channel getAllEventsWithRequestType:PYRequestTypeAsync successHandler:^(NSArray *eventList) {
                    
                    
                } errorHandler:^(NSError *error) {
                    NSLog(@"get all events error is %@",error);
                }];
                
                PYEventType *eventType = [[PYEventType alloc] initWithClass:PYEventClassNote andFormat:PYEventFormatTxt];
                NSString *noteTextValue = @"OS X";
                PYEventNote *noteEvent = [[PYEventNote alloc] initWithType:eventType
                                                                 noteValue:noteTextValue
                                                                  folderId:nil
                                                                      tags:nil
                                                               description:nil
                                                                clientData:nil];
                NSString *imgName = @"image003";
                NSString *filePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"jpg"];
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                
                PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData
                                                                      name:imgName
                                                                  fileName:@"image003.jpg"];
                [noteEvent addAttachment:att];
                
                
                NSString *pdfName = @"Pryv_ecosystem";
                NSString *pdfPath = [[NSBundle mainBundle] pathForResource:pdfName ofType:@"pdf"];
                NSData *pdfData = [NSData dataWithContentsOfFile:pdfPath];
                
                PYAttachment *att1 = [[PYAttachment alloc] initWithFileData:pdfData
                                                                       name:pdfName
                                                                   fileName:@"Pryv_ecosystem.pdf"];
                [noteEvent addAttachment:att1];
                
                
                [channel createEvent:noteEvent requestType:PYRequestTypeSync successHandler:^(NSString *newEventId, NSString *stoppedId) {
                    NSLog(@"success %@", newEventId);
                } errorHandler:^(NSError *error) {
                    NSLog(@"error %@",error);
                }];
                
                
            }
            
            
            
            
        }
        
        
    } errorHandler:^(NSError *error) {
        
    }];

    

}

@end
