//
//  PYEventFilterUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterUtility.h"
#import "PYFilter.h"
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
            // TODO Add to app cache if not done by getEvents
            [eventsToAdd addObject:onlineEvent];
            
        } else if (cachedOnlineEvent.modified != onlineEvent.modified){
            //If online event is in cache and if it's modified add to modified list
            [eventsModified addObject:onlineEvent];
        }else{
            //event is cached and not modified
            // NSLog(@"event is cached and not modified");
        }
    }
    
    // eventsNotPresent in onlineEventList and Present in knownEvent
    PYEvent *knownEvent;
    NSEnumerator *knownEventsEnumerator = [knownEvents objectEnumerator];
    while ((knownEvent = [knownEventsEnumerator nextObject]) != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@", knownEvent.eventId];
        NSArray *results = [onlineEventList filteredArrayUsingPredicate:predicate];
 
        if (results.count == 0) {
            [eventsToRemove addObject:knownEvent];
        }
    }
    
    
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:eventsToAdd sortAscending:YES];
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:eventsToRemove sortAscending:YES];
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:eventsModified sortAscending:YES];
}


+ (NSDictionary *)apiParametersForEventsRequestFromFilter:(PYFilter *)filter
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
    
    if (PYEventFilter_kStateArray[filter.state] != nil) {
      [dic setObject:PYEventFilter_kStateArray[filter.state] forKey:kPYAPIEventFilterState];
    }
    
    
    
    return dic;
}


/**
 * does not consider modified since
 */
+ (BOOL)filter:(PYFilter*)srcFilter isIncludedInFilter:(PYFilter*)destFilter {

    if (destFilter.fromTime > srcFilter.fromTime) return NO;
    
    if (destFilter.toTime < srcFilter.toTime) return NO;
    
    if (destFilter.limit < srcFilter.limit) return NO;
    
#warning - check this
    if (destFilter.onlyStreamsIDs != nil) {
        if (srcFilter.onlyStreamsIDs == nil) return NO; // not good nil.. may cover all :(
        NSSet *srcSet = [NSSet setWithArray:[self streamIdsCoveredByFilter:srcFilter]];
        if (! [srcSet isSubsetOfSet:[NSSet setWithArray:[self streamIdsCoveredByFilter:destFilter]]]) return NO;
    }
    
    if (destFilter.tags != nil) {
        if (srcFilter.tags == nil) return NO; // not good nil.. may cover all :(
        NSSet *srcSet = [NSSet setWithArray:srcFilter.tags];
        if (! [srcSet isSubsetOfSet:[NSSet setWithArray:destFilter.tags]]) return NO;
    }
    
   
    
    if (destFilter.onlyStreamsIDs != nil) {
#warning - todo quick
        NSLog(@"<WARNING> PYEventFilterUtility incomplet (BOOL)filter:(PYFilter*)srcFilter isIncludedInFilter:(PYFilter*)destFilter  checjk");
    }
    
    if (destFilter.state != PYEventFilter_kStateAll) {
        if (destFilter.state != srcFilter.state) return NO;
    }
    return YES;
}

+ (NSArray *)filterEventsList:(NSArray *)events withFilter:(PYFilter *)filter
{
    
    NSMutableArray *result = [[NSMutableArray alloc]
                              initWithArray:[events filteredArrayUsingPredicate:[self predicateFromFilter:filter]]];
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:result sortAscending:YES];
    /**
    if (result.count > filter.limit)
    {
        NSArray *limitedArray = [result subarrayWithRange:NSMakeRange(0, filter.limit)];
        [result release];
        return  limitedArray;
    }**/
    return [result autorelease];
}

+ (NSArray *)streamIdsCoveredByFilter:(PYFilter *)filter
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

+ (NSPredicate *)predicateFromFilter:(PYFilter *)filter
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
    if (filter.types != nil) {
        NSMutableArray* orPredicateList = [[NSMutableArray alloc] init];
        
        for (NSString* type in filter.types) {
            [orPredicateList addObject:[NSPredicate predicateWithFormat:@"type LIKE %@", type]];
        }
        [predicates addObject:[NSCompoundPredicate orPredicateWithSubpredicates:orPredicateList]];
    }
    
#warning - TODO XXXXXXXXX
    if (filter.state == PYEventFilter_kStateDefault) {
        
    }
    
    // Perki 8.jan 2014 what's for?
    NSCompoundPredicate *testPredicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:predicates];
    NSLog(@"subpredicates %@",testPredicate.subpredicates);
    [testPredicate release];
    
    NSPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    [predicates release];
    return resultPredicate;
}


+ (void)sortNSMutableArrayOfPYEvents:(NSMutableArray *)events sortAscending:(BOOL)sortAscending {
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



@end
