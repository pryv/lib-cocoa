//
//  PYEventsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYConnection+DataManagement.h"
#import "PYConnection+TimeManagement.h"

@interface PYEventsTests : PYBaseConnectionTests
@end

@implementation PYEventsTests


- (void)setUp
{
    [super setUp];
    

    
}

- (void)testEvents
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    
    
    
    NOT_DONE(done);
    
    __block PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"note/txt";
    //    NSString *imageDataPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    //    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    //    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    //    [event addAttachment:att];
    STAssertNil(event.connection, @"Event.connection is not nil.");
    
    // --------------- notification
    
    NOT_DONE(eventCreationReceived);
    NOT_DONE(eventModificationReceived);
    id connectionEventObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kPYNotificationEvents
                                                                                   object:self.connection
                                                                                    queue:nil
                                                                               usingBlock:^(NSNotification *note)
                                  {
                                      
                                      if (! eventCreationReceived) {
                                          NSDictionary *message = (NSDictionary*) note.userInfo;
                                          NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
                                          STAssertNotNil(toAdd, @"We should get toAdd Array");
                                          STAssertEquals((NSUInteger)1, toAdd.count , @"Array should contain just one event");
                                          STAssertEquals([toAdd firstObject], event, @"Event should be the same than the one created");
                                          DONE(eventCreationReceived);
                                      } else {
                                          /** -- not predictable until API v0.7
                                          NSDictionary *message = (NSDictionary*) note.userInfo;
                                          NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
                                          STAssertNotNil(toAdd, @"We should not get toAdd Array");
                                          
                                          NSArray* modify = [message objectForKey:kPYNotificationKeyModify];
                                          
                                          STAssertEquals(1u,modify.count , @"Array should contain just one event");
                                          STAssertEquals([modify firstObject], event, @"Event should be the same than the one created");
                                           **/
                                          DONE(eventModificationReceived);
                                          
                                      }
                                  }];
    [connectionEventObserver retain];
    
    
    
    //-- Create event on server
    __block NSString *createdEventId;

    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
                  successHandler:^(NSString *newEventId, NSString *stoppedId)
     {
         STAssertNotNil(event.connection, @"Event.connection is nil. Server or createEvent:requestType: method bug");
         STAssertNotNil(newEventId, @"EventId is nil. Server or createEvent:requestType: method bug");
         STAssertEquals(event.eventId, newEventId, @"EventId was not assigned to event");
         
         
         createdEventId = [newEventId copy];
         
         
         // --- check if this event is found online
         
         PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                                    fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                      toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                       limit:20
                                                              onlyStreamsIDs:nil
                                                                        tags:nil];
         pyFilter.modifiedSince = [self.connection serverTimeFromLocalDate:nil] - 120; // last 120 seconds
         
         
         __block NSString* createdEventIdCopy = [newEventId copy];
         __block BOOL foundEventOnServer;
         [self.connection getEventsWithRequestType:PYRequestTypeAsync
                                            filter:pyFilter
                                   gotCachedEvents:NULL
                                   gotOnlineEvents:^(NSArray *onlineEventList, NSNumber *serverTime)
          {
              STAssertTrue(onlineEventList.count > 0, @"Should get at least one event");
              
              for (PYEvent *eventTemp in onlineEventList) {
                  if ([eventTemp.eventId isEqualToString:createdEventIdCopy]) {
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
         STFail(@"Error occured when creating. %@", error);
         DONE(done);
     }];
    
    WAIT_FOR_DONE(done);
    WAIT_FOR_DONE(eventCreationReceived);
    WAIT_FOR_DONE(eventModificationReceived);
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:connectionEventObserver];
    [connectionEventObserver release];
    
}

- (void)tearDown
{
    [super tearDown];
}

@end
