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
#import "PYClient.h"
#import "PYEventsCachingUtillity.h"
#import "PYEventFilterUtility.h"

@implementation PYEventFilter

@synthesize connection = _connection;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize limit = _limit;
@synthesize onlyStreamsIDs = _onlyStreamsIDs;
@synthesize tags = _tags;

@synthesize lastRefresh = _lastRefresh;

@synthesize notificationCenterName = _notificationCenterName;


- (id)initWithConnection:(PYConnection*)connection
                fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                   limit:(NSUInteger)limit
          onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                    tags:(NSArray *)tags
{
    if (self = [super init]) {
        _connection = connection;
        [self changeFilterFromTime:fromTime
                            toTime:toTime
                             limit:limit
                    onlyStreamsIDs:onlyStreamsIDs
                              tags:tags];
        _lastRefresh = PYEventFilter_UNDEFINED_FROMTIME;
    }
    return self;
}




- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags
{
    _fromTime = fromTime; // time question ?? shouldn't we align time with the server?
    _toTime = toTime;
    _onlyStreamsIDs = onlyStreamsIDs;
    _tags = tags;
    _limit = limit;
}

- (void)update
{
    
}

/**
 * process can be considered as finished when both lists has been received
 */
- (void)getEventsWithRequestType:(PYRequestType)reqType
                 gotCachedEvents:(void (^) (NSArray *cachedEventList))cachedEvents
                 gotOnlineEvents:(void (^) (NSArray *onlineEventList))onlineEvents
                  successHandler:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
                    errorHandler:(void (^)(NSError *error))errorHandler
{
    
    [self.connection getEventsWithRequestType:reqType
                                   parameters:[PYEventFilterUtility filteredEvents:self]
                              gotCachedEvents:cachedEvents
                              gotOnlineEvents:onlineEvents
                               successHandler:syncDetails
                                 errorHandler:errorHandler];


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
