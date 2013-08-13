//
//  PryvCachingController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYChannel;
@class PYStream;
#import <Foundation/Foundation.h>

@interface PYCachingController : NSObject
{
    NSString *_localDataPath;
}

+ (id)sharedManager;
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
- (void)removeEvent:(NSString *)key;
/**
 Remove stream from disk for key
 */
- (void)removeStream:(NSString *)key;
/**
 Get all PYEvent objects from disk
 */
- (NSArray *)getAllEventsFromCache;
/**
 Get single PYEvent object from disk for key
 */
- (PYEvent *)getEventWithKey:(NSString *)key;

/**
 Get all PYChannel objects fro disk
 */
- (NSArray *)getAllChannelsFromCache;
/**
 Get single PYChannel object from disk for key
 */
- (PYChannel *)getChannelWithKey:(NSString *)key;
/**
 Get all PYStream objects from disk
 */
- (NSArray *)getAllStreamsFromCache;
/**
 Get single PYStream object from disk for key
 */
- (PYStream *)getStreamWithKey:(NSString *)key;
@end
