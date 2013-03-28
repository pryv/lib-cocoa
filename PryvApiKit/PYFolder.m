//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYFolder.h"


@implementation PYFolder

@synthesize folderId = _folderId;
@synthesize channelId = _channelId;
@synthesize name = _name;
@synthesize parentId = _parentId;
@synthesize clientData = _clientData;
@synthesize timeCount = _timeCount;
@synthesize children = _children;
@synthesize hidden = _hidden;
@synthesize trashed = _trashed;


- (void)dealloc
{
    [_folderId release];
    [_channelId release];
    [_name release];
    [_parentId release];
    [_clientData release];
    [super dealloc];
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.id=%@", self.folderId];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.parentId=%@", self.parentId];
    [description appendFormat:@", self.hidden=%d", self.hidden];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendString:@">"];
    return description;
}

@end