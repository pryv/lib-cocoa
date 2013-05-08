//
//  PryvType.m
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/5/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


#import "PYEventType.h"

@interface PYEventType ()

@end


@implementation PYEventType

@synthesize eventClass = _eventClass;
@synthesize eventFormat = _eventFormat;
@synthesize eventClassName = _eventClassName;
@synthesize eventFormatName = _eventFormatName;

- (void)dealloc
{
    [_eventClassName release];
    [_eventFormatName release];
    [super dealloc];
}

#pragma mark - Mapping dictionaries

+ (NSDictionary *)classMappingDictionary
{
    return @{@"note" : [NSNumber numberWithInt:PYEventClassNote],
             @"position" :[NSNumber numberWithInt:PYEventClassPosition]
             };
}

+ (NSDictionary *)formatsMappingDictionary
{
    return @{@"html": [NSNumber numberWithInt:PYEventFormatHTML],
             @"txt": [NSNumber numberWithInt:PYEventFormatTxt],
             @"webclip": [NSNumber numberWithInt:PYEventFormatWebClip],
             @"wgs84": [NSNumber numberWithInt:PYEventFormatLocation]
             };
}

#pragma mark - Utility methods

- (NSString *)getClassNameForClass:(PYEventClass)class
{
    NSString __block *keyToReturn;
    [[[self class] classMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        if ([obj intValue] == class) {
            keyToReturn = key;
            *stop = YES;
        }
    }];
    
    return keyToReturn;
}

+ (PYEventClass)getClassForClassName:(NSString *)className
{
    
    return (PYEventClass)[[[self classMappingDictionary] objectForKey:className] intValue];
}

- (NSString *)getFormatNameForFormat:(PYEventFormat)format
{
    NSString __block *keyToReturn;
    [[[self class] formatsMappingDictionary] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        if ([obj intValue] == format) {
            keyToReturn = key;
            *stop = YES;
        }
    }];
    
    return keyToReturn;

}

+ (PYEventFormat)getFormatForFormatName:(NSString *)formatName
{
    return (PYEventFormat)[[[self formatsMappingDictionary] objectForKey:formatName] intValue];
}

#pragma mark - Designated initializer

- (id)initWithClass:(PYEventClass)theEventClass andFormat:(PYEventFormat)theEventFormat
{
    self = [super init];
    if (self) {
        
        self.eventClass = theEventClass;
        self.eventFormat = theEventFormat;
        
        _eventClassName = [self getClassNameForClass:theEventClass];
        _eventFormatName = [self getFormatNameForFormat:theEventFormat];
        
    }
    
    return self;
}

#pragma mark - get objects from JSON response

+ (PYEventType *)eventTypeFromDictionary:(NSDictionary *)JSON
{
    PYEventType *pet = [[PYEventType alloc] init];
    pet.eventClassName = [JSON objectForKey:@"class"];
    pet.eventFormatName = [JSON objectForKey:@"format"];
    
    pet.eventClass = [self getClassForClassName:pet.eventClassName];
    pet.eventFormat = [self getFormatForFormatName:pet.eventFormatName];
    
    return [pet autorelease];
}
@end
