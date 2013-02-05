//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PYFolder : NSObject {
@private
    NSString *_id;
    NSString *_name;
    NSString *_parentId;
    BOOL _hidden;
    BOOL _trashed;
}

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, assign, getter = isHidden) BOOL hidden;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

@end