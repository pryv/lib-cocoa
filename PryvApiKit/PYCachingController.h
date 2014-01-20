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
    PYConnection *_connection;
}
- (PYCachingController*) initWithConnection:(PYConnection*)connection;

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
- (NSData *)getDataForKey:(NSString *)key;
/**
 Remove event from disk for key
 */
- (void)removeEventWithKey:(NSString *)key;
/**
 Remove stream from disk for key
 */
- (void)removeStreamWithKey:(NSString *)key;
/**
 Get all PYEvent objects from disk
 */
- (NSArray *)getAllEventsFromCache;
/**
 Get single PYEvent object from disk for key
 */
- (PYEvent *)getEventWithKey:(NSString *)key;
/**
 Get all PYStream objects from disk
 */
- (NSArray *)getAllStreamsFromCache;
/**
 Get single PYStream object from disk for key
 */
- (PYStream *)getStreamWithKey:(NSString *)key;
@end
