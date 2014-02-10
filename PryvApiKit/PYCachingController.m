//
//  PryvCachingController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController.h"
#import "PYCachingController+Event.h"
#import "PYJSONUtility.h"
#import "PYEvent.h"
#import "PYEvent+JSON.h"
#import "PYStream.h"
#import "PYStream+JSON.h"

@interface PYCachingController ()
@property (nonatomic, retain) NSString *localDataPath;
@end

@implementation PYCachingController

@synthesize localDataPath = _localDataPath;

- (id)initWithCachingId:(NSString *)connectionCachingId
{
    self = [super init];
	if (self) {
		NSError *error = nil;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		self.localDataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:
                              [NSString
                                stringWithFormat:@"cache_%@", connectionCachingId]];
                              
        NSLog(@"self.localDataPath %@", self.localDataPath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:_localDataPath])
			[[NSFileManager defaultManager] createDirectoryAtPath:_localDataPath withIntermediateDirectories:NO attributes:nil error:&error];
		
	}
	return self;
}

- (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

- (BOOL)isDataCachedForKey:(NSString *)key
{
	return key && [[NSFileManager defaultManager] fileExistsAtPath:[self.localDataPath stringByAppendingPathComponent:key]];
}

- (void)cacheData:(NSData *)data withKey:(NSString *)key
{
    NSLog(@"*23 %@",key);
	if (key)
		[[NSFileManager defaultManager] createFileAtPath:[self.localDataPath stringByAppendingPathComponent:key] contents:data attributes:nil];
}

- (NSData *)dataForKey:(NSString *)key
{
    if (key)
        return [NSData dataWithContentsOfFile:[self.localDataPath stringByAppendingPathComponent:key]];
    return nil;
}


- (NSArray *)getAllFilesWithPredicateFormat:(NSString *)format
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.localDataPath error:nil];
    NSArray *filesWithSelectedPrefix = [files filteredArrayUsingPredicate:
                                        [NSPredicate predicateWithFormat:format]];
    return filesWithSelectedPrefix;

}

- (void)removeEntityWithKey:(NSString *)key
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.localDataPath stringByAppendingPathComponent:key]])
    {
        NSLog(@"WANT TO REMOVE BAD Entity: %@",key);
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.localDataPath stringByAppendingPathComponent:key] error:&error];
    if (error) {
        NSAssert(@"Error in removing entity", @"");
    }
}

- (void)removeStreamWithKey:(NSString *)key
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.localDataPath stringByAppendingPathComponent:key] error:&error];
    if (error) {
        NSAssert(@"Error in removing stream", @"");
    }
}

- (NSArray *)allEventsFromCache
{
    NSArray *filesWithSelectedPrefix = [self getAllFilesWithPredicateFormat:@"self BEGINSWITH[cd] 'event_'"];
    if (!filesWithSelectedPrefix.count) {
        return nil;
    }
    
    NSMutableArray *arrayOFCachedEvents = [[NSMutableArray alloc] init];
    for (NSString *eventCachedName in filesWithSelectedPrefix) {
        NSData *eventData = [self dataForKey:eventCachedName];
        NSDictionary *eventDic = [PYJSONUtility getJSONObjectFromData:eventData];
        [arrayOFCachedEvents
         addObject:[PYEvent _eventFromDictionary:eventDic]];
    }
    
    return [arrayOFCachedEvents autorelease];
}

- (PYEvent *)eventWithKey:(NSString *)key;
{
    if ([self isDataCachedForKey:key]) {
        NSData *eventData = [self dataForKey:key];
        NSDictionary *eventDic = [PYJSONUtility getJSONObjectFromData:eventData];
        return [PYEvent _eventFromDictionary:eventDic];
    }
    
    return nil;
}

- (PYEvent *)eventWithEventId:(NSString *)eventId;
{
    return [self eventWithKey:[self keyForEventId:eventId]];
}

- (NSArray *)allStreamsFromCache
{
    NSArray *filesWithSelectedPrefix = [self getAllFilesWithPredicateFormat:@"self BEGINSWITH[cd] 'stream_'"];
    if (!filesWithSelectedPrefix.count) {
        return nil;
    }
    
    NSMutableArray *arrayOFCachedStreams = [[NSMutableArray alloc] init];
    for (NSString *streamCachedName in filesWithSelectedPrefix) {
        NSDictionary *streamDic = [PYJSONUtility getJSONObjectFromData:[self dataForKey:streamCachedName]];
        [arrayOFCachedStreams addObject:[PYStream streamFromJSON:streamDic]];
    }
    
    return [arrayOFCachedStreams autorelease];
}

- (PYStream *)streamWithKey:(NSString *)key
{
    if ([self isDataCachedForKey:key]) {
        NSData *streamData = [self dataForKey:key];
        NSDictionary *streamDic = [PYJSONUtility getJSONObjectFromData:streamData];
        return [PYStream streamFromJSON:streamDic];
    }
    
    return nil;
}

- (void) dealloc
{
    [_localDataPath release];
    _localDataPath = nil;
    
    [super dealloc];
}

@end
