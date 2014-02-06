//
//  offLineTests.m
//  PryvApiKit
//
//  Created by Perki on 03.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "offLineTests.h"
#import "PYTestsUtils.h"
#import "PYCachingController+Event.h"

@interface offLineTests ()
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

    self.connection.apiPort = 0; // set conn offline
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.eventContent = @"Test Offline";
    event.type = @"note/txt";
    
    STAssertNil(event.connection, @"Event.connection is not nil.");
    STAssertTrue(event.hasTmpId, @"event must have a temp id");
    STAssertFalse([event.connection.cache eventIsKnownByCache:event], @"event should not be known by cache");
    
    //-- Create event
    __block BOOL step_1_CreateEvent = NO;
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId) {
                      STAssertNil(newEventId, @"We shouldn't get a new id");
                      STAssertTrue(event.hasTmpId, @"event must have a temp id");
                      STAssertTrue([event.connection.cache eventIsKnownByCache:event],
                                   @"event should be known by cache");
                      STAssertTrue(event.toBeSync, @"event should be known as to be synched");
                      
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
    
    //-- Launch synch
    __block BOOL step_2_SynchEvents = NO;
    [self.connection syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
        step_2_SynchEvents = YES;
    }];
    
    [PYTestsUtils waitForBOOL:&step_2_SynchEvents forSeconds:10];
    if (!step_2_SynchEvents) {
        STFail(@"Timeout synching events.");
        return;
    }

    
    
    
    
}






@end
