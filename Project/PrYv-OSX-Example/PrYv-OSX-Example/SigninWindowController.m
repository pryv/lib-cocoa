//
//  SigninWindowController.m
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "SigninWindowController.h"
#import "PryvApiKit.h"
#import "PYWebLoginViewController.h"
#import "WebViewController.h"

@interface SigninWindowController ()

@end

@implementation SigninWindowController

@synthesize webViewController;

- (void)awakeFromNib{
    webViewController = [[WebViewController alloc] initWithNibName:nil bundle:nil];
    [[self window] setDelegate:webViewController];
}

@end
