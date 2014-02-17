//
//  PYTestsUtils.h
//  PryvApiKit
//
//  Created by Perki on 17.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PYTestExecutionBlock)();

@interface PYTestsUtils : NSObject

/**
 * Utiliy for asynchronous call
 * Loop until finished is set to true
 */
+ (void)waitForBOOL:(BOOL*)finished forSeconds:(int)seconds;


/**
 * Utiliy for asynchronous call
 * ExecuteBlock after
 */
+ (void)execute:(PYTestExecutionBlock)block ifNotTrue:(BOOL*)finished afterSeconds:(int)seconds;


@end
