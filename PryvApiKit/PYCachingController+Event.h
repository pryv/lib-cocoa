//
//  PYEventsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYCachingController.h"

@class PYEvent, PYConnection, PYAttachment;

@interface PYCachingController (Event)

/**
 Cache PYEvent object on disk
 */
- (void)cacheEvent:(PYEvent *)event;
/**
 Remove PYEvent object from disk
 */
- (void)removeEvent:(PYEvent *)event;

/**
 Get all PYEvent objects from disk
 */
- (NSArray *)eventsFromCache;
/**
 Get PYEvent object from disk with key(eventId)
 */
- (PYEvent *)eventFromCacheWithEventId:(NSString *)eventId;

/**
 Utility method - Get key for event
 */
- (NSString *)keyForEvent:(PYEvent *)event;
- (NSString *)keyForEventId:(NSString *)eventId;



- (NSData *)dataForAttachment:(PYAttachment *)attachment  onEvent:(PYEvent*) event;
- (void)saveDataForAttachment:(PYAttachment *)attachment onEvent:(PYEvent*) event;



/**
 get cachedPreview (if any)
 */
- (NSData *)previewForEvent:(PYEvent *)event;

/**
 save preview for this event
 */
- (void)savePreview:(NSData *)fileData forEvent:(PYEvent *)event;



@end
