//
//  PYTestsUtils.m
//  PryvApiKit
//
//  Created by Perki on 17.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYTestsUtils.h"



@implementation PYTestsUtils

+ (void)waitForBOOL:(BOOL*)finished forSeconds:(int)seconds {
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:seconds];
    while (!*finished && [timeout timeIntervalSinceNow]>0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
}

+ (void)execute:(PYTestExecutionBlock)block ifNotTrue:(BOOL*)finished afterSeconds:(int)seconds {
    [self waitForBOOL:finished forSeconds:seconds];
    if (! *finished) block();
}

@end
