//
//  PYEventFilterUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@class PYConnection;
@class PYFilter;

@interface PYEventFilterUtility : NSObject


+ (void)sortNSMutableArrayOfPYEvents:(NSMutableArray *)events sortAscending:(BOOL)sortAscending;

+ (NSPredicate *)predicateFromFilter:(PYFilter *)filter;

/**
 This method gets NSDictionary json-like representation of PYEventFilter
 */
+ (NSDictionary *)apiParametersForEventsRequestFromFilter:(PYFilter *)filter;
/**
 Get array of PYEvent objects from cache that are filtered 
 */
+ (NSArray *)filterEventsList:(NSArray *)events withFilter:(PYFilter *)filter;
/**
 This method creates event sync details for visual presentation on client app
 */
+ (void)createEventsSyncDetails:(NSArray *)onlineEventList
                  knownEvents:(NSArray *)knownEvents
                    eventsToAdd:(NSMutableArray *)eventsToAdd
                 eventsToRemove:(NSMutableArray *)eventsToRemove
                 eventsModified:(NSMutableArray *)eventsModified;

/**
 Get all the streamIds covered by a Filter
 */
+ (NSArray *)streamIdsCoveredByFilter:(PYFilter *)filter;

/**
 * does not consider modified since
 */
+ (BOOL)filter:(PYFilter*)srcFilter isIncludedInFilter:(PYFilter*)destFilter;

@end
