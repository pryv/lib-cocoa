//
//  PYEventFilter.m
//  PryvApiKit
//
//  Created by Pierre-Mikael Legris on 30.05.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
//
//  PYFilter is a seprated object for future optimization and Socket.io usage
//
//
//  Usage: An app create a Filter then call refresh() to get new events
//
//  In the future we should add a Filter.listen(delegate)
//
//

#import "PYEventFilter.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYEvent.h"
#import "PYEventFilterUtility.h"


@interface PYEventFilter ()
- (void)connectionEventUpdate:(NSNotification *)notification;
@end

@implementation PYEventFilter


@synthesize connection = _connection;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize limit = _limit;
@synthesize onlyStreamsIDs = _onlyStreamsIDs;
@synthesize tags = _tags;
@synthesize types = _types;

@synthesize modifiedSince = _modifiedSince;

@synthesize currentEventsDic = _currentEventsDic;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //TODO check that it's necessary
    [_currentEventsDic release];
    _currentEventsDic = nil;
    _connection  = nil;
    [_onlyStreamsIDs release];
    [_tags release];
    [_types release];
    [super dealloc];
}

- (id)initWithConnection:(PYConnection*)connection
                fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                   limit:(NSUInteger)limit
          onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                    tags:(NSArray *)tags
{
    return [self initWithConnection:connection fromTime:fromTime toTime:toTime
                              limit:limit onlyStreamsIDs:onlyStreamsIDs tags:tags types:nil];
}

- (id)initWithConnection:(PYConnection*)connection
                fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                   limit:(NSUInteger)limit
          onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                    tags:(NSArray *)tags
                   types:(NSArray *)types
{
    if (self = [super init]) {
        _connection = connection;
        [self changeFilterFromTime:fromTime
                            toTime:toTime
                             limit:limit
                    onlyStreamsIDs:onlyStreamsIDs
                              tags:tags
                             types:types];
        _modifiedSince = PYEventFilter_UNDEFINED_FROMTIME;
        _currentEventsDic = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEventUpdate:)
                                                     name:kPYNotificationEvents object:self.connection];
        
    }
    return self;
}


- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags
{
    [self changeFilterFromTime:fromTime toTime:toTime limit:limit
                onlyStreamsIDs:onlyStreamsIDs tags:tags types:nil];
}

- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags
                        types:(NSArray *)types
{
    self.fromTime = fromTime; // time question ?? shouldn't we align time with the server?
    self.toTime = toTime;
    self.onlyStreamsIDs = onlyStreamsIDs;
    self.tags = tags;
    self.limit = limit;
    self.types = types;
}

- (void)notifyEventsToAdd:(NSArray*)srcAdd toRemove:(NSArray*)srcRemove modified:(NSArray*)srcModified
{
    
    NSMutableArray *resultAdd = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *resultRemove = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *resultModify = [[[NSMutableArray alloc] init] autorelease];
    
    ///  /!\ AT WORK - Proof of concept
    ///
    ///  Missing: just add what's not present .. and remove that need to removed
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    PYEvent* event;
    if (srcAdd != nil) {
        NSEnumerator *toAddEnumerator = [srcAdd objectEnumerator];
        while ((event = [toAddEnumerator nextObject]) != nil) {
            if ([self.currentEventsDic objectForKey:event.clientId] == nil) {
                [self.currentEventsDic setValue:event forKey:event.clientId];
                [resultAdd addObject:event];
            }
        }
        [userInfo setObject:resultAdd forKey:kPYNotificationKeyAdd];
    }
    if (srcRemove != nil) {
        
        NSEnumerator *toRemoveEnumerator = [srcRemove objectEnumerator];
        while ((event = [toRemoveEnumerator nextObject]) != nil) {
            [self.currentEventsDic removeObjectForKey:event.clientId];
            [resultRemove addObject:event];
        }
        [userInfo setObject:resultRemove forKey:kPYNotificationKeyDelete];
    }
    if (srcModified != nil) {
       
        NSEnumerator *toModifiyEnumerator = [srcModified objectEnumerator];
        while ((event = [toModifiyEnumerator nextObject]) != nil) {
            if ([self.currentEventsDic objectForKey:event.clientId] != nil) { // known object
                [resultModify addObject:event];
            }
        }
        [userInfo setObject:resultModify forKey:kPYNotificationKeyModify];
    }
    
    if ((resultAdd.count + resultRemove.count + resultModify.count) == 0 ) {
        NSLog(@"*42 void Filter notification.. no changes detected ");
        [userInfo release];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPYNotificationEvents
     object:self
     userInfo:userInfo];
    [userInfo release];
}


