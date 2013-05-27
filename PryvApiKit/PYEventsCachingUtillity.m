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

+ (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    [[PYCachingController sharedManager] cacheEventData:[PYJSONUtility getDataFromJSONObject:event] withKey:eventKey];
    
}

+ (void)cacheEvents:(NSArray *)events
{
    for (NSDictionary *eventDic in events) {
        [self cacheEvent:eventDic WithKey:eventDic[@"id"]];
    }
}

+ (NSArray *)getEventsFromCache
{
    return [[PYCachingController sharedManager] getAllEventsFromCache];
}

@end
