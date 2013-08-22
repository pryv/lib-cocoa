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
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYJSONUtility.h"

@implementation PYEventsCachingUtillity

+ (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

+ (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key
{
    NSMutableDictionary *eventForCache = [event mutableCopy];
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    NSMutableDictionary *attachmentsDic = [[eventForCache objectForKey:@"attachments"] mutableCopy];
    
    if (attachmentsDic && attachmentsDic.count > 0) {
        
        
        [attachmentsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *attachmentDataDic, BOOL *stop) {
            
            NSMutableDictionary *mutableAttachmentDataDic = [attachmentDataDic mutableCopy];
            
            NSString *eventId = [eventForCache objectForKey:@"id"];
            NSString *fileName = [mutableAttachmentDataDic objectForKey:@"fileName"];
            if (!fileName) {
                fileName = @"";
            }
            
            NSString *attachmentDataKey = [NSString stringWithFormat:@"%@_%@", eventId, fileName];
            NSData *attachmentData = [mutableAttachmentDataDic objectForKey:@"attachmentData"];
            [[PYCachingController sharedManager] cacheData:attachmentData
                                                   withKey:attachmentDataKey];
            
            [mutableAttachmentDataDic removeObjectForKey:@"attachmentData"];
            [attachmentsDic setObject:mutableAttachmentDataDic forKey:key];

        }];
        
        [eventForCache setObject:attachmentsDic forKey:@"attachments"];
    }
    
    NSData *eventData = [PYJSONUtility getDataFromJSONObject:eventForCache];
    [[PYCachingController sharedManager] cacheData:eventData withKey:eventKey];
    
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
            [self cacheEvent:eventDic WithKey:[eventDic objectForKey:@"id"]];
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

+ (void)getAndCacheEventWithServerId:(NSString *)eventId
                     usingConnection:(PYConnection *)connection
                         requestType:(PYRequestType)reqType
{
    //In this method we will ask server for event with eventId and we'll cache it
    NSLog(@"Event id : %@",eventId);
    [connection getOnlineEventWithId:eventId
                         requestType:reqType
                      successHandler:^(PYEvent *event) {
                          
                          [PYEventsCachingUtillity cacheEvent:event];
                          
                      } errorHandler:^(NSError *error) {
                          NSLog(@"error");
                      }];
}


@end
