//
//  Created by Konstantin Dorodov on 1/7/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYEventAttachment.h"


@implementation PYEventAttachment

@synthesize fileData = _fileData;
@synthesize name = _name;
@synthesize fileName = _fileName;
@synthesize size = _size;
@synthesize mimeType = _mimeType;


- (id)initWithFileData:(NSData *)fileData
                  name:(NSString *)name
              fileName:(NSString *)fileName
              mimeType:(NSString *)mimeType
{
    if (self = [super init]) {
        _fileData = fileData;
        _name = name;
        _fileName = fileName;
        _mimeType = mimeType;
    }
    return self;
}

+ (PYEventAttachment *)attachmentFromDictionary:(NSDictionary *)JSON
{
    PYEventAttachment *attachment = [[PYEventAttachment alloc] init];
    attachment.fileName = [JSON objectForKey:@"fileName"];
    attachment.mimeType = [JSON objectForKey:@"type"];
    attachment.size = [JSON objectForKey:@"size"];
    
    return [attachment autorelease];
}

@end