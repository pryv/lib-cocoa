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
#import "PYClient.h"
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
    
    PYEvent *moneyUSD = [[PYEvent alloc] init];
    moneyUSD.type = @"money/usd";
    
    if (! [@"$" isEqualToString:[moneyUSD.pyType symbol]]) {
        STFail(@"Failed testing if mass/kg event symbol as '$'");
    }
    
    
    PYEvent *pryvActivity = [[PYEvent alloc] init];
    pryvActivity.type = @"activity/pryv";
    
    if ([pryvActivity.pyType symbol] != nil) {
        STFail(@"Failed testing if activity/pryv event symbol as nil value");
    }
}

- (void)testLocalizedNames
{
    
    PYEvent *lengthM = [[PYEvent alloc] init];
    lengthM.type = @"length/km";
    
    [PYClient setLanguageCodePrefered:@"en"];

    if (! [@"Kilometers" isEqualToString:lengthM.pyType.localizedName]) {
        STFail(@"Failed testing if length/km event localizedName in english is Kilometer : %@",
               lengthM.pyType.localizedName);
    }
    
    [PYClient setLanguageCodePrefered:@"fr"];
    
    if (! [@"Kilomètres" isEqualToString:[lengthM.pyType localizedName]]) {
        STFail(@"Failed testing if length/km event localizedName in french is Kilomètre: %@",
               [lengthM.pyType localizedName]);
    }
    
    PYEvent *activity = [[PYEvent alloc] init];
    activity.type = @"activity/pryv";
    if (! [activity.pyType.formatKey isEqualToString:activity.pyType.localizedName]) {
        STFail(@"Failed testing if activity/pryv event localizedName is : %@",
               activity.pyType.localizedName);
    }
}



- (void)testMeasurementSets
{
 /**
  NSArray *measurementSets = [[PYEventTypes sharedInstance] measurementSets];
    if (! [[measurementSets objectAtIndex:0] isKindOfClass:[PYMeasurementSet class]]) {
        STFail(@"measurementSets does not return PYMeasurementSet but ");
    }**/
}


- (void)tearDown
{
    [super tearDown];
}

@end
