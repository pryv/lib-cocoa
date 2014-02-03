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
    self.connection.apiPort = 0;
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.eventContent = @"Test Offline";
    event.type = @"note/txt";
    
    
    __block NSString *createdEventId;
    
    STAssertNil(event.connection, @"Event.connection is not nil.");
    
    //-- Create event on server
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId) {
                      createdEventId = newEventId;
                      
                      event.notSyncAdd;
                      
                      
                  }
                    errorHandler:^(NSError *error) {
                      STFail(@"Error occured when creating.");
                  }];


    
    
    
    
    self.connection.apiPort = originalApiPort;
    
    
}






@end
