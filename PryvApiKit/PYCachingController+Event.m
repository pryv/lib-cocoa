//
//  PYEventsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController+Event.h"
#import "PYEvent.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYJSONUtility.h"

@implementation PYCachingController (Event)



- (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key
{
    NSMutableDictionary *eventForCache = [event mutableCopy];
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    NSMutableDictionary *attachmentsDic = [[eventForCache objectForKey:@"attachments"] mutableCopy];
    if (attachmentsDic && attachmentsDic.count > 0) {
        
        [[eventForCache objectForKey:@"attachments"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *attachmentDataDic, BOOL *stop) {
            
            NSMutableDictionary *mutableAttachmentDataDic = [attachmentDataDic mutableCopy];
            
            NSString *eventId = [eventForCache objectForKey:@"id"];
            NSString *fileName = [mutableAttachmentDataDic objectForKey:@"fileName"];
            if (!fileName) {
                fileName = @"";
            }
            
            NSString *attachmentDataKey = [NSString stringWithFormat:@"%@_%@", eventId, fileName];
            NSData *attachmentData = [mutableAttachmentDataDic objectForKey:@"attachmentData"];
            [self cacheData:attachmentData
                                                   withKey:attachmentDataKey];
            
            [mutableAttachmentDataDic removeObjectForKey:@"attachmentData"];
            [attachmentsDic setObject:mutableAttachmentDataDic forKey:key];

        }];
        
        [eventForCache setObject:attachmentsDic forKey:@"attachments"];
    }
    
    NSData *eventData = [PYJSONUtility getDataFromJSONObject:eventForCache];
    [self cacheData:eventData withKey:eventKey];
    
}

- (void)removeEvent:(PYEvent *)event WithKey:(NSString *)key
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    [self removeEventWithKey:eventKey];
    //second try
    eventKey = [[NSString stringWithFormat:@"event_%f",event.time] stringByReplacingOccurrencesOfString:@"." withString:@""];
    [self removeEventWithKey:eventKey];

}

- (void)cacheEvents:(NSArray *)events
{
    if ([self cachingEnabled]) {
        for (NSDictionary *eventDic in events) {
            [self cacheEvent:eventDic WithKey:[eventDic objectForKey:@"id"]];
        }

    }
}

- (void)cacheEvent:(PYEvent *)event
{
    NSDictionary *eventDic = [event cachingDictionary];
    [self cacheEvent:eventDic WithKey:[self getKeyForEvent:event]];
}

- (void)removeEvent:(PYEvent *)event
{
    [self removeEvent:event WithKey:[self getKeyForEvent:event]];
}

- (NSString *)getKeyForEvent:(PYEvent *)event
{    
    return event.eventId;
}


- (NSArray *)getEventsFromCache
{
    return [self getAllEventsFromCache];
}

- (PYEvent *)getEventFromCacheWithEventId:(NSString *)eventId
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",eventId];
    return [self getEventWithKey:eventKey];

}

- (void)getAndCacheEventWithServerId:(NSString *)eventId
                     usingConnection:(PYConnection *)connection
                         requestType:(PYRequestType)reqType
{
    //In this method we will ask server for event with eventId and we'll cache it
    [connection getOnlineEventWithId:eventId
                         requestType:reqType
                      successHandler:^(PYEvent *event) {
                          
                          [self cacheEvent:event];
                          
                      } errorHandler:^(NSError *error) {
                          NSLog(@"error");
                      }];
}


@end
