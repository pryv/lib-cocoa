//
//  WelcomeWindowWindowController.h
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SigninWindowController;

@interface WelcomeWindowController : NSWindowController {
    @private
    NSButton *signinButton;
    SigninWindowController *signinWindowController;
}

@property (assign) IBOutlet NSButton *signinButton;
- (IBAction)signinButtonPressed:(id)sender;
- (IBAction)getStreams:(id)sender;
- (IBAction)createTestStream:(id)sender;
- (IBAction)trashTestStream:(id)sender;

@end
