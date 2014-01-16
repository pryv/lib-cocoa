//
//  PryvCachingTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/24/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvCachingTests.h"
#import "PYCachingController.h"
#import "PryvApiKit.h"
#import "PYConnection.h"

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
    
    STAssertNotNil(self.connection, @"Connection isn't created");
    
    NSString *key = @"ImageDataKey";
    [self.connection.cache cacheData:self.imageData withKey:key];
    STAssertTrue([self.connection.cache isDataCachedForKey:@"ImageDataKey"], @"Data isn't cached for key %@",key);
}

@end
