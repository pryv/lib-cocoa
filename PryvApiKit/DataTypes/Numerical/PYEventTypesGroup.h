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
    NSString *_classKey;
    NSMutableArray *_formatKeys;
}


@property (nonatomic, strong) PYEventClass *klass;
@property (nonatomic, strong) NSMutableArray *formatKeys;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *classKey;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSArray *formatKeyList;


- (id)initWithClassKey:(NSString*)classKey
        andListOfFormats:(NSArray*)listOfFormat
      andPYEventsTypes:(PYEventTypes*) pyTypes;

- (PYEventType*) pyTypeAtIndex:(int)index;

- (void) addFormat:(NSString*)formatKey withClassKey:(NSString*)classKey;

- (void) addFormats:(NSArray*)formatKeyList withClassKey:(NSString*)classKey;

- (void) sortUsingComparator:(NSComparator)cmptr;

- (void) sortUsingLocalizedName;
@end
