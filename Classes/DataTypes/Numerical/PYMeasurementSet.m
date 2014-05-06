//
//  MeasurementSet.m
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYMeasurementSet.h"

#import "PYConstants.h"
#import "PYClient.h"
#import "PYEventTypes.h"
#import "PYUtilsLocalization.h"

@interface PYMeasurementSet ()

- (void)setupMeasurementTypesWithTypesDic:(NSDictionary*)types andPYEventsTypes:(PYEventTypes*) pyTypes;

@end

@implementation PYMeasurementSet

@synthesize key = _key;
@synthesize measurementGroups = _measurementGroups;
@synthesize names = _names;
@synthesize descriptions = _descriptions;

- (id)initWithKey:(NSString *)key andDictionary:(NSDictionary *)dictionary andPYEventsTypes:(PYEventTypes*) pyTypes;
{
    self = [super init];
    if(self)
    {
        self.key = key;
        self.names = [dictionary objectForKey:@"name"];
        self.descriptions = [dictionary objectForKey:@"description"];
        self.measurementGroups = [NSMutableArray array];
        [self setupMeasurementTypesWithTypesDic:[dictionary objectForKey:@"types"] andPYEventsTypes:pyTypes];
    }
    return self;
}

- (void)setupMeasurementTypesWithTypesDic:(NSDictionary *)types andPYEventsTypes:(PYEventTypes*) pyTypes
{
    
    for(NSString *classKey in [types allKeys])
    {
        PYMeasurementTypesGroup *group = [[PYMeasurementTypesGroup alloc]
                                    initWithClassKey:classKey
                                    andListOfFormats:[types objectForKey:classKey]
                                    andPYEventsTypes:pyTypes];
        [self.measurementGroups addObject:group];
        [group release];
    }
}

- (void)dealloc
{
    [_names release];
    [_descriptions release];
    [_key release];
    [_measurementGroups release];

    [super dealloc];
}

- (NSString *)localizedName
{
    return [PYUtilsLocalization fromDictionary:_names defaultValue:self.key];
}

- (NSString *)localizedDescription
{
    
    return [PYUtilsLocalization fromDictionary:_descriptions defaultValue:@""];
}

@end
