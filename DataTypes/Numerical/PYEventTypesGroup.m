//
//  MeasurementGroup.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/26/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYEventTypesGroup.h"
#import "PYEventTypes.h"
#import "PYEventClass.h"

@interface PYEventTypesGroup ()

@end

@implementation PYEventTypesGroup

@synthesize classKey = _classKey;
@synthesize types = _types;

- (id)initWithClassKey:(NSString *)classKey andListOfTypes:(NSArray *)listOfTypes andPYEventsTypes:(PYEventTypes *) pyTypes
{
    self = [super init];
    if(self)
    {
        self.klass = [pyTypes pyClassForString:classKey];
        self.types = listOfTypes;
    }
    return self;
}

- (NSString*) name {
    NSLog(@"** WARNING PYEventTypesGroup.name should be removed ASAP");
    return self.classKey;
}

- (NSString*) classKey {
    return self.klass.classKey;
}

-(NSString*) localizedName {
    return self.klass.localizedName;
}

-(PYEventType *) pyTypeAtIndex:(int)index {
    NSString *type = [self.types objectAtIndex:index];
    NSString *key = [NSString stringWithFormat:@"%@/%@", self.classKey, type];
    PYEventType *pyType = [[PYEventTypes sharedInstance] pyTypeForString:key];
    return pyType;
}

@end
