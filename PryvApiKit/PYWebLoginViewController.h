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
#import "PYAccess.h"

@class PYWebLoginViewController;

@protocol PYWebLoginDelegate
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
- (NSViewController*) pyWebLoginGetController;
#else
- (UIViewController*) pyWebLoginGetController;
#endif
- (void) pyWebLoginSuccess:(PYAccess*)pyAccess;
- (void) pyWebLoginAborded:(NSString*)reason;
- (void) pyWebLoginError:(NSError*)error;
@end


#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@interface PYWebLoginViewController : NSViewController {
#else
@interface PYWebLoginViewController : UIViewController {
#endif
}


@property (nonatomic, assign) id  delegate;

+ (PYWebLoginViewController *)requestAccessWithAppId:(NSString *)appID
                                      andPermissions:(NSArray *)permissions
                                            delegate:(id ) delegate
                                #if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
                                           withFrame:(NSRect)frameRect
                                           frameName:(NSString *)frameName
                                           groupName:(NSString *)groupName
                                #endif
                                            ;

@end