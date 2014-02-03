//
//  PYEventsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventsTests.h"
#import "PYConnection+DataManagement.h"

@implementation PYEventsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testEvents
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    [self testGettingStreams];
    
    
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
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
              createdEventId = [NSString stringWithString:newEventId];
              event.eventId = [NSString stringWithString:newEventId];
              
              
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
                                            STAssertTrue(foundEventOnServer, @"Event hasn't found on server");
                                            
                                            //-- delete event found
                                            [self.connection trashOrDeleteEvent:event withRequestType:PYRequestTypeAsync successHandler:NULL errorHandler:^(NSError *error) {
                                                STFail(@"Error occured when deleting.");
                                            }];
                                            
                                            
                                        } onlineDiffWithCached:NULL errorHandler:^(NSError *error) {
                                            STFail(@"Error occured when checking.");
                                        }];

              
              
              
          } errorHandler:^(NSError *error) {
              STFail(@"Error occured when creating.");
          }];
    
    
  
        
}

- (void)tearDown
{
    [super tearDown];
}

@end
