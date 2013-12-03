//
//  PYEventTypesTests.m
//  PryvApiKit
//
//  Created by Perki on 03.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventTypesTests.h"
#import "PYEventTypes.h"

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
    
    PYEvent *event = [[PYEvent alloc] init];
    event.type = @"note/txt";
    
    NSDictionary* eventDef = [[PYEventTypes sharedInstance] definitionForPYEvent:event];
    if (! [eventDef objectForKey:@"type"]) {
        STFail(@"Cannot find classes in dictionary");
        
    } else {
        NSLog(@"*21 %@", [eventDef objectForKey:@"type"]);
    }

}


- (void)tearDown
{
    [super tearDown];
}

@end
