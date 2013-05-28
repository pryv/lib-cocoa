//
//  PYEventsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
#import <Foundation/Foundation.h>

@interface PYEventsCachingUtillity : NSObject

+ (void)cacheEvent:(PYEvent *)event;
+ (void)cacheUnsyncEvent:(PYEvent *)event;
//Array of event JSON data(dictionaries)
+ (void)cacheEvents:(NSArray *)events;
//Array  of PYEvent objects
+ (void)cacheEventObjects:(NSArray *)eventObjects;
//Archive NSURLRequest
+ (void)cacheURLRequest:(NSURLRequest *)request forEventId:(NSString *)eventId;
+ (NSURLRequest *)getNSURLRequestForEventId:(NSString *)eventId;

+ (NSArray *)getEventsFromCache;
+ (NSArray *)getUnsyncEventsFromCache;
+ (PYEvent *)getEventFromCacheWithEventId:(NSString *)eventId isUnsync:(BOOL)unsync;

@end