/**
 * The list represent 
 * @param eventList complete list of events that should match the filter
 */
- (void)synchWithList:(NSArray*) eventList {
    
    NSMutableArray *eventsToAdd = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *eventsToRemove = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *eventsModified = [[[NSMutableArray alloc] init] autorelease];
    
    [PYEventFilterUtility createEventsSyncDetails:eventList
                                      knownEvents:self.currentEventsSet
                                      eventsToAdd:eventsToAdd
                                   eventsToRemove:eventsToRemove
                                   eventsModified:eventsModified];
    
    [self notifyEventsToAdd:eventsToAdd toRemove:eventsToRemove modified:eventsModified];
}

- (NSArray*)currentEventsSet
{
    // TODO check order
    return [_currentEventsDic allValues];
}


- (void)update
{
    // no need to handle the events, it will be done by the notification listner
    //[self.connection eventsWithFilter:self fromCache:nil andOnline:nil onlineDiffWithCached:nil errorHandler:nil];
    
    [self.connection eventsWithFilter:self
                            fromCache:^(NSArray *cachedEventList) {
                                  [self synchWithList:cachedEventList];
                          
                            } andOnline:^(NSArray *onlineEventList, NSNumber *serverTime) {
                                  
                                # warning should be uncommentend .. keep self.modified if no property has been changed since last update
                                  //self.modifiedSince = [serverTime doubleValue];
                                  [self synchWithList:onlineEventList];
                                  
                              } onlineDiffWithCached:nil
                                 errorHandler:^(NSError *error) {
                                  
                              }];
}


#pragma mark - notifications from connection

- (void)connectionEventUpdate:(NSNotification *)notification
{
    
    NSDictionary *message = (NSDictionary*) notification.userInfo;
    
    PYEventFilter* sender = [message objectForKey:kPYNotificationWithFilter];
    if (sender == self) {
        NSLog(@"<NOTICE> skipping notification as I'm the sender");
        return;
    }
    
    NSArray* toAdd = [PYEventFilterUtility
                      filterEventsList:[message objectForKey:kPYNotificationKeyAdd] withFilter:self];
    NSArray* toRemove = [PYEventFilterUtility
                         filterEventsList:[message objectForKey:kPYNotificationKeyDelete] withFilter:self];
    NSArray* modify = [PYEventFilterUtility
                       filterEventsList:[message objectForKey:kPYNotificationKeyModify] withFilter:self];
    
    [self notifyEventsToAdd:toAdd toRemove:toRemove modified:modify];
}

#pragma mark - Utilities sort

/**
 * Untested
 */
NSComparisonResult _compareEventByTimeAsc( PYEvent* e1, PYEvent* e2, void* ignore)
{
    NSTimeInterval t1 = [e1 getEventServerTime];
    NSTimeInterval t2 = [e2 getEventServerTime];
    if (t1 < t2)
        return NSOrderedAscending;
    else if (t1 > t2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

/**
 * Untested
 */
NSComparisonResult _compareEventByTimeDesc( PYEvent* e1, PYEvent* e2, void* ignore)
{
    NSTimeInterval t1 = [e1 getEventServerTime];
    NSTimeInterval t2 = [e2 getEventServerTime];
    if (t1 > t2)
        return NSOrderedAscending;
    else if (t1 < t2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

+ (void)sortNSMutableArrayOfPYEvents:(NSMutableArray *)events sortAscending:(BOOL)sortAscending {
    /** Sort untested **/
    if (sortAscending) {
        [events sortUsingFunction:_compareEventByTimeAsc context:nil];
    } else {
        [events sortUsingFunction:_compareEventByTimeDesc context:nil];
    }
}

@end
