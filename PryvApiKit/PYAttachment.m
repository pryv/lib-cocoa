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
        _fileData = fileData;
        _name = name;
        _fileName = fileName;
    }
    return self;
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
    NSArray *objects;
    NSArray *keys;
    if (self.fileData) {
        objects = [NSArray arrayWithObjects:self.fileName, self.mimeType, self.size, self.fileData, nil];
        keys = [NSArray arrayWithObjects:@"fileName",@"type",@"size", @"attachmentData", nil];
    }else{
        objects = [NSArray arrayWithObjects:self.fileName, self.mimeType, self.size, nil];
        keys = [NSArray arrayWithObjects:@"fileName",@"type",@"size", nil];
    }
    
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