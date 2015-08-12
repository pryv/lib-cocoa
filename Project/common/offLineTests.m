//
//  offLineTests.m
//  PryvApiKit
//
//  Created by Perki on 03.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYTestsUtils.h"
#import "PYCachingController+Events.h"
#import "PYConnection+Synchronization.h"
#import <PYConnection.h>
#import "PYTestConstants.h"

@implementation PYConnection (Testing)
@end


@interface offLineTests : PYBaseConnectionTests
{
    NSUInteger originalApiPort;
}
@end



@implementation offLineTests


- (void)setUp
{
    [super setUp];
    // Set-up code here.
    originalApiPort = self.connection.apiPort;
}

- (void)tearDown
{
    //self.connection.apiPort = originalApiPort;
    [super tearDown];
}





- (void)testGoingOfflineThenOnline
{
    //--####### set conn offline
    self.connection.apiPort = 0;
    
    PYCachingController *cache = self.connection.cache;
    
    __block PYEvent *event = [[PYEvent alloc] init];
    event.streamId = kPYAPITestStreamId;
    event.eventContent = [NSString stringWithFormat:@"Test Offline %@", [NSDate date]];
    event.type = @"note/txt";
    
    XCTAssertNil(event.connection, @"Event.connection is not nil.");
    XCTAssertTrue(event.hasTmpId, @"event must have a temp id");
    XCTAssertFalse([cache eventIsKnownByCache:event], @"event should not be known by cache");
    
    XCTAssertEqual(event.synchedAt, PYEvent_UNDEFINED_TIME, @"event should not have synched time");
    
    //--####### Create event
    __block BOOL step_1_CreateEvent = NO;
    __block NSString *unsyncEventCacheKey ;
    [self.connection eventCreate:event
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event) {
                      XCTAssertNil(newEventId, @"We shouldn't get a new id");
                      XCTAssertTrue(event.hasTmpId, @"event must have a temp id");
                      XCTAssertTrue(event.toBeSync, @"event should be known as to be synched");
                      XCTAssertEqual(event.synchedAt, PYEvent_UNDEFINED_TIME, @"event should not have synched time");
                      
                      
                      //-- cache test
                      XCTAssertTrue([cache eventIsKnownByCache:event],
                                   @"event should be known by cache");
                      unsyncEventCacheKey = [[cache keyForEvent:event] copy];
                      
                      
                      
                      step_1_CreateEvent = YES;
                  }
                    errorHandler:^(NSError *error) {
                        XCTFail(@"Error occured when creating event: %@", error);
                    }];
    

    [PYTestsUtils waitForBOOL:&step_1_CreateEvent forSeconds:10];
    if (!step_1_CreateEvent) {
        XCTFail(@"Timeout creating event.");
        return;
    }
    
    self.connection.apiPort = originalApiPort; // set conn onnLine
    
    __block NSTimeInterval startingSynchAt = [[NSDate date] timeIntervalSince1970];
    
    //--####### Launch synch
    __block BOOL step_2_SynchEvents = NO;
    [self.connection syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
        if (overEventCount > 0) { // was not already in synch process
            XCTAssertEqual(overEventCount, successCount, @"All events should have been synchronized");
            XCTAssertFalse([cache isDataCachedForKey:unsyncEventCacheKey], @"Event temporary caching data must be removed");
            XCTAssertTrue([cache eventIsKnownByCache:event], @"event should be known by cache");
            XCTAssertTrue(event.synchedAt > startingSynchAt, @"event should have a synchedAtDate after startingSync date");
            XCTAssertTrue(event.synchedAt < [[NSDate date] timeIntervalSince1970],
                          @"event should have a synchedAtDate before now");
        }
   
        step_2_SynchEvents = YES;
    }];
    
    // wait for timeout times number of unsynced events secods
    [PYTestsUtils waitForBOOL:&step_2_SynchEvents forSeconds:10];
    if (!step_2_SynchEvents) {
        XCTFail(@"Timeout synching events.");
        return;
    }
    
    
    [PYEvent release];
    
    
}






@end
