//
//  PYStreamsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYStream;
@class PYChannel;
#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYStreamsCachingUtillity : NSObject

/**
 Cache stream json objects on disk
 */
+ (void)cacheStreams:(NSArray *)streams;
/**
 Remove PYStream object from disk
 */
+ (void)removeStream:(PYStream *)stream;
/**
 Get all PYStream objects from disk
 */
+ (NSArray *)getStreamsFromCache;
/**
 Get PYStream object from disk with key(streamId)
 */
+ (PYStream *)getStreamFromCacheWithStreamId:(NSString *)streamId;
/**
 Cache PYStream object on disk
 */
+ (void)cacheStream:(PYStream *)stream;
/**
 Get stream with particular id from server and cache it on disk
 */
+ (void)getAndCacheStream:(PYStream *)stream
             withServerId:(NSString *)serverId
              requestType:(PYRequestType)reqType;

@end
