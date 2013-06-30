//
//  PYEventFilterUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
@class PYEventFilter;
@class PYChannel;
#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYEventFilterUtility : NSObject

+ (NSDictionary *)filteredEvents:(PYEventFilter *)filter;
+ (NSArray *)filterCachedEvents:(NSArray *)cachedEventsArray withFilter:(PYEventFilter *)filter;
+ (void)createEventsSyncDetails:(NSArray *)onlineEventList
                  offlineEvents:(NSArray *)cachedEvents
                    eventsToAdd:(NSMutableArray *)eventsToAdd
                 eventsToRemove:(NSMutableArray *)eventsToRemove
                 eventsModified:(NSMutableArray *)eventsModified;

+ (void)getAndCacheEventWithServerId:(NSString *)eventId
                           inChannel:(PYChannel *)channel
                         requestType:(PYRequestType)reqType;


@end
