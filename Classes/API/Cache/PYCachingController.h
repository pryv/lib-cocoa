//
//  PryvCachingController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYStream;
@class PYConnection;

@interface PYCachingController : NSObject
{
    NSString *_localDataPath;
    NSMutableDictionary *_allEventsDictionary;
}


@property (nonatomic, retain) NSMutableDictionary* allEventsDictionary;


- (id)initWithConnection:(PYConnection*) connection;


#pragma mark - id to disk manipulations

/**
 Check if data is cached for key
*/
- (BOOL)isDataCachedForKey:(NSString *)key;
/**
 Cache NSData on disk
 */
- (void)cacheData:(NSData *)data withKey:(NSString *)key;
/**
 Get NSData object from disk
 */
- (NSData *)dataForKey:(NSString *)key;
/**
 Remove an entity from disk for key
 */
- (void)removeEntityWithKey:(NSString *)key;

/**
 Change the key of an event
 */
- (void)moveEntityWithKey:(NSString *)src toKey:(NSString *)dst;


#pragma mark - streams

/**
 Get all PYStream objects from disk
 */
- (NSArray *)allStreams;

# pragma mark - events

/**
 Get all PYEvent objects from memory
 */
- (NSArray *)allEvents;


/**
 * Trigger a save All event on disk
 */
- (void)saveAllEvents;


/**
 Get single PYEvent object from disk for key
 doesn't set connection property on Event
 */
- (PYEvent *)eventWithEventId:(NSString *)eventId;


@end
