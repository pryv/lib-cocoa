//
//  PYEventsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventsTests.h"
#import "PYConnection+DataManagement.h"

#define NOT_DONE(done) __block BOOL done = NO;
#define DONE(done) done = YES;
#define WAIT_FOR_DONE(done)     \
                    while (!done) {\
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode\
                        beforeDate:[NSDate distantFuture]];\
                        usleep(10000);\
                    }

@implementation PYEventsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testEvents
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    [self testGettingStreams];
    
    NOT_DONE(done);
    
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.time = NSTimeIntervalSince1970;
    event.eventContent = @"Test";
    event.type = @"note/txt";
//    NSString *imageDataPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
//    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
//    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
//    [event addAttachment:att];
    
    
    __block NSString *createdEventId;

    STAssertNil(event.connection, @"Event.connection is not nil.");
    
    //-- Create event on server
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId) {
                      
              STAssertNotNil(newEventId, @"EventId is nil. Server or createEvent:requestType: method bug");
              STAssertNotNil(event.connection, @"Event.connection is nil. Server or createEvent:requestType: method bug");
              createdEventId = newEventId;
              event.eventId = newEventId;
              
              
              // --- check if this event is found online
              __block BOOL foundEventOnServer;
              [self.connection getEventsWithRequestType:PYRequestTypeAsync
                                                 filter:nil
                                        gotCachedEvents:NULL
                                        gotOnlineEvents:^(NSArray *onlineEventList, NSNumber *serverTime) {
                                            STAssertTrue(onlineEventList.count > 0, @"Some events are already created before running this test, error in geting online events list");
                                            
                                            for (PYEvent *eventTemp in onlineEventList) {
                                                if ([eventTemp.eventId isEqualToString:createdEventId]) {
                                                    foundEventOnServer = YES;
                                                    break;
                                                }
                                            }
                                            STAssertTrue(foundEventOnServer, @"Event hasn't been found on server");
                                            
                                            //-- delete event found
                                            [self.connection trashOrDeleteEvent:event
                                                                withRequestType:PYRequestTypeAsync
                                                                 successHandler:^{
                                                                     DONE(done);
                                                                 }
                                                                   errorHandler:^(NSError *error) {
                                                STFail(@"Error occured when deleting.");
                                                DONE(done);
                                            }];
                                        } onlineDiffWithCached:NULL errorHandler:^(NSError *error) {
                                            STFail(@"Error occured when checking.");
                                            DONE(done);
                                        }];
          } errorHandler:^(NSError *error) {
              STFail(@"Error occured when creating.");
              DONE(done);
          }];
  
    WAIT_FOR_DONE(done);
}

- (void)tearDown
{
    [super tearDown];
}

@end
