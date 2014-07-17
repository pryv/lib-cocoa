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
#import "PYConnection+Events.h"
#import "PYEvent.h"
#import "PYEventFilterUtility.h"


@interface PYEventFilter ()
- (void)connectionEventUpdate:(NSNotification *)notification;
@end

@implementation PYEventFilter


@synthesize currentEventsDic = _currentEventsDic;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //TODO check that it's necessary
    [_currentEventsDic release];
    _currentEventsDic = nil;
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
    if (self = [super initWithConnection:connection fromTime:fromTime toTime:toTime
                                   limit:limit onlyStreamsIDs:onlyStreamsIDs tags:tags types:types]) {
       
            _currentEventsDic = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionEventUpdate:)
                                                     name:kPYNotificationEvents object:connection];
        
    }
    return self;
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
    NSDate* afx = [NSDate date];
    [PYEventFilterUtility createEventsSyncDetails:eventList
                                      knownEvents:self.currentEventsSet
                                      eventsToAdd:eventsToAdd
                                   eventsToRemove:eventsToRemove
                                   eventsModified:eventsModified];
    NSLog(@"*afx %f", [afx timeIntervalSinceNow]);
    
    [self notifyEventsToAdd:eventsToAdd toRemove:eventsToRemove modified:eventsModified];
}

- (void)notifyWithOnlineListSinceLastUpdate:(NSArray*) eventList {
    
    
    NSMutableArray *resultAdd = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *resultModify = [[[NSMutableArray alloc] init] autorelease];
    
    ///  /!\ AT WORK - Proof of concept
    ///
    ///  Missing: just add what's not present .. and remove that need to removed
    
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
    PYEvent* event;
    if (eventList != nil) {
        NSEnumerator *toAddEnumerator = [eventList objectEnumerator];
        while ((event = [toAddEnumerator nextObject]) != nil) {
            if ([self.currentEventsDic objectForKey:event.clientId] == nil) {
                [self.currentEventsDic setValue:event forKey:event.clientId];
                [resultAdd addObject:event];
            } else {
                [resultModify addObject:event];
            }
        }
        [userInfo setObject:resultAdd forKey:kPYNotificationKeyAdd];
        [userInfo setObject:resultModify forKey:kPYNotificationKeyAdd];
    }
    
    if ((resultAdd.count + resultModify.count) == 0 ) {
        NSLog(@"*43 void Filter notification.. no changes detected ");
        [userInfo release];
        return;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kPYNotificationEvents
     object:self
     userInfo:userInfo];
    [userInfo release];

}


- (NSArray*)currentEventsSet
{
    // TODO check order
    return [_currentEventsDic allValues];
}


- (void)update
{
    
    NSArray* toAdd = [PYEventFilterUtility
                      filterEventsList:[self.connection allEvents] withFilter:self];
    [self notifyEventsToAdd:toAdd toRemove:nil modified:nil];
    
    
    
    // no need to handle the events, it will be done by the notification listner
    //[self.connection eventsWithFilter:self fromCache:nil andOnline:nil onlineDiffWithCached:nil errorHandler:nil];
    
    // first of all clean up actual list of event
    
    NSPredicate* predicate = [PYEventFilterUtility predicateFromFilter:self];
    NSMutableArray *eventsToRemove = [[[NSMutableArray alloc] init] autorelease];
    NSEnumerator *currentEventsEnumerator = [self.currentEventsSet objectEnumerator];
    PYEvent* event;
    while ((event = [currentEventsEnumerator nextObject]) != nil) {
        if (! [predicate evaluateWithObject:event]) {
            [eventsToRemove addObject:event];
        }
    }
    [self notifyEventsToAdd:nil toRemove:eventsToRemove modified:nil];
    
    
    // -- if filter is matching the cache.. just update the cache
    
    
    if (! [self.connection updateCache:nil ifCacheIncludes:self]) {
        
        
        
        // -- check online
      
        
        [self.connection eventsWithFilter:self
                                fromCache:^(NSArray *cachedEventList) {
                                    [self synchWithList:cachedEventList];
                                    
                                } andOnline:^(NSArray *onlineEventList, NSNumber *serverTime) {

                                    [self notifyWithOnlineListSinceLastUpdate:onlineEventList];
                                    
                                } onlineDiffWithCached:nil
                             errorHandler:^(NSError *error) {
                                 
                             }];
    }
    
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
    
    NSArray* modify = [PYEventFilterUtility
                       filterEventsList:[message objectForKey:kPYNotificationKeyModify] withFilter:self];
    
    [self notifyEventsToAdd:toAdd toRemove:[message objectForKey:kPYNotificationKeyDelete] modified:modify];
}

#pragma mark - Utilities sort

@end
