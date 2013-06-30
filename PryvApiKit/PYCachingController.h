//
//  PryvCachingController.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYChannel;
@class PYFolder;
#import <Foundation/Foundation.h>

@interface PYCachingController : NSObject
{
    NSString *_localDataPath;
}

+ (id)sharedManager;

- (BOOL)isDataCachedForKey:(NSString *)key;
- (void)cacheData:(NSData *)data withKey:(NSString *)key;
- (NSData *)getDataForKey:(NSString *)key;
- (void)removeEvent:(NSString *)key;
- (void)removeFolder:(NSString *)key;
- (NSArray *)getAllEventsFromCache;
- (PYEvent *)getEventWithKey:(NSString *)key;
- (void)cacheNSURLRequest:(NSURLRequest *)req withKey:(NSString *)key;
- (NSURLRequest *)getNSURLRequestForKey:(NSString *)key;

//Channels
- (NSArray *)getAllChannelsFromCache;
- (PYChannel *)getChannelWithKey:(NSString *)key;
//Folders
- (NSArray *)getAllFoldersFromCache;
- (PYFolder *)getFolderWithKey:(NSString *)key;
@end
