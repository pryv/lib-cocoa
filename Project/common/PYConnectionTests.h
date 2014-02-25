//
//  PYAccessTests.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <PryvApiKit/PryvApiKit.h>


#define NOT_DONE(done) __block BOOL done = NO;
#define DONE(done) done = YES;
#define WAIT_FOR_DONE(done)     \
                    while (!done) {\
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode\
                        beforeDate:[NSDate distantFuture]];\
                        usleep(10000);\
                    }

@interface PYConnectionTests : SenTestCase

@property (nonatomic, retain) PYConnection *connection;

- (void)testGettingStreams;

@end
