//
//  offLineTests.m
//  PryvApiKit
//
//  Created by Perki on 03.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "offLineTests.h"
#import "PYTestsUtils.h"

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
    STAssertTrue(event.hasTmpId);
    
    
    //-- Create event on server
    __block BOOL step_1_CreateEvent = NO;
    __block NSString *createdEventId;
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId) {
                      
                      createdEventId = newEventId;
                      
                      event.toBeSync;
                      
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
    
    
    
    
    self.connection.apiPort = originalApiPort;
    
    
}






@end
