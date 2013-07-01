//
//  PYEventsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventsTests.h"

@implementation PYEventsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testEvents
{
    STAssertNotNil(self.access, @"Access isn't created");
    [self testGettingChannels];
    STAssertNotNil(self.channelForTest, @"Test channel isn't created");
    
    PYEvent *event = [[PYEvent alloc] init];
    event.value = @"Test";
    event.eventFormat = @"txt";
    event.eventClass = @"note";
//    NSString *imageDataPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
//    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
//    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
//    [event addAttachment:att];
    
    
    __block NSString *createdEventId;

    [self.channelForTest createEvent:event
             requestType:PYRequestTypeSync
          successHandler:^(NSString *newEventId, NSString *stoppedId) {
              STAssertNotNil(newEventId, @"EventId is nil. Server or createEvent:requestType: method bug");
              createdEventId = newEventId;
          } errorHandler:^(NSError *error) {
              
          }];
    
    __block BOOL foundEventOnServer;
    [self.channelForTest getAllEventsWithRequestType:PYRequestTypeSync
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
    
    [self.channelForTest trashOrDeleteEvent:event withRequestType:PYRequestTypeAsync successHandler:NULL errorHandler:^(NSError *error) {
        STFail(@"Error occured");
    }];
        
}

- (void)tearDown
{
    [super tearDown];
}

@end
