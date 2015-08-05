//
//  PYBaseConnectionTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYTestConstants.h"
#import "PYTestsUtils.h"

@implementation PYBaseConnectionTests

@synthesize connection = _connection;

- (void)setUp
{
    [super setUp];
    [PYClient setDefaultDomainStaging];
    self.connection = [PYClient createConnectionWithUsername:kPYAPITestAccount
                                              andAccessToken:kPYAPITestAccessToken];
    XCTAssertNotNil(self.connection, @"Connection not created.");
}


- (void)tearDown
{
    self.connection = nil;
    [super tearDown];
}


@end
