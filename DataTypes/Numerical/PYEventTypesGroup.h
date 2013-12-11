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
}


@property (nonatomic, strong) PYEventClass *klass;
@property (nonatomic, strong) NSMutableArray *types;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *classKey;
@property (nonatomic, readonly) NSString *localizedName;


- (id)initWithClassKey:(NSString*)classKey
        andListOfTypes:(NSArray*)listOfTypes
      andPYEventsTypes:(PYEventTypes*) pyTypes;

- (PYEventType*) pyTypeAtIndex:(int)index;



@end
