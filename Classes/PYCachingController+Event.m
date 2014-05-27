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
#import "PYLocalStorage.h"

@interface PYCachingController ()
- (NSString *)keyForPreviewOnEvent:(PYEvent *)event;
- (NSString *)keyForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event ;
- (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key;
- (NSString *)keyForNotYetCreatedEvent:(PYEvent *)event;
- (NSString *)keyForAttachment:(PYAttachment *)attachment onNotYetCreatedEvent:(PYEvent *)event;

@end

@implementation PYCachingController (Event)



- (void)cacheEvent:(PYEvent *)event andCleanTempData:(BOOL)cleanTemp
{
    if (cleanTemp) {
       [self removeEntityWithKey:[self keyForNotYetCreatedEvent:event]];
        // move eventual attachments
        for (PYAttachment* att in event.attachments) {
            [self moveEntityWithKey:[self keyForAttachment:att onNotYetCreatedEvent:event]
                              toKey:[self keyForAttachment:att onEvent:event]];
        }
        
    }
    [self cacheEvent:event];
}

- (void)cacheEvent:(PYEvent *)event
{

    for (PYAttachment *att in event.attachments) {
        if (att.fileData && att.fileData.length > 0) [self saveDataForAttachment:att onEvent:event];
    }
      
    NSData *eventData = [PYJSONUtility getDataFromJSONObject:[event cachingDictionary]];
    [self cacheData:eventData withKey:[self keyForEvent:event]];
    [[PYLocalStorage sharedInstance] save:event];
}




- (void)removeEvent:(PYEvent *)event
{
    [self removeEntityWithKey:[self keyForEvent:event]];
    if (event.attachments) {
    for (PYAttachment* att in event.attachments) {
        [self removeEntityWithKey:[self keyForAttachment:att onEvent:event]];
    }
    }
    [self removeEntityWithKey:[self keyForPreviewOnEvent:event]];
}


- (NSString *)keyForEvent:(PYEvent *)event {
    if (event.hasTmpId) {
        return [self keyForNotYetCreatedEvent:event];
    }
    
    return [self keyForEventId:event.eventId];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)keyForNotYetCreatedEvent:(PYEvent *)event {
    return [self keyForEventId:event.clientId];
}


#pragma clang diagnostic pop

- (NSString *)keyForEventId:(NSString *)eventId {
    return [NSString stringWithFormat:@"event_%@", eventId];
}


#pragma mark - previews


- (NSArray *)eventsFromCache
{
    return [self allEventsFromCache];
}

- (BOOL)eventIsKnownByCache:(PYEvent *)event
{
    return [self isDataCachedForKey:[self keyForEvent:event]];
}


#pragma mark - attachments

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)keyForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event {
    return [NSString stringWithFormat:@"att_%@_%@", [self keyForEvent:event], attachment.fileName];
}

- (NSString *)keyForAttachment:(PYAttachment *)attachment onNotYetCreatedEvent:(PYEvent *)event {
    return [NSString stringWithFormat:@"att_%@_%@", [self keyForNotYetCreatedEvent:event], attachment.fileName];
}

#pragma clang diagnostic pop

- (NSData *)dataForAttachment:(PYAttachment *)attachment  onEvent:(PYEvent*) event {
    attachment.fileData = [self dataForKey:[self keyForAttachment:attachment onEvent:event]];
    return attachment.fileData;
}

- (void)saveDataForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event {
    [self cacheData:attachment.fileData  withKey:[self keyForAttachment:attachment onEvent:event]];
}


#pragma mark - previews

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (NSString *)keyForPreviewOnEvent:(PYEvent *)event {
    return [NSString stringWithFormat:@"preview_%@", [self keyForEvent:event]];
}
#pragma clang diagnostic pop

- (NSData *)previewForEvent:(PYEvent *)event {
    return [self dataForKey:[self keyForPreviewOnEvent:event]];
}

- (void)savePreview:(NSData *)fileData forEvent:(PYEvent *)event {
    [self cacheData:fileData  withKey:[self keyForPreviewOnEvent:event]];
}

@end
