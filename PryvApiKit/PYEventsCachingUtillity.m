//
//  PYEventsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventsCachingUtillity.h"
#import "PYCachingController.h"
#import "PYEvent.h"
#import "PYJSONUtility.h"

@implementation PYEventsCachingUtillity

+ (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

+ (void)cacheURLRequest:(NSURLRequest *)request forEventKey:(NSString *)uniqueKey
{
    NSString *requestKey = [NSString stringWithFormat:@"request_%@",uniqueKey];
    [[PYCachingController sharedManager] cacheNSURLRequest:request withKey:requestKey];

}

+ (NSURLRequest *)getNSURLRequestForEventKey:(NSString *)uniqueKey;
{
    NSString *requestKey = [NSString stringWithFormat:@"request_%@",uniqueKey];
    return [[PYCachingController sharedManager] getNSURLRequestForKey:requestKey];
}

+ (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    [[PYCachingController sharedManager] cacheEventData:[PYJSONUtility getDataFromJSONObject:event] withKey:eventKey];
    
}

+ (void)removeEvent:(PYEvent *)event WithKey:(NSString *)key
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    [[PYCachingController sharedManager] removeEvent:eventKey];

}

+ (void)cacheEvents:(NSArray *)events
{
    if ([self cachingEnabled]) {
        for (NSDictionary *eventDic in events) {
            [self cacheEvent:eventDic WithKey:eventDic[@"id"]];
        }

    }
}

+ (void)cacheEvent:(PYEvent *)event
{
    NSDictionary *eventDic = [event cachingDictionary];
    [self cacheEvent:eventDic WithKey:[self getKeyForEvent:event]];
}

+ (void)removeEvent:(PYEvent *)event
{
    [self removeEvent:event WithKey:[self getKeyForEvent:event]];
}

+ (NSString *)getKeyForEvent:(PYEvent *)event
{
    if (!event.eventId) {
        //If event is created offline or/and it's not synched ever, event doesn't have id so use alternate way for unique id
        //event.timeIntervalWhenCreationTried is created when user tried to create event
        return [[NSNumber numberWithDouble:event.timeIntervalWhenCreationTried] stringValue];
    }
    
    return event.eventId;
}


+ (NSArray *)getEventsFromCache
{
    return [[PYCachingController sharedManager] getAllEventsFromCache];
}

+ (PYEvent *)getEventFromCacheWithEventId:(NSString *)eventId
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",eventId];
    return [[PYCachingController sharedManager] getEventWithKey:eventKey];

}

@end
