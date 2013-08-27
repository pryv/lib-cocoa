//
//  PryvCachingController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController.h"
#import "PYJSONUtility.h"
#import "PYEvent.h"
#import "PYEvent+JSON.h"
#import "PYEventFilter.h"
#import "PYStream.h"
#import "PYStream+JSON.h"

@interface PYCachingController ()
@property (nonatomic, retain) NSString *localDataPath;
@end

@implementation PYCachingController

@synthesize localDataPath = _localDataPath;

- init
{
    self = [super init];
	if (self) {
		NSError *error = nil;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		self.localDataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PYCachingController"];
        NSLog(@"self.localDataPath %@",self.localDataPath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:_localDataPath])
			[[NSFileManager defaultManager] createDirectoryAtPath:_localDataPath withIntermediateDirectories:NO attributes:nil error:&error];
		
	}
	return self;
}

- (BOOL)isDataCachedForKey:(NSString *)key
{
	return key && [[NSFileManager defaultManager] fileExistsAtPath:[self.localDataPath stringByAppendingPathComponent:key]];
}

- (void)cacheData:(NSData *)data withKey:(NSString *)key
{
	if (key)
		[[NSFileManager defaultManager] createFileAtPath:[self.localDataPath stringByAppendingPathComponent:key] contents:data attributes:nil];
}

- (NSData *)getDataForKey:(NSString *)key
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

- (void)removeEvent:(NSString *)key
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.localDataPath stringByAppendingPathComponent:key] error:&error];
    if (error) {
        NSAssert(@"Error in removing event", @"");
    }
}

- (void)removeStream:(NSString *)key
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self.localDataPath stringByAppendingPathComponent:key] error:&error];
    if (error) {
        NSAssert(@"Error in removing stream", @"");
    }
}

- (NSArray *)getAllEventsFromCache
{
    NSArray *filesWithSelectedPrefix = [self getAllFilesWithPredicateFormat:@"self BEGINSWITH[cd] 'event_'"];
    if (!filesWithSelectedPrefix.count) {
        return nil;
    }
    
    NSMutableArray *arrayOFCachedEvents = [[NSMutableArray alloc] init];
    for (NSString *eventCachedName in filesWithSelectedPrefix) {
        NSData *eventData = [self getDataForKey:eventCachedName];
        NSDictionary *eventDic = [PYJSONUtility getJSONObjectFromData:eventData];
        [arrayOFCachedEvents addObject:[PYEvent eventFromDictionary:eventDic]];
    }
    
    return arrayOFCachedEvents;
}

- (PYEvent *)getEventWithKey:(NSString *)key;
{
    if ([self isDataCachedForKey:key]) {
        NSData *eventData = [self getDataForKey:key];
        NSDictionary *eventDic = [PYJSONUtility getJSONObjectFromData:eventData];
        return [PYEvent eventFromDictionary:eventDic];
    }
    
    return nil;
}

- (NSArray *)getAllStreamsFromCache
{
    NSArray *filesWithSelectedPrefix = [self getAllFilesWithPredicateFormat:@"self BEGINSWITH[cd] 'stream_'"];
    if (!filesWithSelectedPrefix.count) {
        return nil;
    }
    
    NSMutableArray *arrayOFCachedStreams = [[NSMutableArray alloc] init];
    for (NSString *streamCachedName in filesWithSelectedPrefix) {
        NSDictionary *streamDic = [PYJSONUtility getJSONObjectFromData:[self getDataForKey:streamCachedName]];
        [arrayOFCachedStreams addObject:[PYStream streamFromJSON:streamDic]];
    }
    
    return arrayOFCachedStreams;
}

- (PYStream *)getStreamWithKey:(NSString *)key
{
    if ([self isDataCachedForKey:key]) {
        NSData *streamData = [self getDataForKey:key];
        NSDictionary *streamDic = [PYJSONUtility getJSONObjectFromData:streamData];
        return [PYStream streamFromJSON:streamDic];
    }
    
    return nil;
}

+ (id)sharedManager {
    static PYCachingController *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

@end
