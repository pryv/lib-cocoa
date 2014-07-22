//
//  PYStreamsCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYCachingController.h"

@class PYStream;

@interface PYCachingController (Streams)

/**
 Cache stream (PYStreams) objects on disk
 */
- (void)cachePYStreams:(NSArray*) streams;


@end
