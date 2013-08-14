//
//  PYStreamsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYStreamsCachingUtillity.h"
#import "PYCachingController.h"
#import "PYJSONUtility.h"
#import "PYStream.h"
#import "PYChannel.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"

@implementation PYStreamsCachingUtillity

+ (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

+ (void)removeStream:(PYStream *)stream
{
    [self removeStream:stream WithKey:[self getKeyForStream:stream]];
}

+ (void)removeStream:(PYStream *)stream WithKey:(NSString *)key
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",key];
    [[PYCachingController sharedManager] removeStream:streamKey];
    
}

+(void)getAndCacheStream:(PYStream *)stream
            withServerId:(NSString *)serverId
             requestType:(PYRequestType)reqType{
    
    [stream.connection getOnlineStreamWithId:serverId requestType:reqType successHandler:^(PYStream *stream) {
        [PYStreamsCachingUtillity cacheStream:stream];
    } errorHandler:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];
    
}

+ (void)cacheStreams:(NSArray *)streams;
{
    if ([self cachingEnabled]) {
        for (NSDictionary *streamDic in streams) {
            [self cacheStream:streamDic WithKey:[streamDic objectForKey:@"id"]];
        }        
    }
}

+ (void)cacheStream:(NSDictionary *)stream WithKey:(NSString *)key
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",key];
    [[PYCachingController sharedManager] cacheData:[PYJSONUtility getDataFromJSONObject:stream] withKey:streamKey];
}

+ (void)cacheStream:(PYStream *)stream
{
    NSDictionary *streamDic = [stream cachingDictionary];
//    [self cacheEvent:eventDic WithKey:[self getKeyForEvent:event]];
    [self cacheStream:streamDic WithKey:[self getKeyForStream:stream]];
}

+ (NSString *)getKeyForStream:(PYStream *)stream
{    
    return stream.streamId;
}


+ (NSArray *)getStreamsFromCache
{
    return [[PYCachingController sharedManager] getAllStreamsFromCache];
}

+ (PYStream *)getStreamFromCacheWithStreamId:(NSString *)streamId
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",streamId];
    return [[PYCachingController sharedManager] getStreamWithKey:streamKey];
    
}

@end
