//
//  WelcomeWindowWindowController.h
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SigninWindowController,PYEvent;

@interface WelcomeWindowController : NSWindowController {
    @private
    NSButton *signinButton;
    IBOutlet NSTextField *eventID;
    SigninWindowController *signinWindowController;
    PYEvent *event;
    PYEvent *runningEvent;
    NSMutableArray *streams;
}

@property (assign) IBOutlet NSButton *signinButton;
@property (assign) PYEvent *event;
@property (assign) PYEvent *runningEvent;
- (IBAction)signinButtonPressed:(id)sender;
- (IBAction)getStreams:(id)sender;
- (IBAction)createTestStream:(id)sender;
- (IBAction)trashTestStream:(id)sender;
- (IBAction)createTestEvent:(id)sender;
- (IBAction)deleteTestEvent:(id)sender;
- (IBAction)getEvents:(id)sender;
- (IBAction)deleteEvent:(id)sender;
- (IBAction)startRunningEvent:(id)sender;
- (IBAction)stopRunningEvent:(id)sender;
- (IBAction)getRunningEvent:(id)sender;

@end
