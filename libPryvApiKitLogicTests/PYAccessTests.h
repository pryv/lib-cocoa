//
//  PYAccessTests.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvApiKit.h"
#import <SenTestingKit/SenTestingKit.h>

@interface PYAccessTests : SenTestCase

@property (nonatomic, retain) PYAccess *access;
@property (nonatomic, retain) PYChannel *channelForTest;

- (void)testGettingChannels;

@end
