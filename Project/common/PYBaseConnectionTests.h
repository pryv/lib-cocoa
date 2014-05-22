//
//  PYBaseConnectionTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <PryvApiKit/PryvApiKit.h>


#define NOT_DONE(done) __block BOOL done = NO;
#define DONE(done) done = YES;
#define WAIT_FOR_DONE(done)     \
                    while (!done) {\
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode\
                        beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];\
                    }


@interface PYBaseConnectionTests : SenTestCase

@property (nonatomic, retain) PYConnection *connection;


@end
