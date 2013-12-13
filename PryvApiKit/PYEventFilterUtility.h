//
//  PYEventFilterUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@class PYEventFilter;

@interface PYEventFilterUtility : NSObject

/**
 This method gets NSDictionary json-like representation of PYEventFilter
 */
+ (NSDictionary *)filteredEvents:(PYEventFilter *)filter;
/**
 Get array of PYEvent objects from cache that are filtered 
 */
+ (NSArray *)filterCachedEvents:(NSArray *)cachedEventsArray withFilter:(PYEventFilter *)filter;
/**
 This method creates event sync details for visual presentation on client app
 */
+ (void)createEventsSyncDetails:(NSArray *)onlineEventList
                  offlineEvents:(NSArray *)cachedEvents
                    eventsToAdd:(NSMutableArray *)eventsToAdd
                 eventsToRemove:(NSMutableArray *)eventsToRemove
                 eventsModified:(NSMutableArray *)eventsModified;

/**
 This method get particular event from server and cache it
*/
+ (void)getAndCacheEventWithServerId:(NSString *)eventId
                     usingConnection:(PYConnection *)connection
                         requestType:(PYRequestType)reqType;


@end
