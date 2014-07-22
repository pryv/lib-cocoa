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
    [super tearDown];
}





- (void)testGoingOfflineThenOnline
{
    //--####### set conn offline
    self.connection.apiPort = 0;
    
    PYCachingController *cache = self.connection.cache;
    
    __block PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.eventContent = [NSString stringWithFormat:@"Test Offline %@", [NSDate date]];
    event.type = @"note/txt";
    
    STAssertNil(event.connection, @"Event.connection is not nil.");
    STAssertTrue(event.hasTmpId, @"event must have a temp id");
    STAssertFalse([cache eventIsKnownByCache:event], @"event should not be known by cache");
    
    STAssertEquals(event.synchedAt, PYEvent_UNDEFINED_TIME, @"event should not have synched time");
    
    //--####### Create event
    __block BOOL step_1_CreateEvent = NO;
    __block NSString *unsyncEventCacheKey ;
    [self.connection eventCreate:event
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event) {
                      STAssertNil(newEventId, @"We shouldn't get a new id");
                      STAssertTrue(event.hasTmpId, @"event must have a temp id");
                      STAssertTrue(event.toBeSync, @"event should be known as to be synched");
                      STAssertEquals(event.synchedAt, PYEvent_UNDEFINED_TIME, @"event should not have synched time");
                      
                      
                      //-- cache test
                      STAssertTrue([cache eventIsKnownByCache:event],
                                   @"event should be known by cache");
                      unsyncEventCacheKey = [[cache keyForEvent:event] copy];
                      
                      
                      
                      step_1_CreateEvent = YES;
                  }
                    errorHandler:^(NSError *error) {
                        STFail(@"Error occured when creating event: %@", error);
                    }];
    

    [PYTestsUtils waitForBOOL:&step_1_CreateEvent forSeconds:10];
    if (!step_1_CreateEvent) {
        STFail(@"Timeout creating event.");
        return;
    }
    
    self.connection.apiPort = originalApiPort; // set conn onnLine
    
    __block NSTimeInterval startingSynchAt = [[NSDate date] timeIntervalSince1970];
    
    //--####### Launch synch
    __block BOOL step_2_SynchEvents = NO;
    [self.connection syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
        STAssertEquals(overEventCount, successCount, @"All events should have been synchronized");
        STAssertFalse([cache isDataCachedForKey:unsyncEventCacheKey], @"Event temporary caching data must be removed");
        STAssertTrue([cache eventIsKnownByCache:event], @"event should be known by cache");
        STAssertTrue(event.synchedAt > startingSynchAt, @"event should have a synchedAtDate after startingSync date");
        STAssertTrue(event.synchedAt < [[NSDate date] timeIntervalSince1970],
                     @"event should have a synchedAtDate before now");
        step_2_SynchEvents = YES;
    }];
    
    // wait for timeout times number of unsynced events secods
    [PYTestsUtils waitForBOOL:&step_2_SynchEvents forSeconds:(int)(61 * [[self.connection eventsNotSync] count])];
    if (!step_2_SynchEvents) {
        STFail(@"Timeout synching events.");
        return;
    }
    
    
    [PYEvent release];
    
    
}






@end
