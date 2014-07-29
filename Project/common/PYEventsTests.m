//
//  PYEventsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYConnection+Streams.h"
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
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    STAssertNotNil(imageData, @"could not create nsdata from image");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    STAssertTrue([[event description] length] > 0, @"poke description");
    
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
                                      } else if (! eventModificationReceived) { // only once...
                                          NSDictionary *message = (NSDictionary*) note.userInfo;
                                          NSArray* toModify = [message objectForKey:kPYNotificationKeyModify];
                                          STAssertNotNil(toModify, @"We should get a toModify Array");
                                         
                                          /** Modify from the API in unpredictable...
                                          STAssertEquals(1u,toModify.count , @"Array should contain just one event");
                                          STAssertEquals([toModify firstObject], event, @"Event should be the same than the one created");
                                           **/
                                          DONE(eventModificationReceived);
                                          
                                      }
                                  }];
    [connectionEventObserver retain];
    
    
    
    //-- Create event on server
    __block NSString *createdEventId;

    [self.connection eventCreate:event
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event)
     {
         STAssertNotNil(event.connection, @"Event.connection is nil. Server or eventCreate: method bug");
         STAssertNotNil(newEventId, @"EventId is nil. Server or eventCreate: method bug");
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
         
         
         // -- test event modification
         
         
         NOT_DONE(event_modify);
         event.eventContent = [NSString stringWithFormat:@"Test Modificaton %@", [NSDate date]];
         [self.connection eventSaveModifications:event
               successHandler:^(NSString *stoppedId) {
                   
                   DONE(event_modify);
               } errorHandler:^(NSError *error) {
                   STFail(@"not expected error on event modification %@", error);
                   DONE(event_modify);
               }];
         WAIT_FOR_DONE(event_modify);
         
         
         __block NSString* createdEventIdCopy = [newEventId copy];
         __block BOOL foundEventOnServer;
         [self.connection eventsWithFilter:pyFilter
                                 fromCache:NULL
                                 andOnline:^(NSArray *onlineEventList, NSNumber *serverTime)
          {
              STAssertTrue(onlineEventList.count > 0, @"Should get at least one event");
              
              for (PYEvent *eventTemp in onlineEventList) {
                  if ([eventTemp.eventId isEqualToString:createdEventIdCopy]) {
                      foundEventOnServer = YES;
                      
                      
                      STAssertTrue([eventTemp.eventContent rangeOfString:@"Modificaton"].location != NSNotFound, @"modification of event didn't work out");
                      
                      break;
                  }
              }
              STAssertTrue(foundEventOnServer, @"Event hasn't been found on server");
              
              //-- trash and delete event found
              [self.connection eventTrashOrDelete:event
               successHandler:^{
                   [self.connection eventTrashOrDelete:event
                    successHandler:^{
                        DONE(done);
                    }
                    errorHandler:^(NSError *error) {
                        STFail(@"Error occured when deleting.");
                        DONE(done);
                    }];
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


- (void)testEventDurations
{
    NSNumber *nearTimeStamp = [NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] - 10)];
    
    // event with 2 minutes duration
    NSDictionary* e1Dict = @{ @"time": nearTimeStamp, @"duration" : @120};
    PYEvent* e1 = [[PYEvent alloc] init];
    [e1 resetFromCachingDictionary:e1Dict];
    STAssertTrue(! [e1 isRunning], @"should not be runing");
    STAssertNotNil(e1.eventEndDate, @"should have a end date");
    
    // caching directory
    NSDictionary* d1 = [e1 dictionary];
    STAssertNotNil([d1 objectForKey:@"duration"], @"should have a duration value");
    NSDictionary* cd1 = [e1 cachingDictionary];
    STAssertNotNil([cd1 objectForKey:@"duration"], @"should have a duration value");
    
    // manipulations
    [e1 setRunningState];
    STAssertTrue([e1 isRunning], @"should not be runing");
    STAssertNotNil(e1.eventEndDate, @"should have a end date");
    
    [e1 release];
    
    // event with no duration
    NSDictionary* e2Dict = @{ @"time": nearTimeStamp};
    PYEvent* e2 = [[PYEvent alloc] init];
    [e2 resetFromCachingDictionary:e2Dict];
    STAssertTrue(! [e2 isRunning], @"should not be runing");
    STAssertNil(e2.eventEndDate, @"should have a end date");
    // caching directory
    NSDictionary* d2 = [e2 dictionary];
    STAssertNotNil([d2 objectForKey:@"duration"], @"should have a duration value");
    NSDictionary* cd2 = [e2 cachingDictionary];
    STAssertNotNil([cd2 objectForKey:@"duration"], @"should have a duration value");
    
    [e2 setEventEndDate:[NSDate date]];
    STAssertTrue(! [e2 isRunning], @"should not be runing");
    STAssertNotNil(e2.eventEndDate, @"should have a end date");
    STAssertTrue(e2.duration > 0, @"should not be runing");
    [e2 release];
    
    // running event
    NSDictionary* e3Dict = @{ @"time": nearTimeStamp, @"duration" : [NSNull null]};
    PYEvent* e3 = [[PYEvent alloc] init];
    [e3 resetFromCachingDictionary:e3Dict];
    STAssertTrue([e3 isRunning], @"should be running");
    STAssertNotNil(e3.eventEndDate, @"should have a end date");
    // caching directory
    NSDictionary* d3 = [e3 dictionary];
    STAssertTrue([d3 objectForKey:@"duration"] == [NSNull null], @"should have a duration value");
    NSDictionary* cd3 = [e3 cachingDictionary];
    STAssertTrue([cd3 objectForKey:@"duration"] == [NSNull null], @"should have a duration value");

    [e3 release];
    
}

- (void)tearDown
{
    [super tearDown];
}

@end
