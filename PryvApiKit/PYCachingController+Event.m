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
#import "PYAttachment.h"

@interface PYCachingController ()
- (NSString *)keyForPreviewOnEvent:(PYEvent *)event;
- (NSString *)keyForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event ;
- (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key;
@end

@implementation PYCachingController (Event)


- (void)cacheEvent:(PYEvent *)event
{
    NSDictionary *eventDic = [event cachingDictionary];
    [self cacheEvent:eventDic withKey:[self keyForEvent:event]];
}

- (void)cacheEvent:(NSDictionary *)event withKey:(NSString *)key
{
    NSMutableDictionary *eventForCache = [event mutableCopy];
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    NSMutableDictionary *attachmentsDic = [[eventForCache objectForKey:@"attachments"] mutableCopy];
    if ([attachmentsDic count] > 0) {
        
        [[eventForCache objectForKey:@"attachments"] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *attachmentDataDic, BOOL *stop) {
            
            NSMutableDictionary *mutableAttachmentDataDic = [attachmentDataDic mutableCopy];
            
            NSString *eventId = [eventForCache objectForKey:@"id"];
            NSString *fileName = [mutableAttachmentDataDic objectForKey:@"fileName"];
            if (!fileName) {
                fileName = @"";
            }
            
            NSString *attachmentDataKey = [NSString stringWithFormat:@"%@_%@", eventId, fileName];
            NSData *attachmentData = [mutableAttachmentDataDic objectForKey:@"attachmentData"];
            [self cacheData:attachmentData withKey:attachmentDataKey];
            
            [mutableAttachmentDataDic removeObjectForKey:@"attachmentData"];
            [attachmentsDic setObject:mutableAttachmentDataDic forKey:key];

            [mutableAttachmentDataDic release];

        }];
        
        [eventForCache setObject:attachmentsDic forKey:@"attachments"];
    }
    [attachmentsDic release];
    
    NSData *eventData = [PYJSONUtility getDataFromJSONObject:eventForCache];
    [self cacheData:eventData withKey:eventKey];
    [eventForCache release];
}

- (void)removeEvent:(PYEvent *)event withKey:(NSString *)key
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",key];
    [self removeEntityWithKey:eventKey];
    //second try
    eventKey = [[NSString stringWithFormat:@"event_%f",event.time] stringByReplacingOccurrencesOfString:@"." withString:@""];
    [self removeEntityWithKey:eventKey];
    //preview
    [self removeEntityWithKey:[self keyForPreviewOnEvent:event]];

}

- (void)cacheEvents:(NSArray *)events
{
    if ([self cachingEnabled]) {
        for (NSDictionary *eventDic in events) {
            [self cacheEvent:eventDic withKey:[eventDic objectForKey:@"id"]];
        }

    }
}

- (void)removeEvent:(PYEvent *)event
{
    [self removeEvent:event withKey:[self keyForEvent:event]];
}

- (NSString *)keyForEvent:(PYEvent *)event
{    
    return event.eventId;
}


- (NSArray *)eventsFromCache
{
    return [self allEventsFromCache];
}

- (PYEvent *)eventFromCacheWithEventId:(NSString *)eventId
{
    NSString *eventKey = [NSString stringWithFormat:@"event_%@",eventId];
    return [self eventWithKey:eventKey];

}

- (void)findAndCacheEventWithServerId:(NSString *)eventId
                      usingConnection:(PYConnection *)connection
                          requestType:(PYRequestType)reqType
{
    //In this method we will ask server for event with eventId and we'll cache it
    [connection getOnlineEventWithId:eventId
                         requestType:reqType
                      successHandler:^(PYEvent *event) {
                          
                          [self cacheEvent:event];
                          
                      } errorHandler:^(NSError *error) {
                          NSLog(@"error: %@", error);
                      }];
}


#pragma mark - attachments

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)keyForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event {
    return [NSString stringWithFormat:@"%@_attachment_%@", event.eventId, attachment.fileName];
}
#pragma clang diagnostic pop

- (NSData *)dataForAttachment:(PYAttachment *)attachment  onEvent:(PYEvent*) event {
    return [self dataForKey:[self keyForAttachment:attachment onEvent:event]];
}

- (void)saveDataForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event {
    [self cacheData:attachment.fileData  withKey:[self keyForAttachment:attachment onEvent:event]];
}



#pragma mark - previews

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)keyForPreviewOnEvent:(PYEvent *)event {
    return [NSString stringWithFormat:@"%@_preview", event.eventId];
}
#pragma clang diagnostic pop

- (NSData *)previewForEvent:(PYEvent *)event {
    return [self dataForKey:[self keyForPreviewOnEvent:event]];
}

- (void)savePreview:(NSData *)fileData forEvent:(PYEvent *)event {
    [self cacheData:fileData  withKey:[self keyForPreviewOnEvent:event]];
}

@end
