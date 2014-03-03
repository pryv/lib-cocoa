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
#import "PYCachingController+Event.h"

@implementation PYEvent (Utils)

- (void)preview:(void (^) (PYImage *img))previewImage failure:(void(^) (NSError *error))failure {
    if (! self.connection) {
        if (failure) failure([NSError errorWithDomain:@"No connection" code:1000 userInfo:nil]);
        return;
    }
    [self.connection previewForEvent:self successHandler:^(NSData *filedata) {
        previewImage([self imageFromData:filedata]);
    } errorHandler:^(NSError *error) {
        // if event is a picture get the data from memoroy or cache
        if ([self.type isEqualToString:@"picture/attached"]) {
            if (self.attachments && self.attachments.count > 0) {
                PYAttachment* attachment = [self.attachments firstObject];
                if ((attachment.fileData != nil) && attachment.fileData.length > 0) { // memory
                    previewImage([self imageFromData:attachment.fileData]);
                    return;
                } else { // cache
                    NSData *cachedData = [self.connection.cache dataForAttachment:attachment onEvent:self];
                    if (cachedData && cachedData.length > 0) {
                         previewImage([self imageFromData:cachedData]);
                        return;
                    }
                }
            }
        }
        failure(error);
    }];
}


- (PYImage *) imageFromData:(NSData*)imageData {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
   return [[[NSImage alloc] initWithData:imageData] autorelease];
#else
    return [UIImage imageWithData:imageData];
#endif
}


/**
 * get attachment data
 * REVIEW and eventually move it from Utils to PYAttachment or directly in PYEvent
 **/
- (void)dataForAttachment:(PYAttachment *)attachment
           successHandler:(void (^) (NSData *data))success
             errorHandler:(void(^) (NSError *error))failure
{
    
    if ((attachment.fileData != nil) && attachment.fileData.length > 0) {
        success(attachment.fileData); // already loaded
        return;
    }
    if (self.connection) { // certainly a temporary event (not yet attached to a connection)
        [self.connection dataForAttachment:attachment
                                   onEvent:self
                               requestType:PYRequestTypeAsync
                            successHandler:success
                              errorHandler:failure];
    } else {
        if (failure) {
            failure([NSError errorWithDomain:@"No connection" code:1000 userInfo:nil]);
        }
    }
}

@end
