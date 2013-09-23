//
//  PYAccessTests.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvApiKit.h"
#import <SenTestingKit/SenTestingKit.h>

@interface PYConnectionTests : SenTestCase

@property (nonatomic, retain) PYConnection *connection;
@property (nonatomic, retain) PYStream *streamForTest;

- (void)testGettingStreams;

@end
