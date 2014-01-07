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
@synthesize formatKeys = _formatKeys;
@synthesize klass = _klass;

- (id)initWithClassKey:(NSString *)classKey andListOfFormats:(NSArray *)listOfFormats andPYEventsTypes:(PYEventTypes *) pyTypes
{
  
    self = [super init];
    if(self)
    {
        if (! pyTypes) {
            pyTypes = [PYEventTypes sharedInstance];
        }
        self.klass = [pyTypes pyClassForString:classKey];
    
        self.formatKeys = [[NSMutableArray alloc] init];
        [self addFormats:listOfFormats withClassKey:classKey];
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
    NSString *formatKey = [self.formatKeys objectAtIndex:index];
    NSString *key = [NSString stringWithFormat:@"%@/%@", self.classKey, formatKey];
    PYEventType *pyType = [[PYEventTypes sharedInstance] pyTypeForString:key];
    return pyType;
}

- (void) addFormat:(NSString*)formatKey withClassKey:(NSString*)classKey {
    if (! [self.classKey isEqualToString:classKey]) {
        NSLog(@"<warning>: Tried to add formats of the wrong class %@ into a group %@", classKey, self.classKey);
        return;
    }
    for (int k = 0; k < self.formatKeys.count ; k++) {
        if ([(NSString*)[self.formatKeys objectAtIndex:k] isEqualToString:formatKey]) {
            return; // found
        }
    }
    
    [self.formatKeys addObject:formatKey];
}

- (void) addFormats:(NSArray*)formatKeyList withClassKey:(NSString*)classKey {
    if (! [self.classKey isEqualToString:classKey]) {
        NSLog(@"<warning>: Tried to add formats of the wrong class %@ into a group %@", classKey, self.classKey);
        return;
    }
    for (int j = 0; j < formatKeyList.count ; j++) {
        [self addFormat:(NSString*)[formatKeyList objectAtIndex:j] withClassKey:classKey] ;
    }
}

- (NSArray*) formatKeyList {
    return [NSArray arrayWithArray:self.formatKeys];
}

- (void) sortUsingComparator:(NSComparator)cmptr {
    [_formatKeys sortUsingComparator:cmptr];
}

- (void) sortUsingLocalizedName {
    [self sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *aKey = [NSString stringWithFormat:@"%@/%@", self.classKey, (NSString*)a];
        NSString *bKey = [NSString stringWithFormat:@"%@/%@", self.classKey, (NSString*)b];
        PYEventType *aPyType = [[PYEventTypes sharedInstance] pyTypeForString:aKey];
        PYEventType *bPyType = [[PYEventTypes sharedInstance] pyTypeForString:bKey];
        return [aPyType.localizedName caseInsensitiveCompare:bPyType.localizedName];
    }];
}

@end
