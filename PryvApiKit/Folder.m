//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "Folder.h"


@implementation Folder {
}

@synthesize id = _id;
@synthesize name = _name;
@synthesize parentId = _parentId;
@synthesize hidden = _hidden;
@synthesize trashed = _trashed;

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.id=%@", self.id];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.parentId=%@", self.parentId];
    [description appendFormat:@", self.hidden=%d", self.hidden];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendString:@">"];
    return description;
}

@end