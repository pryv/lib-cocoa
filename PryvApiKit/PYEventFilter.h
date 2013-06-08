//
//  PYEventFilter.h
//  PryvApiKit
//
//  Created by Pierre-Mikael Legris on 30.05.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "PYChannel.h"
#import "PYConstants.h"

#define PYEventFilter_UNDEFINED_FROMTIME DBL_MIN
#define PYEventFilter_UNDEFINED_TOTIME DBL_MAX

@interface PYEventFilter : NSObject
{
    PYChannel *_channel;
    NSTimeInterval _fromTime;
    NSTimeInterval _toTime;
    NSUInteger _limit;
    NSArray *_onlyFoldersIDs; // of strings
    NSArray *_tags;
    
    NSTimeInterval _lastRefresh;
}

@property (readonly, nonatomic, retain) PYChannel *channel;
@property (nonatomic) NSTimeInterval fromTime;
@property (nonatomic) NSTimeInterval toTime;
@property (nonatomic) NSUInteger limit;
@property (nonatomic, retain) NSArray *onlyFoldersIDs;
@property (nonatomic, retain) NSArray *tags;

@property (nonatomic) NSTimeInterval lastRefresh;

/**
 * @param fromTime use PYEventFilter_UNDEFINED_FROMTIME when undefined
 * @param toTime use PYEventFilter_UNDEFINED_TOTIME when undefined
 * @param onlyFoldersIDs array of strings with foldersIDs, null for no match
 * @param limit number of events may be 2x > to the limit if cached events are totally differents than online events
 */
- (id)initWithChannel:(PYChannel*)channel
             fromTime:(NSTimeInterval)fromTime
               toTime:(NSTimeInterval)toTime
                limit:(NSUInteger)limit
       onlyFoldersIDs:(NSArray *)onlyFoldersIDs
                 tags:(NSArray *)tags;

- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyFoldersIDs:(NSArray *)onlyFoldersIDs
                        tags:(NSArray *)tags;

- (void)getEventsWithRequestType:(PYRequestType)reqType
                 gotCachedEvents:(void (^) (NSArray *eventList))gotCachedEvents
                 gotOnlineEvents:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))gotOnlineEvents
                    errorHandler:(void (^) (NSError *error))errorHandler;




@end
