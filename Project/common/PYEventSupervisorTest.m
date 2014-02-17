//
//  PYEventSupervisorTest.m
//  PryvApiKit
//
//  Created by Perki on 09.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYEventSupervisorTest.h"
#import <PryvApiKit/PYEvent.h>
#import "PYEvent+Supervisor.h"
#import "PYTestsUtils.h"

@implementation PYEventSupervisorTest


- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}





- (void)testEventSupervisor
{
    PYEvent* e1 = [[PYEvent alloc] init];
    e1.eventId = @"e1";
    
    PYEvent* e2 = [[PYEvent alloc] init];
    e2.eventId = @"e2";
    NSString *e2Id = [e2.clientId copy];
    
    
    STAssertEquals(e1, [PYEvent liveEventForClientId:e1.clientId], @"e1 not found in supervisor");
    STAssertEquals(e2, [PYEvent liveEventForClientId:e2Id], @"e2 not found in supervisor");
    
    [e2 release];
    
    BOOL forverNO = NO;
    [PYTestsUtils waitForBOOL:&forverNO forSeconds:2]; // for the garbage collector to do it's job
    
    STAssertNil([PYEvent liveEventForClientId:e2Id], @"e2 found in supervisor");
    STAssertEquals(e1, [PYEvent liveEventForClientId:e1.clientId], @"e1 not found in supervisor");
    
    [e1 release];
}


@end
