//
//  PYEAppTests.m
//  PryvApiKit
//
//  Created by Perki on 05.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//


#import "PYEAppTests.h"

#import <PryvApiKit/PryvApiKit.h>
#import "PYTestsUtils.h"
#import "PYCachingController.h"
#import "PYCachingController+Event.h"

@interface PYEAppTests ()

@property (nonatomic, retain) PYConnection *connection;

@end


@implementation PYEAppTests

NSString *const kPYAPITestAccount = @"perkikiki";
NSString *const kPYAPITestAccessToken = @"Ve-U8SCASM";

@synthesize connection;

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) startTests
{
    [PYClient setDefaultDomainStaging];
    self.connection = [PYClient createConnectionWithUsername:kPYAPITestAccount
                                              andAccessToken:kPYAPITestAccessToken];
    
    
    
    [self testGoingOfflineThenOnline];
    
}


- (void)testGoingOfflineThenOnline
{
    int originalApiPort = self.connection.apiPort;

    self.connection.apiPort = 0; // set conn offline
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.eventContent = @"Test Offline";
    event.type = @"note/txt";
    
    
    //-- Create event
    __block BOOL step_1_CreateEvent = NO;
    [self.connection eventCreate:event
                  successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent* event) {
                        step_1_CreateEvent = YES;
                  }
                    errorHandler:^(NSError *error) {
                        
                    }];
    
    
    
    
    [PYTestsUtils waitForBOOL:&step_1_CreateEvent forSeconds:10];
    if (!step_1_CreateEvent) {
        
        return;
    }
    
    self.connection.apiPort = originalApiPort; // set conn onnLine
   
    
    
    //--####### Launch synch
    __block BOOL step_2_SynchEvents = NO;
    [self.connection syncNotSynchedEventsIfAny:^(int successCount, int overEventCount) {
       [self.connection.cache eventIsKnownByCache:event];
        step_2_SynchEvents = YES;
    }];
    
    [PYTestsUtils waitForBOOL:&step_2_SynchEvents forSeconds:10];
    if (!step_2_SynchEvents) {
        return;
    }
    

    
    
    
}



- (void) testFilter
{
    
    //STAssertNotNil(self.connection, @"Connection not created.");
    
    
    //STAssertNotNil(self.connection, @"Connection isn't created");
    
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    //STAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL finished1 = NO;
    __block BOOL finished2 = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:kPYNotificationEvents
                                                      object:pyFilter
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         NSDictionary *message = (NSDictionary*) note.userInfo;
         NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
         if (toAdd && toAdd.count > 0) {
             NSLog(@"*162 ADD %i", toAdd.count);
             
             if (! finished1) {
                 //STAssertEquals(20u, toAdd.count, @"Got wrong number of events");
                 finished1 = YES;
                 pyFilter.limit = 30;
                 [pyFilter update];
                 
             } else {
                 //STAssertEquals(10u, toAdd.count, @"Got wrong number of events");
                 finished2 = YES;
             }
             
         }
         NSArray* toRemove = [message objectForKey:kPYNotificationKeyDelete];
         if (toRemove) {
             NSLog(@"*162 REMOVE %i", toRemove.count);
         }
         NSArray* modify = [message objectForKey:kPYNotificationKeyModify];
         if (modify) {
             NSLog(@"*162 MODIFY %i", modify.count);
         }
         
         
         NSLog(@"*162");
         
     }];
    [pyFilter update];
    
    
    [PYTestsUtils execute:^{
        //STFail(@"Failed after waiting 10 seconds");
    } ifNotTrue:&finished2 afterSeconds:10];
    
}





@end
