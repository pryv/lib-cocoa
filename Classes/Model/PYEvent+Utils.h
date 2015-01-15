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

/** get preview From cache exclusively **/
- (UIImage* )previewFromCache;


/** get a preview image (if available) **/
- (void)preview:(void (^) (PYImage *img))previewImage failure:(void(^) (NSError *error))failure;

/** portable utility to get an image from data **/
- (PYImage *) imageFromData:(NSData*)imageData;

/** 
 * Get attachment data
 * REVIEW and eventually move it from Utils to PYAttachment or directly in PYEvent
 **/
- (void)dataForAttachment:(PYAttachment *)attachment
           successHandler:(void (^)(NSData *data))attachmentData
             errorHandler:(void(^)(NSError *error))failure;

@end
