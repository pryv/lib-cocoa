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
#import "PYFilter.h"

@class PYConnection;

@interface PYEventFilter : PYFilter
{
    NSMutableDictionary *_currentEventsDic;
}



@property (nonatomic, retain, readonly) NSMutableDictionary *currentEventsDic;

/** backward compatibility method.. shouldn't be used**/
- (id)initWithConnection:(PYConnection*)connection
                fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                   limit:(NSUInteger)limit
          onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                    tags:(NSArray *)tags;

/**
 * get all events in this dictionary
 */
- (NSArray *)currentEventsSet;


/**
 * trigger an update of this filter. Result to be monitored on Notification Center
 */
- (void)update;




@end
