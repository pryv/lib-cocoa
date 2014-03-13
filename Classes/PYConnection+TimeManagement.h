//
//  PYConnection+TimeManagement.h
//  PryvApiKit
//
//  Created by Perki on 03.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYConnection.h"

@interface PYConnection (TimeManagement)

- (NSTimeInterval)serverTimeFromLocalDate:(NSDate *)localDate;
- (NSDate *)localDateFromServerTime:(NSTimeInterval)serverTime;

@end
