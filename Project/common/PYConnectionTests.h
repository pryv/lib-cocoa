//
//  PYAccessTests.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <PryvApiKit/PryvApiKit.h>


@interface PYConnectionTests : SenTestCase

@property (nonatomic, retain) PYConnection *connection;

- (void)testGettingStreams;

@end
