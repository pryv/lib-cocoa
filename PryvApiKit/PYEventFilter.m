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
#import "PYEvent.h"
#import "PYClient.h"
#import "PYEventsCachingUtillity.h"
#import "PYConstants.h"

@implementation PYEventFilter

@synthesize channel = _channel;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize limit = _limit;
@synthesize onlyFoldersIDs = _onlyFoldersIDs;
@synthesize tags = _tags;

@synthesize lastRefresh = _lastRefresh;


- (id)initWithChannel:(PYChannel*)channel
             fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                limit:(NSUInteger)limit
           onlyFoldersIDs:(NSArray *)onlyFoldersIDs
                  tags:(NSArray *)tags
{
    if (self = [super init]) {
        _channel = channel;
        [self changeFilterFromTime:fromTime
                            toTime:toTime
                             limit:limit
                    onlyFoldersIDs:onlyFoldersIDs
                              tags:tags];
        _lastRefresh = PYEventFilter_UNDEFINED_FROMTIME;
    }
    return self;
}

- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyFoldersIDs:(NSArray *)onlyFoldersIDs
                        tags:(NSArray *)tags
{
    _fromTime = fromTime; // time question ?? shouldn't we align time with the server?
    _toTime = toTime;
    _onlyFoldersIDs = onlyFoldersIDs;
    _tags = tags;
    _limit = limit;
}

/**
 * process can be considered as finished when both lists has been received
 */
- (void)getEventsWithRequestType:(PYRequestType)reqType
                 gotCachedEvents:(void (^) (NSArray *eventList))gotCachedEvents
                 gotOnlineEvents:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))gotOnlineEvents
                    errorHandler:(void (^) (NSError *error))errorHandler
{
    // get all event cached matching this filter
    // question should we use forKey:@"CachedEvents" ?
    NSArray *allEventsFromCache = [PYEventsCachingUtillity getEventsFromCache];
    
    NSMutableArray* cachedEvents = [self filterCachedEvents:allEventsFromCache];
    gotCachedEvents(cachedEvents);
    
    // TODO convert cachedEvents into a Dictionary where we can find events by their id (or make a PYEventsCachingUtillity return a NSDictonary)
//    NSDictionary* cachedEventsDir = nil;
    
    // get ALL online events matching this request .. This can be optimized if the API provides journaling
    [_channel getEventsWithRequestType:reqType
                              filter:[self dictionaryFromFilter]
                         successHandler:^(NSArray *onlineEventList) {
                             // TODO UPDATE self.lastRefresh
                             
                             NSMutableArray *eventsToAdd = [[[NSMutableArray alloc] init] autorelease];
                             NSMutableArray *eventsToRemove = [[[NSMutableArray alloc] init] autorelease];
                             NSMutableArray *eventsModified = [[[NSMutableArray alloc] init] autorelease];
                             
                             PYEvent *onlineEvent;
                             PYEvent *cachedEvent;
                             NSEnumerator *onlineEventsEnumerator = [onlineEventList objectEnumerator];
                             while ((onlineEvent = [onlineEventsEnumerator nextObject]) != nil) {
                                 NSLog(@"onlineEventId %@",onlineEvent.eventId);
                                 cachedEvent = [PYEventsCachingUtillity getEventFromCacheWithEventId:onlineEvent.eventId];
                                 
                                 // if event not in sent cache
                                 if (!cachedEvent) {
                                     // TODO Add to app cache if not done by getEventsWithRequestType
                                     [eventsToAdd addObject:onlineEvent];
                                     [PYEventsCachingUtillity cacheEvent:onlineEvent];
                                     
                                 } else if ([cachedEvent.modified compare:onlineEvent.modified] != NSOrderedSame){
                                     [eventsModified addObject:onlineEvent];
                                 }
                             }
                             
                             // find object that are not present anymore
                             for (PYEvent *cachedEvent in cachedEvents) {
                                 BOOL isInOnlineList = NO;
                                 for (PYEvent *onlineEvent in onlineEventList) {
                                     if ([cachedEvent.eventId compare:onlineEvent.eventId] == NSOrderedSame) {
                                         isInOnlineList = YES;
                                         break;
                                     }
                                 }
                                 if (isInOnlineList == NO) {
                                     // if cachedEvent not in onlineEventList ->
                                     [eventsToRemove addObject:cachedEvent];
                                 }
                             }
                             
                             gotOnlineEvents(eventsToAdd, eventsToRemove, eventsModified);
                             
                         }
                        errorHandler:errorHandler];
}

