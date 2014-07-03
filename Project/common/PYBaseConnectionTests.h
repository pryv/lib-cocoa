//
//  PYBaseConnectionTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//


#import <PryvApiKit/PryvApiKit.h>
#import <SenTestingKit/SenTestingKit.h>


#define NOT_DONE(done) __block BOOL done = NO;
#define DONE(done) done = YES;
#define WAIT_FOR_DONE(done)     \
                    while (!done) {\
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode\
                        beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];\
                    }
//-- when using WAIT_FOR_DONE_WITH_TIMEOUT check your flag after WAIT is passed!
#define WAIT_FOR_DONE_WITH_TIMEOUT(done, timeout)     \
                    NSDate* startedAt = [NSDate date]; \
                    while (!done && (0 < (timeout +  [startedAt timeIntervalSinceNow]))) {\
                       [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode\
                    beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];\
                    }


@interface PYBaseConnectionTests : SenTestCase

@property (nonatomic, retain) PYConnection *connection;


@end
