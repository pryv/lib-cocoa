//
//  PryvAppDelegate.m
//  OSX example
//
//  Created by Nenad Jelic on 4/25/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvAppDelegate.h"
#import "PryvApiKit.h"

@implementation PryvAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    PYAccess *access = [PYClient createAccessWithUsername:@"perkikiki" andAccessToken:kPYUserTempToken];
    
    [access getChannelsWithRequestType:PYRequestTypeSync filterParams:nil successHandler:^(NSArray *channelList) {
        NSLog(@"channel list %@",channelList);
        
    }errorHandler:^(NSError *error) {
        
    }];

     
                
                                
//                [channel getFoldersWithRequestType:PYRequestTypeSync
//                                      filterParams:@{@"includeHidden": @"true", @"state" : @"all"}
//                                    successHandler:^(NSArray *folderList) {
//
//                                        NSLog(@"folder list %@",folderList);
//                                    } errorHandler:^(NSError *error) {
//                                        NSLog(@"error is %@",error);
//                                    }];
    
                
    
}


@end
