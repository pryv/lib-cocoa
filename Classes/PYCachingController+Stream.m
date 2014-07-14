//
//  PYStreamsCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYCachingController+Stream.h"
#import "PYJSONUtility.h"
#import "PYStream.h"
#import "PYConnection.h"
#import "PYConnection+Streams.h"

@implementation  PYCachingController (Stream)


- (void)cachePYStreams:(NSArray*) streams {
    NSMutableArray* toCache = [[NSMutableArray alloc] init];
    for (PYStream* rootStream in streams) {
        [toCache addObject:[rootStream cachingDictionary]];
    }
    [self cacheData:[PYJSONUtility getDataFromJSONObject:toCache] withKey:@"fetchedStreams"];
}

@end
