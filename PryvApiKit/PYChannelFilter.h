//
//  PYChannelFilter.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/13/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

/**
 @discussion
 This class will be used in the future when web service support these functionalities
 */


typedef enum {
    PYChannelStateDefault = 1,
    PYChannelStateTrashed,
    PYChannelStateAll
} PYChannelState;

#import <Foundation/Foundation.h>
#import "PYAccess.h"

@interface PYChannelFilter : NSObject
{
    PYAccess *_access;
    PYChannelState _channelState;
    NSUInteger _limit;
    NSTimeInterval _lastRefresh;
}

@property (readonly, nonatomic, retain) PYAccess *access;
@property (nonatomic) PYChannelState channelState;
@property (nonatomic) NSUInteger limit;
@property (nonatomic) NSTimeInterval lastRefresh;

- (id)initWithAccess:(PYAccess *)access
            andState:(PYChannelState)channelState
               limit:(NSUInteger)limit;

@end
