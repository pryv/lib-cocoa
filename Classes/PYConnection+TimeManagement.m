//
//  PYConnection+TimeManagement.m
//  PryvApiKit
//
//  Created by Perki on 03.02.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYConnection+TimeManagement.h"
#import "PYConnection.h"

@implementation PYConnection (TimeManagement)


- (NSTimeInterval)serverTimeFromLocalDate:(NSDate*)localDate {
    if (localDate == nil) { localDate = [NSDate date]; }
    
    return [localDate timeIntervalSince1970] - self.serverTimeInterval;
}

- (NSDate *)localDateFromServerTime:(NSTimeInterval)serverTime{
    return [NSDate dateWithTimeIntervalSince1970:(serverTime + self.serverTimeInterval)];
}

@end
