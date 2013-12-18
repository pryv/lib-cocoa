//
//  PYEventFilter.h
//  PryvApiKit
//
//  Created by Pierre-Mikael Legris on 30.05.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "PYConstants.h"
#import "PYClient.h"


@class PYConnection;

#define PYEventFilter_UNDEFINED_FROMTIME DBL_MIN
#define PYEventFilter_UNDEFINED_TOTIME DBL_MAX

@interface PYEventFilter : NSObject
{
    PYConnection *_connection;
    NSTimeInterval _fromTime;
    NSTimeInterval _toTime;
    NSUInteger _limit;
    NSArray *_onlyStreamsIDs; // of strings
    NSArray *_tags;
    
    NSTimeInterval _lastRefresh;
    NSString *_notificationCenterName;
}

@property (readonly, nonatomic, retain) PYConnection *connection;
@property (nonatomic) NSTimeInterval fromTime;
@property (nonatomic) NSTimeInterval toTime;
@property (nonatomic) NSUInteger limit;
@property (nonatomic, retain) NSArray *onlyStreamsIDs;
@property (nonatomic, retain) NSArray *tags;

@property (nonatomic, retain) NSString *notificationCenterName;

@property (nonatomic) NSTimeInterval lastRefresh;


/**
 * @param fromTime use PYEventFilter_UNDEFINED_FROMTIME when undefined
 * @param toTime use PYEventFilter_UNDEFINED_TOTIME when undefined
 * @param onlyStreamsIDs array of strings with StreamsIDs, nil for no match
 * @param tags array of strings with tags, nil for no match
 * @param limit number of events may be 2x > to the limit if cached events are totally differents than online events, 0 or negative for ALL
 */
- (id)initWithConnection:(PYConnection*)connection
             fromTime:(NSTimeInterval)fromTime
               toTime:(NSTimeInterval)toTime
                limit:(NSUInteger)limit
       onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                 tags:(NSArray *)tags;

- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags;

- (void)update;

/**
 This method gets sync details for event filter
 */
- (void)getEventsWithRequestType:(PYRequestType)reqType
                 gotCachedEvents:(void (^) (NSArray *cachedEventList))cachedEvents
                 gotOnlineEvents:(void (^) (NSArray *onlineEventList))onlineEvents
                  successHandler:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
                    errorHandler:(void (^)(NSError *error))errorHandler;




@end
