//
//  libPryvApiKitLogicTests.m
//  libPryvApiKitLogicTests
//
//  Created by Nenad Jelic on 6/24/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "libPryvApiKitLogicTests.h"
#import "PYCachingController.h"

@interface libPryvApiKitLogicTests ()
@property (nonatomic, retain) NSData *imageData;

@end

@implementation libPryvApiKitLogicTests
@synthesize imageData = _imageData;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    [_imageData release];
}

- (void)testExample
{
    NSString *key = @"ImageDataKey";
    [[PYCachingController sharedManager] cacheData:self.imageData withKey:key];
    STAssertTrue([[PYCachingController sharedManager] isDataCachedForKey:@"ImageDataKey"], @"Data isn't cached for key %@",key);
    
}

//- (void)testExample
//{
////    STFail(@"Unit tests are not implemented yet in libPryvApiKitLogicTests");
//    
//    STAssertTrue(2+3==5, @"");
//}

@end
