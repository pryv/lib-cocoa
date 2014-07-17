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
@property (nonatomic) dispatch_queue_t queue;

- (NSArray *)_getAllFilesWithPredicateFormat:(NSString *)format;
- (void)_backgroundSaveAllEvents;

@end

@implementation PYCachingController

@synthesize localDataPath = _localDataPath;
@synthesize allEventsDictionary = _allEventsDictionary;
@synthesize queue = _queue;

#pragma mark - id to disk manipulations

- (id)initWithCachingId:(NSString *)connectionCachingId
{
    self = [super init];
	if (self) {
        self.queue = dispatch_queue_create("com.domain.app.savequeue", 0);
		NSError *error = nil;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		self.localDataPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:
                              [NSString
                               stringWithFormat:@"cache_%@", connectionCachingId]];
        
        NSLog(@"self.localDataPath %@", self.localDataPath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:_localDataPath])
			[[NSFileManager defaultManager] createDirectoryAtPath:_localDataPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        NSDictionary* savedDict = [PYJSONUtility getJSONObjectFromData:[self dataForKey:@"cachedEvents"]];
        if (savedDict) {
            self.allEventsDictionary = [[NSMutableDictionary alloc] initWithDictionary:savedDict];
        } else {
            self.allEventsDictionary = [[NSMutableDictionary alloc] init];
        }
        
	}
	return self;
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

- (void)moveEntityWithKey:(NSString *)src toKey:(NSString *)dst
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.localDataPath stringByAppendingPathComponent:src]])
    {
        NSLog(@"WANT TO MOVE BAD Entity: %@",src);
    }
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:[self.localDataPath stringByAppendingPathComponent:src]
                                            toPath:[self.localDataPath stringByAppendingPathComponent:dst] error:&error];
    if (error) {
        NSAssert(@"Error in moving entity: %@ to %@", src, dst);
    }
}

- (NSArray *)_getAllFilesWithPredicateFormat:(NSString *)format
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.localDataPath error:nil];
    NSArray *filesWithSelectedPrefix = [files filteredArrayUsingPredicate:
                                        [NSPredicate predicateWithFormat:format]];
    return filesWithSelectedPrefix;
    
}

#pragma mark - streams


- (NSArray *)allStreams
{
    NSDictionary *streamListDic = [PYJSONUtility getJSONObjectFromData:[self dataForKey:@"fetchedStreams"]];
    NSMutableArray *streamList = [[NSMutableArray alloc] init];
    for (NSDictionary *streamDictionary in streamListDic) {
        PYStream *stream = [PYStream streamFromJSON:streamDictionary];
        [streamList addObject:stream];
    }
    
    return [streamList autorelease];
}


# pragma mark - events

- (NSArray *)allEvents
{
    NSMutableArray *arrayOFCachedEvents = [[NSMutableArray alloc] init];
    for (NSString *eventCachedName in self.allEventsDictionary) {
        NSDictionary *eventDic = [self.allEventsDictionary objectForKey:eventCachedName];
        [arrayOFCachedEvents addObject:[PYEvent _eventFromDictionary:eventDic]];
    }
    
    return [arrayOFCachedEvents autorelease];
}

BOOL _eventsNeedSave = NO;

- (void)saveAllEvents
{
     NSLog(@"*545 requires saving events");
    _eventsNeedSave = YES;
    dispatch_async(self.queue, ^{
        [self _backgroundSaveAllEvents];
    });
}

- (void)_backgroundSaveAllEvents
{
    @synchronized(self) {
        if (_eventsNeedSave) {
            _eventsNeedSave = NO;
            NSLog(@"*545 Saving events A");
            [self cacheData:[PYJSONUtility getDataFromJSONObject:self.allEventsDictionary] withKey:@"cachedEvents"];
            NSLog(@"*546 Saving events B");
        } else {
            NSLog(@"*547 Skipping save.. not needed");
        }
    }
}



- (PYEvent *)eventWithKey:(NSString *)key;
{
    NSDictionary* eventDict = [self.allEventsDictionary objectForKey:key];
    if (eventDict) {
        return [PYEvent _eventFromDictionary:eventDict];
    }
    
    return nil;
}

- (PYEvent *)eventWithEventId:(NSString *)eventId;
{
    return [self eventWithKey:[self keyForEventId:eventId]];
}

#pragma mark - memory

- (void) dealloc
{
    [_localDataPath release];
    _localDataPath = nil;
    [_allEventsDictionary release];
    _allEventsDictionary = nil;
    [super dealloc];
}

@end
