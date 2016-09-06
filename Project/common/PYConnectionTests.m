//
//  PYAccessTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYTestConstants.h"
#import "PYConnection.h"
#import "PYConnection+Streams.h"
#import "PYConnection+Synchronization.h"
#import "PYTestsUtils.h"
#import "PYBaseConnectionTests.h"


#if TARGET_IPHONE_SIMULATOR
@interface NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end
@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
        return YES;
}
@end
#endif


@interface PYConnectionTests : PYBaseConnectionTests
@end


@implementation PYConnectionTests

- (void)testConnection
{
    XCTAssertTrue([self.connection.idURL
                  isEqualToString:@"https://ios-test.pryv.me:443/?auth=cisryqf19c4bd35yql9u8z8p2"],
                 @"connection URL is not valid, %@", self.connection.idURL);
    XCTAssertTrue([self.connection.idCaching
                  isEqualToString:@"df338bdc8c4cc483c4ceec0ea5ed6ef1_ios-test.pryv.me__cisryqf19c4bd35yql9u8z8p2"],
                 @"id caching is unexpected, %@", self.connection.idCaching);
}

- (void)testSynchronizeTime
{
    __block BOOL finished = NO;
    [self.connection synchronizeTimeWithSuccessHandler:^(NSTimeInterval serverTimeInteval) {
        NSLog(@"ServerTime Delta (s) %f", serverTimeInteval);
        finished = YES;
    } errorHandler:^(NSError *error) {
        XCTFail(@"Cannot get ServerTime %@", error);
        finished = YES;
    }];
    
    [PYTestsUtils execute:^{
        XCTFail(@"Cannot get ServerTime within 10 seconds");
    } ifNotTrue:&finished afterSeconds:10];
    
}

- (void)testSetupConnection
{
    NSDictionary* options =
            @{kPYConnectionOptionFetchStructure : kPYConnectionOptionValueYes,
              kPYConnectionOptionFetchAccessInfos : kPYConnectionOptionValueYes};
    
    NOT_DONE(setUpWithOptions);
    [self.connection setUpWithOptions:options andCallBack:^(NSError *error) {
        if (error) XCTFail(@"Unexpected Error %@", error);
        DONE(setUpWithOptions);
    }];
    WAIT_FOR_DONE(setUpWithOptions);
}

- (void)testCreatingOfflineFirstConnection
{
    PYConnection* connection = [PYClient createConnectionWithUsername:kPYConnectionOfflineUsername  andAccessToken:@"A"];
    
#warning todo add stream and events..
    
    
    BOOL gotError = NO;
    @try {
        [connection setOnlineModeWithUsername:kPYAPITestAccount andAccessToken:kPYAPITestAccessToken2];
    }
    @catch (NSException * e) {
        XCTAssertTrue([[e name] isEqualToString:@"Unimplemented"], @"Should have Unimplemented Error");
        gotError = TRUE;
        NSLog(@"Exception: %@", e);
    }
    XCTAssertTrue(gotError, @"SHOULD HAVE ERROR");
    
    
}




@end
