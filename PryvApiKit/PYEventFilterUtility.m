//
//  PYEventFilterUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterUtility.h"
#import "PYEventFilter.h"
#import "PYEvent.h"
#import "PYEventsCachingUtillity.h"
#import "PYChannel.h"

@implementation PYEventFilterUtility


+ (void)createEventsSyncDetails:(NSArray *)onlineEventList
                  offlineEvents:(NSArray *)cachedEvents
                    eventsToAdd:(NSMutableArray *)eventsToAdd
                 eventsToRemove:(NSMutableArray *)eventsToRemove
                 eventsModified:(NSMutableArray *)eventsModified
{
    PYEvent *onlineEvent;
    NSEnumerator *onlineEventsEnumerator = [onlineEventList objectEnumerator];
    while ((onlineEvent = [onlineEventsEnumerator nextObject]) != nil) {
        
        NSLog(@"onlineEventId %@",onlineEvent.eventId);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@",onlineEvent.eventId];
        NSArray *results = [cachedEvents filteredArrayUsingPredicate:predicate];
        
        PYEvent *cachedOnlineEvent;
        if (results.count == 0) {
            cachedOnlineEvent = nil;
        }else{
            cachedOnlineEvent = [results objectAtIndex:0];
        }
//        PYEvent *cachedOnlineEvent = [PYEventsCachingUtillity getEventFromCacheWithEventId:onlineEvent.eventId];
        
        if (!cachedOnlineEvent) {
            // if online event isn't in cache
            // TODO Add to app cache if not done by getEventsWithRequestType
            [eventsToAdd addObject:onlineEvent];
            
        } else if ([cachedOnlineEvent.modified compare:onlineEvent.modified] != NSOrderedSame){
            //If online event is in cache and if it's modified add to modified list
            [eventsModified addObject:onlineEvent];
        }else{
            //event is cached and not modified
            NSLog(@"event is cached and not modified");
        }
    }
    
    for (PYEvent *cachedEvent in cachedEvents) {
        
        NSArray *results;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@",cachedEvent.eventId];
        results = [onlineEventList filteredArrayUsingPredicate:predicate];
        
        if (results.count == 0) {
            // if cachedEvent not in onlineEventList ->
            [eventsToRemove addObject:cachedEvent];
            [PYEventsCachingUtillity removeEvent:cachedEvent];
            
        }

    }
}

+ (void)getAndCacheEventWithServerId:(NSString *)eventId
                     usingConnection:(PYConnection *)connection
                         requestType:(PYRequestType)reqType
{
    //In this method we will ask server for event with eventId and we'll cache it
    [connection getOnlineEventWithId:eventId
                      requestType:reqType
                   successHandler:^(PYEvent *event) {
                       
                       [PYEventsCachingUtillity cacheEvent:event];
        
                } errorHandler:^(NSError *error) {
                    NSLog(@"error");
                }];
}

+ (NSDictionary *)filteredEvents:(PYEventFilter *)filter
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    if (filter.fromTime != PYEventFilter_UNDEFINED_FROMTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.fromTime] forKey:kPrYvChannelEventFilterFromTime];
    }
    
    if (filter.toTime != PYEventFilter_UNDEFINED_TOTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.toTime] forKey:kPrYvChannelEventFilterToTime];
    }
    
    if (filter.limit > 0) {
        [dic setObject:[NSString stringWithFormat:@"%i",(unsigned int)filter.limit] forKey:kPrYvChannelEventFilterLimit];
    }
    
    //Doesn't work when sending - error in request parameters
    if (filter.onlyFoldersIDs != nil) {
        [dic setObject:filter.onlyFoldersIDs forKey:kPrYvChannelEventFilterOnlyFolders];
    }
    
    //Not implemeted in web service
    if (filter.tags != nil) {
        [dic setObject:filter.tags forKey:kPrYvChannelEventFilterTags];
//        [NSException raise:@"Not implemented" format:@"PYEventFilter.asDictionary tag matching is not yet implemented"];
    }
    
    return dic;
}

+ (NSArray *)filterCachedEvents:(NSArray *)cachedEventsArray withFilter:(PYEventFilter *)filter
{
    //    Would be nice to use  result = [eventErray filteredArrayUsingPredicate:[self predicate]];
    NSArray *result = [cachedEventsArray filteredArrayUsingPredicate:[self cachedEventsPredicateWithFilter:filter]];
    if (result.count > filter.limit)
    {
        NSArray *limitedArray = [result subarrayWithRange:NSMakeRange(0, filter.limit)];
        return  limitedArray;
    }
    return result;
}

+ (NSPredicate *)cachedEventsPredicateWithFilter:(PYEventFilter *)filter
{
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    NSPredicate *fromTimePredicate = nil;
    if (filter.fromTime != PYEventFilter_UNDEFINED_FROMTIME) {
        fromTimePredicate = [NSPredicate predicateWithFormat:@"time >= %f",filter.fromTime];
        [predicates addObject:fromTimePredicate];
    }
    NSPredicate *toTimePredicate = nil;
    if (filter.toTime != PYEventFilter_UNDEFINED_TOTIME) {
        toTimePredicate = [NSPredicate predicateWithFormat:@"time <= %f",filter.toTime];
        [predicates addObject:toTimePredicate];
    }
    NSPredicate *onlyFoldersPredicate = nil;
    if (filter.onlyFoldersIDs != nil) {
        onlyFoldersPredicate = [NSPredicate predicateWithFormat:@"folderId IN %@",filter.onlyFoldersIDs];
        [predicates addObject:onlyFoldersPredicate];
    }
    NSPredicate *onlyTagsPredicate = nil;
    if (filter.tags != nil) {
        onlyTagsPredicate = [NSPredicate predicateWithFormat:@"ANY tags IN %@",filter.tags];
        [predicates addObject:onlyTagsPredicate];
    }
    NSCompoundPredicate *testPredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    NSLog(@"subpredicates %@",testPredicate.subpredicates);
    [testPredicate release];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    return resultPredicate;
}



@end
