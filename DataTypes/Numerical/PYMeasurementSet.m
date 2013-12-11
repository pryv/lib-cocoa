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

- (void)initMeasurementTypesWithTypesDic:(NSDictionary*)types andPYEventsTypes:(PYEventTypes*) pyTypes;

@end

@implementation PYMeasurementSet

@synthesize key = _key;
@synthesize localizedName = _localizedName;
@synthesize localizedDescription = _localizedDescription;
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
        [self initMeasurementTypesWithTypesDic:[dictionary objectForKey:@"types"] andPYEventsTypes:pyTypes];
    }
    return self;
}

- (void)initMeasurementTypesWithTypesDic:(NSDictionary *)types andPYEventsTypes:(PYEventTypes*) pyTypes
{
    
    for(NSString *classKey in [types allKeys])
    {
        PYEventTypesGroup *group = [[PYEventTypesGroup alloc]
                                    initWithClassKey:classKey
                                    andListOfTypes:[types objectForKey:classKey]
                                    andPYEventsTypes:pyTypes];
        [self.measurementGroups addObject:group];
    }
}

- (NSString*)localizedName
{
    return [PYUtilsLocalization fromDictionary:_names defaultValue:self.key];
}

- (NSString*)localizedDescription
{
    return [PYUtilsLocalization fromDictionary:_descriptions defaultValue:@"TODO add some default values there"];
}

@end
