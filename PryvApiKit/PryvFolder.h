//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PryvFolder : NSObject
{
    NSString *_folderId;
    NSString *_channelId;
    NSString *_name;
    NSString *_parentId;
    NSDictionary *_clientData;
    NSTimeInterval _timeCount;
    NSArray *_children;
    BOOL _hidden;
    BOOL _trashed;


}

@property (nonatomic, copy) NSString *folderId;
@property (nonatomic, copy, readonly) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic) NSTimeInterval timeCount;

//@children -> array of PYFolder objects
@property (nonatomic, retain) NSArray *children;

@property (nonatomic, assign, getter = isHidden) BOOL hidden;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

@end