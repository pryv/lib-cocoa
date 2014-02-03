//
//  PYMeasurementSet.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYEventTypesGroup.h"

@interface PYMeasurementSet : NSObject
{
    NSString *_key;
    NSMutableArray *_measurementGroups;
    
    @private
    NSDictionary *_names;
    NSDictionary *_descriptions;
}

- (id)initWithKey:(NSString*)key andDictionary:(NSDictionary*)dictionary andPYEventsTypes:(PYEventTypes*) pyTypes;

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
//Private variables
@property (nonatomic, copy) NSDictionary *names;
@property (nonatomic, copy) NSDictionary *descriptions;

- (NSString *)localizedName;
- (NSString *)localizedDescription;
@end
