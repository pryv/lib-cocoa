//
//  AppDelegate.m
//  OS X example
//
//  Created by Nenad Jelic on 4/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeWindowController.h"
#import "User.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"


@implementation AppDelegate

@synthesize user = _user;

- (void)dealloc
{
    [welcomeWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL staging = YES;
    if (staging) {
        self = [AppDelegate sharedInstance];
        self.user = [[User alloc] initWithUsername:@"perkikiki" andToken:@"Ve-U8SCASM"];
        NSLog(@"User %@ (%@) manually connected for staging.",_user.username,self.user.token);
    }
    welcomeWindowController = [[WelcomeWindowController alloc]
                               initWithWindowNibName:@"WelcomeWindowController"];
    [welcomeWindowController showWindow:self];
    
}

//Enables singleton using Grand Central
+ (AppDelegate*)sharedInstance {
	static dispatch_once_t pred;
	static AppDelegate *sharedInstance = nil;
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}



@end