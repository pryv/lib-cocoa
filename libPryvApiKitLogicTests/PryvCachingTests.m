//
//  PryvCachingTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/24/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvCachingTests.h"
#import "PYCachingController.h"

@interface PryvCachingTests ()
@property (nonatomic, retain) NSData *imageData;
@end

@implementation PryvCachingTests
@synthesize imageData = _imageData;

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    self.imageData = [NSData dataWithContentsOfFile:imagePath];
}

- (void)tearDown
{
    // Tear-down code here.
    [_imageData release];
    [super tearDown];
}

- (void)testCachingOnDisk
{
    NSString *key = @"ImageDataKey";
    [[PYCachingController sharedManager] cacheData:self.imageData withKey:key];
    STAssertTrue([[PYCachingController sharedManager] isDataCachedForKey:@"ImageDataKey"], @"Data isn't cached for key %@",key);
}

@end
