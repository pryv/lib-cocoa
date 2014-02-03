//
//  Created by Konstantin Dorodov on 1/7/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//

#import "PYAttachment.h"

@implementation PYAttachment

@synthesize fileData = _fileData;
@synthesize name = _name;
@synthesize fileName = _fileName;
@synthesize size = _size;
@synthesize mimeType = _mimeType;


- (id)initWithFileData:(NSData *)fileData
                  name:(NSString *)name
              fileName:(NSString *)fileName
{
    if (self = [super init]) {
        self.fileData = fileData;
        self.name = name;
        self.fileName = fileName;
    }
    return self;
}

- (void)dealloc
{
    [_fileData release];
    [_name release];
    [_fileName release];
    [_size release];
    [_mimeType release];

    _fileData = nil;
    _name = nil;
    _fileName = nil;
    _size = nil;
    _mimeType = nil;
    [super dealloc];
}

+ (PYAttachment *)attachmentFromDictionary:(NSDictionary *)JSON
{
    PYAttachment *attachment = [[PYAttachment alloc] init];
    attachment.fileName = [JSON objectForKey:@"fileName"];
    attachment.mimeType = [JSON objectForKey:@"type"];
    attachment.size = [JSON objectForKey:@"size"];
    
    
    return [attachment autorelease];
}

- (NSDictionary *)cachingDictionary
{
    //"attachmentData" key won't be ever available when we read attachment from cache
    NSMutableArray *objects = [NSMutableArray array];
    NSMutableArray *keys = [NSMutableArray array];
    if(self.fileName)
    {
        [objects addObject:self.fileName];
        [keys addObject:@"fileName"];
    }
    if(self.mimeType)
    {
        [objects addObject:self.mimeType];
        [keys addObject:@"type"];
    }
    if(self.size)
    {
        [objects addObject:self.size];
        [keys addObject:@"size"];
    }
    // fileData is saved asside by caching utilities
    /**
    if(self.fileData)
    {
        [objects addObject:self.fileData];
        [keys addObject:@"attachmentData"];
    }**/
    
    NSDictionary *attachmentObject = [NSDictionary dictionaryWithObjects: objects
                                                                 forKeys: keys];
    return attachmentObject;
    
}

-(NSString *)description{
    NSMutableString *description = [NSMutableString stringWithString:@"<"];
    [description appendFormat:@"%@",_fileName];
    if (_size) {
        [description appendFormat:@" (%@ bytes)",_size];
    }if (_name) {
        [description appendFormat:@" - %@",_name];
    }
    if (_mimeType) {
        [description appendFormat:@" - %@",_mimeType];
    }
    [description appendString:@">"];
    return description;
}

@end