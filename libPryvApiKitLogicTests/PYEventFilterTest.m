//
//  PYEventFilterTest.m
//  PryvApiKit
//
//  Created by Perki on 13.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterTest.h"

#import "PYEventFilter.h"
#import "PYTestsUtils.h"

@implementation PYEventFilterTest


- (void)setUp
{
    [super setUp];
    
}

- (void)testEventFilter
{
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    [self testGettingStreams];
    
    
    
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:20
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    STAssertNotNil(pyFilter, @"PYEventFilter isn't created");
    
    
    __block BOOL finished1 = NO;
    __block BOOL finished2 = NO;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"EVENTS"
                                                      object:pyFilter
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note)
     {
         NSDictionary *message = (NSDictionary*) note.userInfo;
         NSArray* toAdd = [message objectForKey:@"ADD"];
         if (toAdd && toAdd.count > 0) {
             NSLog(@"*162 ADD %i", toAdd.count);
             
             if (! finished1) {
                 STAssertEquals(20u, toAdd.count, @"Got wrong number of events");
                 pyFilter.limit = 30;
                 [pyFilter update];
                 finished1 = YES;
                 
             } else {
                 STAssertEquals(10u, toAdd.count, @"Got wrong number of events");
                 finished2 = YES;
             }
             
         }
         NSArray* toRemove = [message objectForKey:@"REMOVE"];
         if (toRemove) {
             NSLog(@"*162 REMOVE %i", toRemove.count);
         }
         NSArray* modify = [message objectForKey:@"MODIFY"];
         if (modify) {
             NSLog(@"*162 MODIFY %i", modify.count);
         }
         
         
         NSLog(@"*162");
         
     }];
    [pyFilter update];
    

    [PYTestsUtils execute:^{
        STFail(@"Failed after waiting 10 seconds");
    } ifNotTrue:&finished2 afterSeconds:10];
    
    
}

- (void) testSort
{
    
    PYEvent *event1 = [[PYEvent alloc] init];
    event1.streamId = @"1"; [event1 setEventServerTime:10];
    PYEvent *event2 = [[PYEvent alloc] init];
    event2.streamId = @"2"; [event2 setEventServerTime:20];
    PYEvent *event3 = [[PYEvent alloc] init];
    event3.streamId = @"3"; [event3 setEventServerTime:30];
    
    NSMutableArray* events = [[NSMutableArray alloc] initWithObjects:event2,event1,event3,nil];
    
    [PYEventFilter sortNSMutableArrayOfPYEvents:events sortAscending:NO];
    STAssertEquals(30.0,[(PYEvent*)[events objectAtIndex:0] getEventServerTime],@"wrong postion of event");
    STAssertEquals(20.0,[(PYEvent*)[events objectAtIndex:1] getEventServerTime],@"wrong postion of event");
    STAssertEquals(10.0,[(PYEvent*)[events objectAtIndex:2] getEventServerTime],@"wrong postion of event");
    
    
    [PYEventFilter sortNSMutableArrayOfPYEvents:events sortAscending:YES];
    STAssertEquals(10.0,[(PYEvent*)[events objectAtIndex:0] getEventServerTime],@"wrong postion of event");
    STAssertEquals(20.0,[(PYEvent*)[events objectAtIndex:1] getEventServerTime],@"wrong postion of event");
    STAssertEquals(30.0,[(PYEvent*)[events objectAtIndex:2] getEventServerTime],@"wrong postion of event");

    
}

@end
