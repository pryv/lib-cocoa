//
//  PYWebLoginViewController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAccess.h"

@class PYWebLoginViewController;

@protocol PYWebLoginDelegate
- (UIViewController*) pyWebLoginGetController;
- (void) pyWebLoginSuccess:(PYAccess*)pyAccess;
- (void) pyWebLoginAborded:(NSString*)reason;
@end


@interface PYWebLoginViewController : UIViewController {
    
}


@property (nonatomic, assign) id  delegate;

+ (PYWebLoginViewController *)requesAccessWithAppId:(NSString *)appID andPermissions:(NSArray *)permissions delegate:(id ) delegate;

@end

