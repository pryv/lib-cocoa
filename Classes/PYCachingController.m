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
    [self managedObjectContext];
    
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


- (NSArray *)getAllFilesWithPredicateFormat:(NSString *)format
{
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.localDataPath error:nil];
    NSArray *filesWithSelectedPrefix = [files filteredArrayUsingPredicate:
                                        [NSPredicate predicateWithFormat:format]];
    return filesWithSelectedPrefix;

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


- (void) resetEventFromDictionary:(PYEvent*)event
{
    NSString* key = [self keyForEventId:event.eventId];
    if (key && [self isDataCachedForKey:key])
    {
        NSData *eventData = [self dataForKey:key];
        NSDictionary *eventDic = [PYJSONUtility getJSONObjectFromData:eventData];
        [event resetFromDictionary:eventDic];
    }
    
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
    NSDictionary *streamListDic = [PYJSONUtility getJSONObjectFromData:[self dataForKey:@"fetchedStreams"]];
    NSMutableArray *streamList = [[NSMutableArray alloc] init];
    for (NSDictionary *streamDictionary in streamListDic) {
        PYStream *stream = [PYStream streamFromJSON:streamDictionary];
        [streamList addObject:stream];
    }
    
    return [streamList autorelease];
}


- (void) dealloc
{
    [_localDataPath release];
    _localDataPath = nil;
    
    [super dealloc];
}

#pragma mark - core data

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

static NSManagedObjectModel *_sharedManagedObjectModel = nil;

+ (NSManagedObjectModel *)sharedManagedObjectModel
{
    if (_sharedManagedObjectModel != nil) {
        return _sharedManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PYCache" withExtension:@"momd"];
    _sharedManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _sharedManagedObjectModel;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
  return [PYCachingController sharedManagedObjectModel];
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PYKit.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
