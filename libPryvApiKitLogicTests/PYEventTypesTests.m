//
//  PYEventTypesTests.m
//  PryvApiKit
//
//  Created by Perki on 03.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventTypesTests.h"
#import "PYEventTypes.h"
#import "PYEventType.h"
#import "PYEvent.h"
#import "PYMeasurementSet.h"

@implementation PYEventTypesTests


- (void)setUp
{
    [super setUp];
    
}


- (void)testGettingResources
{
    NSDictionary* hierarchical = [[PYEventTypes sharedInstance] hierarchical];
    if (! [hierarchical objectForKey:@"classes"]) {
        STFail(@"Cannot find classes in dictionary");

    }
    
    NSDictionary* extras = [[PYEventTypes sharedInstance] extras];
    if (! [extras objectForKey:@"extras"]) {
        STFail(@"Cannot find extras in dictionary");
        
    }
}


- (void)testEvent
{
    
    PYEvent *eventNoteTxt = [[PYEvent alloc] init];
    eventNoteTxt.type = @"note/txt";
    PYEventType *eventType = [eventNoteTxt pyType];
 
    if (! [@"string" isEqualToString:[eventType type]]) {
        STFail(@"Cannot find classes in dictionary, or note/txt is not of type 'string'");
    }
    
}

- (void)testIsNumerical
{
    PYEvent *eventMassKg = [[PYEvent alloc] init];
    eventMassKg.type = @"mass/kg";
    
    if (! [eventMassKg.pyType isNumerical]) {
        STFail(@"Failed testing if mass/kg event is numerical");
    }
}

- (void)testSymbol
{
    
    PYEvent *eventMassKg = [[PYEvent alloc] init];
    eventMassKg.type = @"money/usd";
    
    if (! [@"$" isEqualToString:[eventMassKg.pyType symbol]]) {
        STFail(@"Failed testing if mass/kg event symbol as '$'");
    }
}

- (void)testMeasurementSets
{
    
  /*  NSArray *measurementSets = [[PYEventTypes sharedInstance] measurementSets];
    if (! [[measurementSets objectAtIndex:0] isKindOfClass:[PYMeasurementSet class]]) {
        STFail(@"measurementSets does not return PYMeasurementSet but ");
    } */
}


- (void)tearDown
{
    [super tearDown];
}

@end
