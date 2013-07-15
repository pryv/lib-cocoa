//
//  WebViewController.h
//  PryvApiKit
//
//  Created by Victor Kristof on 09.07.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebViewController : NSViewController <NSWindowDelegate> {
    WebView *webView;
}

@property (assign) IBOutlet WebView *webView;

@end
