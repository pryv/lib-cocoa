//
//  PYStreamsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController+Stream.h"
#import "PYJSONUtility.h"
#import "PYStream.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"

@implementation  PYCachingController (Stream)


- (void)removeStream:(PYStream *)stream
{
    [self removeStream:stream withKey:[self keyForStream:stream]];
}

- (void)removeStream:(PYStream *)stream withKey:(NSString *)key
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",key];
    [self removeStreamWithKey:streamKey];
    
}

-(void)findAndCacheStream:(PYStream *)stream
             withServerId:(NSString *)serverId
              requestType:(PYRequestType)reqType
{
        [stream.connection streamOnlineWithId:serverId
                              successHandler:^(PYStream *stream) {
        [self cacheStream:stream];
    } errorHandler:^(NSError *error) {
        NSLog(@"Error : %@",error);
    }];    
}

- (void)cacheStreams:(NSArray *)streams;
{
    if ([self cachingEnabled]) {
        for (NSDictionary *streamDic in streams) {
            [self cacheStream:streamDic withKey:[streamDic objectForKey:@"id"]];
        }        
    }
}

- (void)cacheStream:(NSDictionary *)stream withKey:(NSString *)key
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",key];
    [self cacheData:[PYJSONUtility getDataFromJSONObject:stream] withKey:streamKey];
}

- (void)cacheStream:(PYStream *)stream
{
    NSDictionary *streamDic = [stream cachingDictionary];
//    [self cacheEvent:eventDic WithKey:[self keyForEvent:event]];
    [self cacheStream:streamDic withKey:[self keyForStream:stream]];
}

- (NSString *)keyForStream:(PYStream *)stream
{    
    return stream.streamId;
}


- (NSArray *)streamsFromCache
{
    return [self allStreamsFromCache];
}

- (PYStream *)streamFromCacheWithStreamId:(NSString *)streamId
{
    NSString *streamKey = [NSString stringWithFormat:@"stream_%@",streamId];
    return [self streamWithKey:streamKey];
    
}

@end
