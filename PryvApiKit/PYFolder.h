//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PYFolder : NSObject

@property (nonatomic, copy) NSString *folderId;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, assign, getter = isHidden) BOOL hidden;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

@end