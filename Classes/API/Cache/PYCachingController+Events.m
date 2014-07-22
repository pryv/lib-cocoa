//
//  PYEventsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController.h"
#import "PYCachingController+Events.h"
#import "PYEvent.h"
#import "PYConnection.h"
#import "PYConnection+Events.h"
#import "PYConnection+Streams.h"
#import "PYJSONUtility.h"
#import "PYAttachment.h"

@interface PYCachingController ()
- (NSString *)keyForPreviewOnEvent:(PYEvent *)event;
- (NSString *)keyForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event ;
- (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key;
- (NSString *)keyForNotYetCreatedEvent:(PYEvent *)event;
- (NSString *)keyForAttachment:(PYAttachment *)attachment onNotYetCreatedEvent:(PYEvent *)event;

@end

@implementation PYCachingController (Events)

- (void)cacheEvent:(PYEvent *)event {
    [self cacheEvent:event addSaveCache:YES];
}


- (void)cacheEvent:(PYEvent *)event addSaveCache:(BOOL)save {

    for (PYAttachment *att in event.attachments) {
        if (att.fileData && att.fileData.length > 0) [self saveDataForAttachment:att onEvent:event];
    }
      
    NSDictionary *eventData = [event cachingDictionary];
    [self.allEventsDictionary setObject:eventData forKey:[self keyForEvent:event]];
    
    if (save) {
        [self saveAllEvents];
    }
}

- (void)cacheEvent:(PYEvent *)event andCleanTempData:(BOOL)cleanTemp
{
    if (cleanTemp) {
        [self.allEventsDictionary removeObjectForKey:[self keyForNotYetCreatedEvent:event]];
        // move eventual attachments
        for (PYAttachment* att in event.attachments) {
            [self moveEntityWithKey:[self keyForAttachment:att onNotYetCreatedEvent:event]
                              toKey:[self keyForAttachment:att onEvent:event]];
        }
        
    }
    [self cacheEvent:event];
}


- (void)removeEvent:(PYEvent *)event
{
    [self.allEventsDictionary removeObjectForKey:[self keyForEvent:event]];
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

- (BOOL)eventIsKnownByCache:(PYEvent *)event
{
    return ([self.allEventsDictionary objectForKey:[self keyForEvent:event]] != nil);
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
