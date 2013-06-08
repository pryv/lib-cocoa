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
+ (void)removeEvent:(PYEvent *)event;
//Array of event JSON data(dictionaries)
+ (void)cacheEvents:(NSArray *)events;
//Archive NSURLRequest
+ (void)cacheURLRequest:(NSURLRequest *)request forEventKey:(NSString *)uniqueKey;
+ (NSURLRequest *)getNSURLRequestForEventKey:(NSString *)uniqueKey;

+ (NSArray *)getEventsFromCache;
+ (PYEvent *)getEventFromCacheWithEventId:(NSString *)eventId;

//Utility
+ (NSString *)getKeyForEvent:(PYEvent *)event;

@end
