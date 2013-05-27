//
//  PYEventsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
#import <Foundation/Foundation.h>

@interface PYEventsCachingUtillity : NSObject

+ (void)cacheEvent:(NSDictionary *)event WithKey:(NSString *)key;
+ (void)cacheEvents:(NSArray *)events;
+ (NSArray *)getEventsFromCache;

@end
