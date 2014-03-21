//
//  PYSupervisorTest.m
//  PryvApiKit
//
//  Created by Perki on 09.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYStream.h>
#import "PYTestsUtils.h"

#import "NSObject+Supervisor.h"

@interface PYSupervisorTest : SenTestCase
@end


@implementation PYSupervisorTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testStreamSupervisor
{
    PYStream *s1 = [[PYStream alloc] init];
    s1.streamId = @"s1";
    
    PYStream *s2 = [[PYStream alloc] init];
    s2.streamId = @"es";
    NSString *s2Id = [s2.clientId copy];
    
    
    STAssertEquals(s1, [PYStream liveObjectForSupervisableKey:s1.clientId], @"s1 not found in supervisor");
    STAssertEquals(s2, [PYStream liveObjectForSupervisableKey:s2Id], @"s2 not found in supervisor");
    
    [s2 release];
    
    BOOL forverNO = NO;
    [PYTestsUtils waitForBOOL:&forverNO forSeconds:2]; // for the garbage collector to do it's job
    
    STAssertNil([PYStream liveObjectForSupervisableKey:s2Id], @"s2 found in supervisor");
    STAssertEquals(s1, [PYStream liveObjectForSupervisableKey:s1.clientId], @"s1 not found in supervisor");
    
    [s1 release];
}

- (void)testEventSupervisor
{
    PYEvent* e1 = [[PYEvent alloc] init];
    e1.eventId = @"e1";
    
    PYEvent* e2 = [[PYEvent alloc] init];
    e2.eventId = @"e2";
    NSString *e2Id = [e2.clientId copy];
    
    
    STAssertEquals(e1, [PYEvent liveObjectForSupervisableKey:e1.clientId], @"e1 not found in supervisor");
    STAssertEquals(e2, [PYEvent liveObjectForSupervisableKey:e2Id], @"e2 not found in supervisor");
    
    [e2 release];
    
    BOOL forverNO = NO;
    [PYTestsUtils waitForBOOL:&forverNO forSeconds:2]; // for the garbage collector to do it's job
    
    STAssertNil([PYEvent liveObjectForSupervisableKey:e2Id], @"e2 found in supervisor");
    STAssertEquals(e1, [PYEvent liveObjectForSupervisableKey:e1.clientId], @"e1 not found in supervisor");
    
    [e1 release];
}


@end
