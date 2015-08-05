//
//  PYEventTypesTests.m
//  PryvApiKit
//
//  Created by Perki on 03.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PryvApiKit/PYEventTypes.h>
#import "PYEventType.h"
#import "PYEventClass.h"
#import "PYEvent.h"
#import "PYClient.h"
#import "PYMeasurementSet.h"
#import "PYMeasurementTypesGroup.h"


#import "PYBaseConnectionTests.h"


@interface PYEventTypesTests : XCTestCase
@end


@implementation PYEventTypesTests

- (void)setUp
{
    [super setUp];
    
}


- (void)testGettingResources
{
    NSDictionary* hierarchical = [[PYEventTypes sharedInstance] hierarchical];
    if (! [hierarchical objectForKey:@"classes"]) {
        XCTFail(@"Cannot find classes in dictionary");
        
    }
    
    NSDictionary* extras = [[PYEventTypes sharedInstance] extras];
    if (! [extras objectForKey:@"extras"]) {
        XCTFail(@"Cannot find extras in dictionary");
        
    }
}

- (void)testGettingResourcesOnline
{
    
    NOT_DONE(updateFromOnlineSource);
    [[PYEventTypes sharedInstance] updateFromOnlineSourceWithSuccess:^(NSDictionary *hierarchical, NSDictionary *extras) {
        DONE(updateFromOnlineSource);
    }];
    
    WAIT_FOR_DONE(updateFromOnlineSource);
    
    NSDictionary* hierarchical = [[PYEventTypes sharedInstance] hierarchical];
    if (! [hierarchical objectForKey:@"classes"]) {
        XCTFail(@"Cannot find classes in dictionary");
        
    }
    
 
    
    NSDictionary* extras = [[PYEventTypes sharedInstance] extras];
    if (! [extras objectForKey:@"extras"]) {
        XCTFail(@"Cannot find extras in dictionary");
        
    }
}




- (void)testEvent
{
    
    PYEvent *eventNoteTxt = [[PYEvent alloc] init];
    eventNoteTxt.type = @"note/txt";
    PYEventType *eventType = [eventNoteTxt pyType];
    
    if (! [@"string" isEqualToString:[eventType type]]) {
        XCTFail(@"Cannot find classes in dictionary, or note/txt is not of type 'string'");
    }
    
}


- (void)testClass
{
    
    PYEvent *eventNoteTxt = [[PYEvent alloc] init];
    eventNoteTxt.type = @"note/txt";
    PYEventType *eventType = [eventNoteTxt pyType];
    
    if (! [@"note" isEqualToString:[eventType classKey]]) {
        XCTFail(@"Cannot find classes in dictionary, or note/txt is not of class 'note'");
    }
    
}

- (void)testIsNumerical
{
    PYEvent *eventMassKg = [[PYEvent alloc] init];
    eventMassKg.type = @"mass/kg";
    
    if (! [eventMassKg.pyType isNumerical]) {
        XCTFail(@"Failed testing if mass/kg event is numerical");
    }
}

- (void)testSymbol
{
    
    PYEvent *moneyUSD = [[PYEvent alloc] init];
    moneyUSD.type = @"money/usd";
    
    if (! [@"$" isEqualToString:[moneyUSD.pyType symbol]]) {
        XCTFail(@"Failed testing if mass/kg event symbol as '$'");
    }
    
    
    PYEvent *pryvActivity = [[PYEvent alloc] init];
    pryvActivity.type = @"activity/pryv";
    
    if ([pryvActivity.pyType symbol] != nil) {
        XCTFail(@"Failed testing if activity/pryv event symbol as nil value");
    }
}

- (void)testLocalizedNames
{
    
    PYEvent *lengthM = [[PYEvent alloc] init];
    lengthM.type = @"length/km";
    
    [PYClient setLanguageCodePrefered:@"en"];
    
    if (! [@"Kilometers" isEqualToString:lengthM.pyType.localizedName]) {
        XCTFail(@"Failed testing if length/km event localizedName in english is Kilometer : %@",
               lengthM.pyType.localizedName);
    }
    
    if (! [@"Length" isEqualToString:lengthM.pyType.klass.localizedName]) {
        XCTFail(@"Failed testing if length/km event class localizedName in english is Length : %@",
               lengthM.pyType.klass.localizedName);
    }
    
    [PYClient setLanguageCodePrefered:@"fr"];
    
    if (! [@"Kilomètres" isEqualToString:[lengthM.pyType localizedName]]) {
        XCTFail(@"Failed testing if length/km event localizedName in french is Kilomètre: %@",
               [lengthM.pyType localizedName]);
    }
    
    if (! [@"Longueur" isEqualToString:lengthM.pyType.klass.localizedName]) {
        XCTFail(@"Failed testing if length/km event class localizedName in french is Longueur : %@",
               lengthM.pyType.klass.localizedName);
    }
    
    PYEvent *activity = [[PYEvent alloc] init];
    activity.type = @"activity/plain";
    if (! [activity.pyType.formatKey isEqualToString:activity.pyType.localizedName]) {
        XCTFail(@"Failed testing if activity/pryv event localizedName is : %@",
               activity.pyType.localizedName);
    }
    
    if (! [@"activity" isEqualToString:activity.pyType.klass.localizedName]) {
        XCTFail(@"Failed testing if activity/pryv event class localizedName in english is activity : %@",
               activity.pyType.klass.localizedName);
    }
}



- (void)testMeasurementSets
{
    
    NSArray *measurementSets = [[PYEventTypes sharedInstance] measurementSets];
    
    NSString* testSetKey = @"all-measures";
    PYMeasurementSet* testSet = nil;
    for (int i = 0; i < measurementSets.count; i++) {
        PYMeasurementSet* set = (PYMeasurementSet*)[measurementSets objectAtIndex:i];
        if ([set.key isEqualToString:testSetKey]){ testSet = set ; break ; }
    }
    
    if (! testSet) {
      XCTFail(@"measurementSets cannot find set with key %@ ", testSetKey);
    }
    
    
    
    
    
    [PYClient setLanguageCodePrefered:@"fr"];
    
    if (! [@"Toutes les mesures" isEqualToString:testSet.localizedName]) {
        XCTFail(@"Failed testing if 'all-measure' measurementSets  event localizedName in french is 'Toutes les mesures': %@",
               testSet.localizedName);
    }
    
    
    // ---- measure groups
    
    NSArray* groups = testSet.measurementGroups;
    NSString* testGroupKey = @"volume";
    PYMeasurementTypesGroup* testGroup = nil;
    for (int i = 0; i < groups.count; i++) {
        PYMeasurementTypesGroup* group = (PYMeasurementTypesGroup*)[groups objectAtIndex:i];
        XCTAssertNotNil(group.localizedName, @"should have a name");
        
        for (int j = 0; j < group.formatKeyList.count; j++) {
            PYEventType* eType = [group pyTypeAtIndex:j];
            XCTAssertTrue([eType.formatKey isEqualToString:(NSString *)[group.formatKeyList objectAtIndex:j]],
                          @"each eType should have the right formatKey"
                          );
        }
        
        
        // -- sorting
        
        [group sortUsingLocalizedName];
#warning test that group is sorted
        
        if ([group.classKey isEqualToString:testGroupKey]){ testGroup = group ; break ; }
    }
    
    
    if (! testGroup) {
        XCTFail(@"measurementSets cannot find group %@ in set with key %@ ", testGroupKey, testSetKey);
    }
    
}


- (void)tearDown
{
    [super tearDown];
}

@end
