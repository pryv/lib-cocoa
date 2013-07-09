//
//  AppDelegate.m
//  OS X example
//
//  Created by Nenad Jelic on 4/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeWindowController.h"


@implementation AppDelegate


- (void)dealloc
{
    [welcomeWindowController release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    welcomeWindowController = [[WelcomeWindowController alloc] initWithWindowNibName:@"WelcomeWindowController"];
    [welcomeWindowController showWindow:self];
    
}


@end
