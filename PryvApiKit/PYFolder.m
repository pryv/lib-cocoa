//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYFolder.h"


@implementation PYFolder

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