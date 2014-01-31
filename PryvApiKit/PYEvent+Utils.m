//
//  PYEvent+Utils.m
//  PryvApiKit
//
//  Created by Perki on 29.01.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYEvent+Utils.h"
#import "PYConnection+DataManagement.h"
#import "PYAttachment.h"

@implementation PYEvent (Utils)

- (void)preview:(void (^) (PYImage *img))previewImage failure:(void(^) (NSError *error))failure {
    if (! self.connection) {
        if (failure) failure([NSError errorWithDomain:@"No connection" code:1000 userInfo:nil]);
        return;
    }
    [self.connection previewForEvent:self successHandler:^(NSData *filedata) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
        previewImage([[[NSImage alloc] initWithData:filedata] autorelease]);
#else
        previewImage([UIImage imageWithData:filedata]);
#endif
    } errorHandler:failure];
}

/**
 * get attachment data
 * REVIEW and eventually move it from Utils to PYAttachment or directly in PYEvent
 **/
- (void)dataForAttachment:(PYAttachment*)attachment successHandler:(void (^) (NSData *data))success errorHandler:(void(^) (NSError *error))failure {
    if (! self.connection) {
        if (failure) failure([NSError errorWithDomain:@"No connection" code:1000 userInfo:nil]);
        return;
    }
    if (attachment.fileData && attachment.fileData.length > 0) {
        success(attachment.fileData); // already loaded
        return;
    }
    [self.connection attachmentDataForEvent:self
                               withFileName:attachment.fileName
                                requestType:PYRequestTypeAsync
                             successHandler:success
                               errorHandler:failure];
}

@end
