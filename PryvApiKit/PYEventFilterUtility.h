//
//  PYEventFilterUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/8/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
@class PYEventFilter;
#import <Foundation/Foundation.h>

@interface PYEventFilterUtility : NSObject

+ (NSDictionary *)dictionaryFromFilter:(PYEventFilter *)filter;
+ (NSArray *)filterCachedEvents:(NSArray *)cachedEventsArray withFilter:(PYEventFilter *)filter;

@end
