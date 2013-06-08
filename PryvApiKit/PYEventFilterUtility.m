//
//  PYEventFilterUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterUtility.h"
#import "PYEventFilter.h"

@implementation PYEventFilterUtility


/**
 * To pass in an API request
 * DRAFT CODE UNTESTED
 **/
+ (NSDictionary *)dictionaryFromFilter:(PYEventFilter *)filter
{
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    if (filter.fromTime != PYEventFilter_UNDEFINED_FROMTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.fromTime] forKey:kPrYvChannelEventFilterFromTime];
    }
    
    if (filter.toTime != PYEventFilter_UNDEFINED_TOTIME) {
        [dic setObject:[NSString stringWithFormat:@"%f",filter.toTime] forKey:kPrYvChannelEventFilterToTime];
    }
    
    if (filter.limit > 0) {
        [dic setObject:[NSString stringWithFormat:@"%i",filter.limit] forKey:kPrYvChannelEventFilterLimit];
    }
    
    //Doesn't work when sending - error in request parameters
    //    if (self.onlyFoldersIDs != nil) {
    //        [dic setObject:self.onlyFoldersIDs forKey:kPrYvChannelEventFilterOnlyFolders];
    //    }
    
    //Not implemeted in web service
    //    if (self.tags != nil) {
    //        [NSException raise:@"Not implemented" format:@"PYEventFilter.asDictionary tag matching is not yet implemented"];
    //    }
    
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
