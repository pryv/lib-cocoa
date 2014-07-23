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

@interface PYCachingController (Events)

/**
 Cache PYEvent object on disk
 */
- (void)cacheEvent:(PYEvent *)event;

/**
 Cache PYEvent object on disk and tell if it should be saved
 */
- (void)cacheEvent:(PYEvent *)event andSaveCache:(BOOL)save;

/**
 Cache PYEvent object on disk and eventually remove temporary data
 */
- (void)cacheEvent:(PYEvent *)event andCleanTempData:(BOOL)cleanTemp;

/**
 Remove PYEvent object from disk
 */
- (void)removeEvent:(PYEvent *)event;


/**
 check if the event is known by cache
 */
- (BOOL)eventIsKnownByCache:(PYEvent *)event;

/**
 Utility method - Get key for event
 */
- (NSString *)keyForEvent:(PYEvent *)event;
- (NSString *)keyForEventId:(NSString *)eventId ;

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
