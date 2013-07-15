//
//  SigninWindowController.h
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebViewController;

@interface SigninWindowController : NSWindowController {
    @private
    WebViewController *webViewController;
    }

@property (assign) IBOutlet WebViewController *webViewController;

@end
