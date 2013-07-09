//
//  AppDelegate.h
//  OS X example
//
//  Created by Nenad Jelic on 4/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    WebView *webView;
}


@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@end
