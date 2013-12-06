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
#import "PYUtilsLocalization.h"

@interface PYMeasurementSet ()

- (void)initMeasurementTypesWithTypesDic:(NSDictionary*)types;

@end

@implementation PYMeasurementSet

@synthesize key = _key;
@synthesize localizedName = _localizedName;
@synthesize localizedDescription = _localizedDescription;
@synthesize measurementGroups = _measurementGroups;
@synthesize names = _names;
@synthesize descriptions = _descriptions;

- (id)initWithKey:(NSString *)key andDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.key = key;
        self.names = [dictionary objectForKey:@"name"];
        self.descriptions = [dictionary objectForKey:@"description"];
        self.measurementGroups = [NSMutableArray array];
        [self initMeasurementTypesWithTypesDic:[dictionary objectForKey:@"types"]];
    }
    return self;
}

- (void)initMeasurementTypesWithTypesDic:(NSDictionary *)types
{
    for(NSString *groupName in [types allKeys])
    {
        PYMeasurementGroup *group = [[PYMeasurementGroup alloc] initWithName:groupName andListOfTypes:[types objectForKey:groupName]];
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
