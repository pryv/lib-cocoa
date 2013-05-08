//
//  PYWebLoginViewController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PryvAccess.h"

@class PryvWebLoginViewController;

@protocol PYWebLoginDelegate
- (UIViewController*) pyWebLoginGetController;
- (void) pyWebLoginSuccess:(PryvAccess*)pyAccess;
- (void) pyWebLoginAborded:(NSString*)reason;
@end


@interface PryvWebLoginViewController : UIViewController {
    
}


@property (nonatomic, assign) id  delegate;

+ (PryvWebLoginViewController *)requesAccessWithAppId:(NSString *)appID andPermissions:(NSArray *)permissions delegate:(id ) delegate;

@end