/** 
 * TODO may be nice to get a predicate out of this filer 
 *
 **/
-(NSPredicate *)predicate
{
//    NSString *value = @"TTZ3TJ0xt5";
//    NSPredicate *workingPredicate = [NSPredicate predicateWithFormat:@"eventId == %@",value];    
    
    //@"time >= %f AND time <= %f AND ALL tags IN %@ AND folderId IN %@"
    NSString *predicateStr = @"time >= %f AND time <= %f AND ALL tags IN %@";
    NSPredicate *fromTimeP = [NSPredicate predicateWithFormat:predicateStr,
                              self.fromTime,
                              self.toTime,
                              self.tags];
    
    return fromTimeP;
}

/**
 * To pass in an API request
 * DRAFT CODE UNTESTED
 **/
-(NSDictionary *)dictionaryFromFilter
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    if (self.fromTime != PYEventFilter_UNDEFINED_FROMTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",self.fromTime] forKey:kPrYvChannelEventFilterFromTime];
    }
    
    if (self.toTime != PYEventFilter_UNDEFINED_TOTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",self.toTime] forKey:kPrYvChannelEventFilterToTime];
    }
    
    if (self.limit > 0) {
        [dic setObject:[NSString stringWithFormat:@"%i",self.limit] forKey:kPrYvChannelEventFilterLimit];
    }
    
    if (self.onlyFoldersIDs != nil) {
        [dic setObject:self.onlyFoldersIDs forKey:kPrYvChannelEventFilterOnlyFolders];
    }
    

//    if (self.tags != nil) {
//        [NSException raise:@"Not implemented" format:@"PYEventFilter.asDictionary tag matching is not yet implemented"];
//    }
    
    return dic;
}

-(BOOL) matchEvent:(PYEvent *)event
{
    if (self.fromTime > event.time) { return false; }
    
    if (self.toTime < event.time) { return false; }
    
    
    if ((self.onlyFoldersIDs != nil) &&
        ([self.onlyFoldersIDs indexOfObject:event.folderId] == NSNotFound)) {
        return false;
    }
    
//    if (self.tags != nil) {
//        [NSException raise:@"Not implemented" format:@"PYEventFilter.matchEvent tag matching is not yet implemented"];
//    }
    
    return true;
}

-(NSMutableArray *)filterCachedEvents:(NSArray *)cachedEventsArray
{
//    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    
    NSArray *result = [cachedEventsArray filteredArrayUsingPredicate:[self predicate]];
    return [result mutableCopy];
    
    // Would be nice to use  result = [eventErray filteredArrayUsingPredicate:[self predicate]];
//    NSEnumerator *e = [cachedEventsArray objectEnumerator];
//    PYEvent *event;
//
//    int count = 0;
//    while (((event = [e nextObject]) != nil) &&  [self matchEvent:event]) {
//        [result addObject:event];
//        count++;
//        if (self.limit > 0 && count >= self.limit) {
//            return result;
//        }
//    }

    
    return result;
}

+(void)sortNSMutableArrayOfPYEvents:(NSMutableArray *)events sortAscending:(BOOL)sortAscending {
    /** Sort untested **/
    if (sortAscending) {
        [events sortUsingFunction:_compareEventByTimeAsc context:nil];
    } else {
        [events sortUsingFunction:_compareEventByTimeDesc context:nil];
    }
}


/**
 * Untested
 */
NSComparisonResult _compareEventByTimeAsc( PYEvent* e1, PYEvent* e2, void* ignore)
{
    NSTimeInterval t1 = [e1 time];
    NSTimeInterval t2 = [e2 time];
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
    NSTimeInterval t1 = [e1 time];
    NSTimeInterval t2 = [e2 time];
    if (t1 > t2)
        return NSOrderedAscending;
    else if (t1 < t2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

@end
