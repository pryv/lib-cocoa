//
//  PYEventTypesGroup.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYEventClass.h"
#import "PYEventType.h"
#import "PYEventTypes.h"

@interface PYEventTypesGroup : NSObject
{
    PYEventClass *_klass;
    NSMutableArray *_types;
    NSMutableArray *_formatKeys;
}


@property (nonatomic, strong) PYEventClass *klass;
@property (nonatomic, strong) NSMutableArray *formatKeys;

- (id)initWithClassKey:(NSString *)classKey
      andListOfFormats:(NSArray *)listOfFormat
      andPYEventsTypes:(PYEventTypes*)pyTypes;

- (NSString *)name;

- (NSString *)classKey;

- (NSString *)localizedName;

- (NSArray *)formatKeyList;

- (PYEventType *)pyTypeAtIndex:(int)index;

- (void)addFormat:(NSString *)formatKey withClassKey:(NSString *)classKey;

- (void)addFormats:(NSArray *)formatKeyList withClassKey:(NSString *)classKey;

- (void)sortUsingComparator:(NSComparator)cmptr;

- (void)sortUsingLocalizedName;
@end
