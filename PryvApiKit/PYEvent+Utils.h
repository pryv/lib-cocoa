//
//  PYEvent+Utils.h
//  PryvApiKit
//
//  Created by Perki on 29.01.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYEvent.h"
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
#import <Cocoa/Cocoa.h>
#define PYImage NSImage
#else
#import <UIKit/UIKit.h>
#define PYImage UIImage
#endif





@interface PYEvent (Utils)

/** get a preview image (if available) **/
- (void)preview:(void (^) (PYImage *img))previewImage failure:(void(^) (NSError *error))failure;



@end
