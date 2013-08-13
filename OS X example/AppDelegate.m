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


@implementation AppDelegate

@synthesize user = _user;

- (void)dealloc
{
    [welcomeWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
