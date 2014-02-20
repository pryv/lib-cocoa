//
//  PryvCachingController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYStream;

@interface PYCachingController : NSObject
{
    NSString *_localDataPath;
}

- (id)initWithCachingId:(NSString *)connectionCachingId;

/** return true is caching is enbaled (at compile time) **/
- (BOOL)cachingEnabled;

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


- (void)moveEntityWithKey:(NSString *)src toKey:(NSString *)dst;
/**
 Remove stream from disk for key
 */
- (void)removeStreamWithKey:(NSString *)key;
/**
 Get all PYEvent objects from disk
 doesn't set connection property on Event
 */
- (NSArray *)allEventsFromCache;

/**
 Reset content of an exisiting event with the data present in the cache
 */
- (void) resetEventFromDictionary:(PYEvent*)event;

/**
 Get single PYEvent object from disk for key
 doesn't set connection property on Event
 */
- (PYEvent *)eventWithKey:(NSString *)key;
- (PYEvent *)eventWithEventId:(NSString *)eventId;
/**
 Get all PYStream objects from disk
 */
- (NSArray *)allStreamsFromCache;
/**
 Get single PYStream object from disk for key
 */
- (PYStream *)streamWithKey:(NSString *)key;
@end
