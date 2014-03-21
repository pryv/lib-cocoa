//
//  PYWebLoginViewController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
#import <Availability.h>
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#else
#import <UIKit/UIKit.h>
#endif
#import "PYConnection.h"

@class PYWebLoginViewController;

@protocol PYWebLoginDelegate
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
//- (void) pyWebLoginNotVisible:(NSNotification *)notification;
#else
- (UIViewController *)pyWebLoginGetController;
#endif
- (void)pyWebLoginSuccess:(PYConnection *)pyConnection;
- (void)pyWebLoginAborted:(NSString *)reason;
- (void)pyWebLoginError:(NSError *)error;
@end


#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@interface PYWebLoginViewController : NSViewController {
#else
@interface PYWebLoginViewController : UIViewController {
#endif
    @private
    NSArray *permissions;
    NSString *appID;
    NSTimer *pollTimer;
    NSString *pollURL;
    id  delegate;
    #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    WebView *webView;
    #endif
}

    


+ (PYWebLoginViewController *)requestConnectionWithAppId:(NSString *)appID
                                          andPermissions:(NSArray *)permissions
                                                delegate:(id )delegate
                                #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
                                             withWebView:(WebView **)webView
                                #endif
                                            ;
- (void)timerBlock:(NSTimer*)timer;

@end