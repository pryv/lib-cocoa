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
    
    STAssertNotNil(self.streamForTest, @"Test stream isn't created");
    
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

    [self.connection createEvent:event
             requestType:PYRequestTypeSync
          successHandler:^(NSString *newEventId, NSString *stoppedId) {
              STAssertNotNil(newEventId, @"EventId is nil. Server or createEvent:requestType: method bug");
              createdEventId = [NSString stringWithString:newEventId];
              event.eventId = [NSString stringWithString:newEventId];
          } errorHandler:^(NSError *error) {
              
          }];
    
    __block BOOL foundEventOnServer;
    [self.connection getAllEventsWithRequestType:PYRequestTypeSync
                                     gotCachedEvents:NULL
                                     gotOnlineEvents:^(NSArray *onlineEventList) {
                                         STAssertTrue(onlineEventList.count > 0, @"Some events are already created before running this test, error in geting online events list");
                                         
                                         for (PYEvent *event in onlineEventList) {
                                             if ([event.eventId isEqualToString:createdEventId]) {
                                                 foundEventOnServer = YES;
                                                 break;
                                             }
                                         }
                                         STAssertTrue(foundEventOnServer, @"Event hasn't found on server");
                                         
                                     } successHandler:NULL errorHandler:^(NSError *error) {
                                     }];
    
    [self.connection trashOrDeleteEvent:event withRequestType:PYRequestTypeSync successHandler:NULL errorHandler:^(NSError *error) {
        STFail(@"Error occured when deleting.");
    }];
        
}

- (void)tearDown
{
    [super tearDown];
}

@end
