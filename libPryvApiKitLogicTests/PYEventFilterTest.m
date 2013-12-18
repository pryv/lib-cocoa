//
//  PYEventFilterTest.m
//  PryvApiKit
//
//  Created by Perki on 13.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterTest.h"

#import "PYEventFilter.h"
#import "PYTestsUtils.h"

@implementation PYEventFilterTest


- (void)setUp
{
    [super setUp];
    
}

- (void)testEventFilter
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    [self testGettingStreams];
    

    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:2000
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    STAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    __block BOOL finished = NO;
    NSLog(@"*53");
    [pyFilter getEventsWithRequestType:PYRequestTypeAsync
                       gotCachedEvents:^(NSArray *cachedEventList) {
                             NSLog(@"*54 CACHED EVENTS: %i", cachedEventList.count);
                       } gotOnlineEvents:^(NSArray *onlineEventList) {
                             NSLog(@"*55 ONLINE EVENTS: %i", onlineEventList.count);
                           finished = YES;
                       } successHandler:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {
                           NSLog(@"*56 ONLINE EVENTS CHANGES: toADD: %i, toRemove: %i, modified: %i ", eventsToAdd.count, eventsToRemove.count, eventModified.count);
                           
                       } errorHandler:^(NSError *error) {
                           STFail(@"<ERROR> %@", error);
                           
                       }];
    
   [PYTestsUtils execute:^{
        STFail(@"Failed after waiting 10 seconds");
   } ifNotTrue:&finished afterSeconds:10];
}

@end
