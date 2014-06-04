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

#import "PYFilter.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYEvent.h"
#import "PYEventFilterUtility.h"


@interface PYFilter ()

@end

@implementation PYFilter

NSString * const PYEventFilter_kStateArray[] = { nil, @"trashed", @"all" };


@synthesize connection = _connection;
@synthesize fromTime = _fromTime;
@synthesize toTime = _toTime;
@synthesize limit = _limit;
@synthesize onlyStreamsIDs = _onlyStreamsIDs;
@synthesize tags = _tags;
@synthesize types = _types;
@synthesize state = _state;

@synthesize modifiedSince = _modifiedSince;



- (void)dealloc
{
    //TODO check that it's necessary
    _connection  = nil;
    [_onlyStreamsIDs release];
    [_tags release];
    [_types release];
    [super dealloc];
}



- (id)initWithConnection:(PYConnection*)connection
                fromTime:(NSTimeInterval)fromTime
                  toTime:(NSTimeInterval)toTime
                   limit:(NSUInteger)limit
          onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                    tags:(NSArray *)tags
                   types:(NSArray *)types
{
    if (self = [super init]) {
        _connection = connection;
        [self changeFilterFromTime:fromTime
                            toTime:toTime
                             limit:limit
                    onlyStreamsIDs:onlyStreamsIDs
                              tags:tags
                             types:types];
        _modifiedSince = PYEventFilter_UNDEFINED_FROMTIME;
        
        
    }
    return self;
}


- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags
{
    [self changeFilterFromTime:fromTime toTime:toTime limit:limit
                onlyStreamsIDs:onlyStreamsIDs tags:tags types:nil];
}

- (void)changeFilterFromTime:(NSTimeInterval)fromTime
                      toTime:(NSTimeInterval)toTime
                       limit:(NSUInteger)limit
              onlyStreamsIDs:(NSArray *)onlyStreamsIDs
                        tags:(NSArray *)tags
                       types:(NSArray *)types
{
    self.fromTime = fromTime; // time question ?? shouldn't we align time with the server?
    self.toTime = toTime;
    self.onlyStreamsIDs = onlyStreamsIDs;
    self.tags = tags;
    self.limit = limit;
    self.types = types;
}

@end
