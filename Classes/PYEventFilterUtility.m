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
#import "PYConnection+FetchedStreams.h"
#import "PYStream+Utils.h"

@implementation PYEventFilterUtility


+ (void)createEventsSyncDetails:(NSArray *)onlineEventList
                  knownEvents:(NSArray *)knownEvents
                    eventsToAdd:(NSMutableArray *)eventsToAdd
                 eventsToRemove:(NSMutableArray *)eventsToRemove
                 eventsModified:(NSMutableArray *)eventsModified
{
    PYEvent *onlineEvent;
    NSEnumerator *onlineEventsEnumerator = [onlineEventList objectEnumerator];
    while ((onlineEvent = [onlineEventsEnumerator nextObject]) != nil) {
        
        //NSLog(@"onlineEventId %@",onlineEvent.eventId);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@",onlineEvent.eventId];
        NSArray *results = [knownEvents filteredArrayUsingPredicate:predicate];
        
        PYEvent *cachedOnlineEvent;
        if (results.count == 0) {
            cachedOnlineEvent = nil;
        }else{
            cachedOnlineEvent = [results objectAtIndex:0];
        }
        
        if (!cachedOnlineEvent) {
            // if online event isn't in cache
            // TODO Add to app cache if not done by getEventsWithRequestType
            [eventsToAdd addObject:onlineEvent];
            
        } else if (cachedOnlineEvent.modified != onlineEvent.modified){
            //If online event is in cache and if it's modified add to modified list
            [eventsModified addObject:onlineEvent];
        }else{
            //event is cached and not modified
            // NSLog(@"event is cached and not modified");
        }
    }
    [PYEventFilter sortNSMutableArrayOfPYEvents:eventsToAdd sortAscending:YES];
    [PYEventFilter sortNSMutableArrayOfPYEvents:eventsToRemove sortAscending:YES];
    [PYEventFilter sortNSMutableArrayOfPYEvents:eventsModified sortAscending:YES];
}


+ (NSDictionary *)apiParametersForEventsRequestFromFilter:(PYEventFilter *)filter
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    if (filter == nil) return dic;
    if (filter.fromTime != PYEventFilter_UNDEFINED_FROMTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.fromTime] forKey:kPYAPIEventFilterFromTime];
    }
    
    if (filter.toTime != PYEventFilter_UNDEFINED_TOTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.toTime] forKey:kPYAPIEventFilterToTime];
    }
    
    if (filter.limit > 0) {
        [dic setObject:[NSString stringWithFormat:@"%i",(unsigned int)filter.limit] forKey:kPYAPIEventFilterLimit];
    }
    
    //Doesn't work when sending - error in request parameters
    if (filter.onlyStreamsIDs != nil) {
        [dic setObject:filter.onlyStreamsIDs forKey:kPYAPIEventFilterOnlyStreams];
    }
    
    if (filter.modifiedSince != PYEventFilter_UNDEFINED_FROMTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.modifiedSince] forKey:kPYAPIEventModifiedSinceTime];
    }
    
    
    if (filter.tags != nil) {
        [dic setObject:filter.tags forKey:kPYAPIEventFilterTags];
    }
    
    if (filter.types != nil) {
        [dic setObject:filter.types forKey:kPYAPIEventFilterTypes];
    }
    
    return dic;
}

+ (NSArray *)filterEventsList:(NSArray *)events withFilter:(PYEventFilter *)filter
{
    
    NSMutableArray *result = [[NSMutableArray alloc]
                              initWithArray:[events filteredArrayUsingPredicate:[self predicateFromFilter:filter]]];
    [PYEventFilter sortNSMutableArrayOfPYEvents:result sortAscending:YES];
    if (result.count > filter.limit)
    {
        NSArray *limitedArray = [result subarrayWithRange:NSMakeRange(0, filter.limit)];
        [result release];
        return  limitedArray;
    }
    return [result autorelease];
}

+ (NSArray *)streamIdsCoveredByFilter:(PYEventFilter *)filter
{
    if (! filter.onlyStreamsIDs) return nil;
    NSMutableSet *result = [[[NSMutableSet alloc] init] autorelease];
  
    for (NSString* streamId in filter.onlyStreamsIDs) {
        PYStream* stream = [filter.connection streamWithStreamId:streamId];
        if (!stream) {
            [result addObject:streamId];
        } else {
            [result addObjectsFromArray:[stream descendantsIds]];
        }
    }
    
    return [result allObjects];
}

+ (NSPredicate *)predicateFromFilter:(PYEventFilter *)filter
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
    NSPredicate *onlyStreamsPredicate = nil;
    if (filter.onlyStreamsIDs != nil) {
        // find all children of this stream
        onlyStreamsPredicate = [NSPredicate predicateWithFormat:@"streamId IN %@",[self streamIdsCoveredByFilter:filter]];
        [predicates addObject:onlyStreamsPredicate];
    }
    NSPredicate *onlyTagsPredicate = nil;
    if (filter.tags != nil) {
        onlyTagsPredicate = [NSPredicate predicateWithFormat:@"ANY tags IN %@",filter.tags];
        [predicates addObject:onlyTagsPredicate];
    }
    //TODO check this
   NSPredicate *onlyTypesPredicate = nil;
    if (filter.types != nil) {
        NSLog(@"<WARNING> type predicate may not support widcards searches");
        onlyTypesPredicate = [NSPredicate predicateWithFormat:@"type IN %@",filter.types];
        [predicates addObject:onlyTypesPredicate];
    }
    // Perki 8.jan 2014 what's for?
    NSCompoundPredicate *testPredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    NSLog(@"subpredicates %@",testPredicate.subpredicates);
    [testPredicate release];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [predicates release];
    return resultPredicate;
}



@end
