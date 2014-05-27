//
//  PYLocalStoreTest.m
//  PrYv-iOS-Example
//
//  Created by Perki on 27.05.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <PryvApiKit/PYEvent.h>
#import <PryvApiKit/PYStream.h>
#import "PYLocalStorage+Event.h"
#import "PYTestsUtils.h"
#import "PYBaseConnectionTests.h"


@interface PYLocalStoreTest : SenTestCase

@end

@implementation PYLocalStoreTest

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
    
    PYEvent* e1 = [PYEvent createOrRetreiveWithClientId:nil];
    e1.eventId = @"e1";
    NOT_DONE(event_saved);
    [e1 saveWithSuccessCallBack:^(BOOL succeded, NSError *error) {
        DONE(event_saved);
    }];
    WAIT_FOR_DONE(event_saved);
    STAssertEquals(e1, [PYLocalStorage eventById:e1.eventId onConnection:nil], @"e1 not found in supervisor");
    
    [e1 release];
}


@end
