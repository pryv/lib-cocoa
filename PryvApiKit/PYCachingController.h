//
//  PryvCachingController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
#import <Foundation/Foundation.h>

@interface PYCachingController : NSObject
{
    NSString *_localDataPath;
}

+ (id)sharedManager;

- (BOOL)isEventDataCachedForKey:(NSString *)key;
- (void)cacheEventData:(NSData *)data withKey:(NSString *)key;
- (NSData *)getEventDataForKey:(NSString *)key;
- (void)removeEvent:(NSString *)key;
- (NSArray *)getAllEventsFromCache;
//- (NSArray *)getAllUnsyncEventsFromCache;
- (PYEvent *)getEventWithKey:(NSString *)key;
- (void)cacheNSURLRequest:(NSURLRequest *)req withKey:(NSString *)key;
- (NSURLRequest *)getNSURLRequestForKey:(NSString *)key;

@end
