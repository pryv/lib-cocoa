//
//  Created by Konstantin Dorodov on 1/7/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PYAttachment : NSObject
{
    NSString *_attachmentId;
    NSString *_name;
    NSString *_fileName;
    NSString *_mimeType;
    NSNumber *_size;
    NSData *_fileData;
}

@property (nonatomic, copy) NSString *attachmentId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, retain) NSNumber *size;
@property (nonatomic, retain) NSData *fileData;

/**
 Designated initializer for PYAttachment
 @param fileData - NSData object of attachment file
 @param name - Attachment name
 @param fileName - File name of attachment
 */
-(id)initWithFileData:(NSData *)fileData
                 name:(NSString *)name
             fileName:(NSString *)fileName;

/**
 Get PYAttachment object from server
 */
+ (PYAttachment *)attachmentFromDictionary:(NSDictionary *)JSON;
/**
 JSON-like attachment presentation for caching on disk
 */
- (NSDictionary *)cachingDictionary;


@end