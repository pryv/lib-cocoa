//
//  PYProfileAndInfostests.m
//  PrYv-iOS-Example
//
//  Created by Perki on 16.06.14.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import "PYConnection+ProfileAndInfos.h"
#import "PYTestConstants.h"

@interface PYProfileAndInfostests : PYBaseConnectionTests
@end


@implementation PYProfileAndInfostests


- (void)setUp
{
    [super setUp];
    
    
    
}

- (void)testAccessInfos
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    NOT_DONE(done);
    
    [self.connection accessInfosWithSuccessHandler:^(NSDate *cachedAt, NSDictionary *infos) {
         if (! infos) XCTFail(@"Error occured when geting access is nil ");
         DONE(done);
    } refreshCacheIfOlderThan:0 failureHandler:^(NSError *error) {
        XCTFail(@"Error occured when geting access. %@", error);
        DONE(done);
    }];
    
    
    WAIT_FOR_DONE(done);
    
    
}

- (void)testProfilePublic
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    NOT_DONE(done);
    
    [self.connection profilePublicWithSuccessHandler:^(NSDate *cachedAt, NSDictionary *profile) {
        if (! profile) XCTFail(@"Error occured when geting profilePublic is nil ");
        DONE(done);
    } refreshCacheIfOlderThan:0 failureHandler:^(NSError *error) {
        XCTFail(@"Error occured when geting profilePublic. %@", error);
        DONE(done);
    }];
    
    
    WAIT_FOR_DONE(done);
    
    
}


- (void)testProfileApp
{
    XCTAssertNotNil(self.connection, @"Connection isn't created");
    
    NOT_DONE(done);
    
    [self.connection profileAppWithSuccessHandler:^(NSDate *cachedAt, NSDictionary *profile) {
        if (! profile) XCTFail(@"Error occured when geting profileApp is nil ");
        DONE(done);
    } refreshCacheIfOlderThan:0 failureHandler:^(NSError *error) {
        XCTFail(@"Error occured when geting profileApp. %@", error);
        DONE(done);
    }];
    
    
    WAIT_FOR_DONE(done);
    
    
}



@end
