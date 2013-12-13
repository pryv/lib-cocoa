//
//  PYEventFilterTest.m
//  PryvApiKit
//
//  Created by Perki on 13.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventFilterTest.h"

#import "PYEventFilter.h"

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
                                                                  limit:0
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    STAssertNotNil(pyFilter, @"PYEventFilter isn't created");

}

@end
