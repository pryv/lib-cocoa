//
//  Created by Konstantin Dorodov on 1/7/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PYAttachment : NSObject
{
    NSData *_fileData;
    NSString *_name;
    NSString *_fileName;
    NSString *_mimeType;
    NSNumber *_size;

}

@property (nonatomic, retain) NSData *fileData;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, retain) NSNumber *size;


-(id)initWithFileData:(NSData *)fileData
                 name:(NSString *)name
             fileName:(NSString *)fileName;

+ (PYAttachment *)attachmentFromDictionary:(NSDictionary *)JSON;
- (NSDictionary *)cachingDictionary;
@end