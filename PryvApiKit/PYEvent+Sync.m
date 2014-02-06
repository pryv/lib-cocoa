//
//  PYEvent+Sync.m
//  PryvApiKit
//
//  Created by Perki on 04.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//



#import "PYEvent+Sync.h"

@implementation PYEvent (Sync)


NSString* const kPYEventSyncAll = @"SYNC_ALL_PROPERTIES";
NSString* const kPYEventDeleteOnSync = @"SYNC_TO_BE_DELETED";

- (void) clearModifiedProperties {
    self.modifiedEventPropertiesToBeSync = nil;
}

- (void) compareAndSetModifiedPropertiesFromCache {
    // for now we set all properties but we should check properties
    
    /**
     NSDictionary *modifiedPropertiesDic = [self dictionary];
     [modifiedPropertiesDic
     enumerateKeysAndObjectsUsingBlock:^(NSString *property, id value, BOOL *stop) {
     [currentEventFromCache setValue:value forKey:property];
     }];
     
     //We have to know what properties are modified in order to make succesfull request
     currentEventFromCache.modifiedEventPropertiesToBeSync = [eventObject dictionary];
     //We must have cached modified properties of event in cache
     **/
    [self addPropertiesToSync:kPYEventSyncAll];
}

- (void) addPropertiesToSync:(NSString*) propertyName
{
    if (self.modifiedEventPropertiesToBeSync == nil) {
        self.modifiedEventPropertiesToBeSync = [NSMutableSet setWithObject:propertyName];
    } else {
        if (! [self.modifiedEventPropertiesToBeSync member:propertyName]) {
            [self.modifiedEventPropertiesToBeSync addObject:propertyName];
        }
    }
}

- (BOOL) hasPropertyToSync:(NSString*) propertyName
{
    if (self.modifiedEventPropertiesToBeSync == nil) return NO;
    return ([self.modifiedEventPropertiesToBeSync member:propertyName] != nil);
}

- (void) setToBeDeletedOnSync
{
    [self addPropertiesToSync:kPYEventDeleteOnSync];
}

- (BOOL) toBeDeleteOnSync
{
    return [self hasPropertyToSync:kPYEventDeleteOnSync];
}

- (NSDictionary*) dictionaryForUpdate
{
    if (self.modifiedEventPropertiesToBeSync == nil) { return nil; };
    if (! [self.modifiedEventPropertiesToBeSync member:kPYEventSyncAll]) {
        return [self dictionary];
    }
    return nil;
}


@end
