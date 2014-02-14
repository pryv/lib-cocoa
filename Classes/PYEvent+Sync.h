//
//  PYEvent+Sync.h
//  PryvApiKit
//
//  Created by Perki on 04.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYEvent.h"

@interface PYEvent (Sync)

/**
 * reset modified properties
 */
- (void) clearModifiedProperties;

/**
 * use before caching an updated, not synched event;
 */
- (void) compareAndSetModifiedPropertiesFromCache;

/**
 * set this event to be delete on next Sync
 */
- (void) setToBeDeletedOnSync;

/**
 * check if object need to be deleted
 */
- (BOOL) toBeDeleteOnSync;

/**
 * get the dictionary for next update
 */
- (NSDictionary*) dictionaryForUpdate;

/**
 * check if a property needs to be set
 */
- (BOOL) hasPropertyToSync:(NSString*) propertyName;

@end
