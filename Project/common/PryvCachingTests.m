//
//  PryvCachingTests.m
//  PryvApiKit
//
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYCachingController.h"
#import "PryvApiKit.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYTestsUtils.h"
#import "PYEvent.h"


@interface PryvCachingTests : PYBaseConnectionTests
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

- (void)testResetCacheFromEvent
{
    PYEventFilter* pyFilter = [[PYEventFilter alloc] initWithConnection:self.connection
                                                               fromTime:PYEventFilter_UNDEFINED_FROMTIME
                                                                 toTime:PYEventFilter_UNDEFINED_TOTIME
                                                                  limit:1
                                                         onlyStreamsIDs:nil
                                                                   tags:nil];
    
    
    NOT_DONE(eventsWithFilter);
    [self.connection eventsWithFilter:pyFilter
                            fromCache:NULL
                            andOnline:^(NSArray *onlineEventList, NSNumber *serverTime)
     {
         STAssertTrue(onlineEventList.count > 0, @"Should get at least one event");
         PYEvent* event = [onlineEventList firstObject];
         NSDictionary* initialState = [event cachingDictionary];
         NSTimeInterval previousDate = [[event eventDate] timeIntervalSince1970];
         [event setEventDate:nil];
         STAssertFalse(([[event eventDate] timeIntervalSince1970] == previousDate), @"time must be different");
         [event resetFromCachingDictionary:initialState];
         STAssertTrue(([[event eventDate] timeIntervalSince1970] == previousDate), @"time must be equals");
         DONE(eventsWithFilter);
     } onlineDiffWithCached:^(NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified) {

     } errorHandler:^(NSError *error) {
         STFail(@"Failed fetching event.");
         DONE(eventsWithFilter);
     }];
    
    WAIT_FOR_DONE_WITH_TIMEOUT(eventsWithFilter, 20);
    if (!eventsWithFilter) STFail(@"Timeout eventsWithFilter");

}

@end
