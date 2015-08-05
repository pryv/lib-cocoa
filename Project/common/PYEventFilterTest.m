//
//  PYEventFilterTest.m
//  PryvApiKit
//
//  Created by Perki on 13.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"

#import "PYEventFilter.h"
#import "PYEventFilterUtility.h"
#import "PYTestsUtils.h"
#import "PYEvent.h"

#import "PYConnection+FetchedStreams.h"

#import "PYTestConstants.h"
#import "PYStream+Utils.h"

@interface PYEventFilterTest : PYBaseConnectionTests
@end

@implementation PYEventFilterTest


- (void)setUp
{
    [super setUp];
    
}

// FIXME this test should create the events necessary for the filter
- (void)testEventFilter
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    XCTAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL finished1 = NO;
    __block BOOL finished2 = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:kPYNotificationEvents
                                                      object:pyFilter
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         NSDictionary *message = (NSDictionary*) note.userInfo;
         NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
         
         NSLog(@"*162 ADD %@", @(toAdd.count));
         
         if (! finished1) {
             XCTAssertTrue(toAdd.count > 0, @"Got wrong number of events");
             pyFilter.limit = 30;
             finished1 = YES;
             [pyFilter update];
         } else {
             XCTAssertEqual((NSUInteger)10, (NSUInteger)toAdd.count, @"Got wrong number of events");
         }
         
         NSArray* toRemove = [message objectForKey:kPYNotificationKeyDelete];
         if (toRemove) {
             NSLog(@"*162 REMOVE %@", @(toRemove.count));
         }
         NSArray* modify = [message objectForKey:kPYNotificationKeyModify];
         if (modify) {
             NSLog(@"*162 MODIFY %@", @(modify.count));
         }
         
         if (finished1) {
             finished2 = YES;
         }
         finished1 = YES;
         
         NSLog(@"*162");
         
     }];
    [pyFilter update];
    
    
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 10 seconds");
    } ifNotTrue:&finished2 afterSeconds:10];
    
    
}

- (void) testFilterOnType
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    NSString* typeFilter = @"note/txt";
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil
                                                                  types:@[typeFilter]];
    XCTAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL fromCache = NO;
    __block BOOL fromOnline = NO;
    [self.connection eventsWithFilter:pyFilter
                            fromCache:^(NSArray *cachedEventList) {
                                if (cachedEventList) {
                                    for (int i = 0; i < cachedEventList.count; i++) {
                                        XCTAssertTrue([[(PYEvent*)cachedEventList[i] type] isEqualToString:typeFilter],
                                                     @"type is not note/txt");
                                    }
                                }
                                fromCache = YES;
                                
                            } andOnline:^(NSArray *onlineEventList, NSNumber *serverTime) {
                                if (onlineEventList) {
                                    for (int i = 0; i < onlineEventList.count; i++) {
                                        XCTAssertTrue([[(PYEvent*)onlineEventList[i] type] isEqualToString:typeFilter],
                                                     @"type is not note/txt");
                                    }
                                }
                                
                                fromOnline = YES;
                                
                            } onlineDiffWithCached:nil
                         errorHandler:^(NSError *error) {
                             
                         }];
    
    
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 50 seconds");
    } ifNotTrue:&fromCache afterSeconds:50];
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 50 seconds");
    } ifNotTrue:&fromOnline afterSeconds:50];
    
    
}


- (void) testFilterOnStreamId
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    
    //-- prefetch streams
     __block BOOL streamFetched = NO;
    [self.connection streamsEnsureFetched:^(NSError *error) {
        XCTAssertTrue(error == nil, @"failed fectching streams");
        streamFetched  =YES;
    }];
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 50 seconds");
    } ifNotTrue:&streamFetched afterSeconds:50];
    
    
    
    
    PYStream* stream = [self.connection streamWithStreamId:kPYAPITestStreamId];
    NSArray* matchingStreamsIds = [stream descendantsIds];
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:@[stream.streamId]
                                                                   tags:nil
                                                                  types:nil];
    XCTAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL fromCache = NO;
    __block BOOL fromOnline = NO;
    [self.connection eventsWithFilter:pyFilter
                            fromCache:^(NSArray *cachedEventList) {
                                if (cachedEventList) {
                                    for (int i = 0; i < cachedEventList.count; i++) {
                                        NSString* eventStreamId = [(PYEvent*)cachedEventList[i] stream].streamId;
                                        //NSLog(@".. %lu %@", [matchingStreamsIds indexOfObject:eventStreamId], eventStreamId);
                                        XCTAssertTrue([matchingStreamsIds indexOfObject:eventStreamId] != NSNotFound,
                                                     @"Got an event out of filter with streamId: %@", eventStreamId);
                                    }
                                    
                                }
                                fromCache = YES;
                                
                            } andOnline:^(NSArray *onlineEventList, NSNumber *serverTime) {
                                if (onlineEventList) {
                                    for (int i = 0; i < onlineEventList.count; i++) {
                                        NSString* eventStreamId = [(PYEvent*)onlineEventList[i] stream].streamId;
                                        XCTAssertTrue([matchingStreamsIds indexOfObject:eventStreamId] != NSNotFound,
                                                     @"Got an event out of filter with streamId: %@", eventStreamId);
                                    }
                                }
                                fromOnline = YES;
                                
                            } onlineDiffWithCached:nil
                         errorHandler:^(NSError *error) {
                             
                         }];
    
    
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 50 seconds");
    } ifNotTrue:&fromCache afterSeconds:50];
    [PYTestsUtils execute:^{
        XCTFail(@"Failed after waiting 50 seconds");
    } ifNotTrue:&fromOnline afterSeconds:50];
    
    
}

- (void) testSort
{
    
    PYEvent *event1 = [[PYEvent alloc] init];
    event1.streamId = @"1"; [event1 setEventServerTime:10];
    PYEvent *event2 = [[PYEvent alloc] init];
    event2.streamId = @"2"; [event2 setEventServerTime:20];
    PYEvent *event3 = [[PYEvent alloc] init];
    event3.streamId = @"3"; [event3 setEventServerTime:30];
    
    NSMutableArray* events = [[NSMutableArray alloc] initWithObjects:event2,event1,event3,nil];
    
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:events sortAscending:NO];
    XCTAssertEqual(30.0,[(PYEvent*)[events objectAtIndex:0] getEventServerTime],@"wrong postion of event");
    XCTAssertEqual(20.0,[(PYEvent*)[events objectAtIndex:1] getEventServerTime],@"wrong postion of event");
    XCTAssertEqual(10.0,[(PYEvent*)[events objectAtIndex:2] getEventServerTime],@"wrong postion of event");
    
    
    [PYEventFilterUtility sortNSMutableArrayOfPYEvents:events sortAscending:YES];
    XCTAssertEqual(10.0,[(PYEvent*)[events objectAtIndex:0] getEventServerTime],@"wrong postion of event");
    XCTAssertEqual(20.0,[(PYEvent*)[events objectAtIndex:1] getEventServerTime],@"wrong postion of event");
    XCTAssertEqual(30.0,[(PYEvent*)[events objectAtIndex:2] getEventServerTime],@"wrong postion of event");
    
    
}

@end
