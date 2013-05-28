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

+ (void)cacheURLRequest:(NSURLRequest *)request forEventId:(NSString *)eventId
{
    NSString *requestKey = [NSString stringWithFormat:@"request_%@",eventId];
    [[PYCachingController sharedManager] cacheNSURLRequest:request withKey:requestKey];

}

+ (NSURLRequest *)getNSURLRequestForEventId:(NSString *)eventId
{
    NSString *requestKey = [NSString stringWithFormat:@"request_%@",eventId];
    return [[PYCachingController sharedManager] getNSURLRequestForKey:requestKey];
}

+ (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key isUnsync:(BOOL)unsync
{
    NSString *eventKey;
    if (unsync) {
        eventKey = [NSString stringWithFormat:@"unsync_event_%@",key];
    }else{
        eventKey = [NSString stringWithFormat:@"event_%@",key];
    }
    [[PYCachingController sharedManager] cacheEventData:[PYJSONUtility getDataFromJSONObject:event] withKey:eventKey];
    
}

+ (void)cacheEvents:(NSArray *)events
{
    if ([self cachingEnabled]) {
        for (NSDictionary *eventDic in events) {
            [self cacheEvent:eventDic WithKey:eventDic[@"id"] isUnsync:NO];
        }

    }
}

+ (void)cacheEventObjects:(NSArray *)eventObjects
{
    if ([self cachingEnabled]) {
        
    }
}

+ (void)cacheEvent:(PYEvent *)event
{
    NSDictionary *eventDic = [event dictionary];
    [self cacheEvent:eventDic WithKey:eventDic[@"id"] isUnsync:NO];
}

+ (void)cacheUnsyncEvent:(PYEvent *)event
{
    NSDictionary *eventDic = [event dictionary];
    [self cacheEvent:eventDic WithKey:eventDic[@"id"] isUnsync:YES];

}


+ (NSArray *)getEventsFromCache
{
    return [[PYCachingController sharedManager] getAllEventsFromCache];
}

+ (NSArray *)getUnsyncEventsFromCache
{
    return [[PYCachingController sharedManager] getAllUnsyncEventsFromCache];
}

+ (PYEvent *)getEventFromCacheWithEventId:(NSString *)eventId isUnsync:(BOOL)unsync
{
    NSString *eventKey;
    if (unsync) {
        eventKey = [NSString stringWithFormat:@"unsync_event_%@",eventId];
    }else{
        eventKey = [NSString stringWithFormat:@"event_%@",eventId];
    }
    return [[PYCachingController sharedManager] getEventWithKey:eventKey];

}

@end
