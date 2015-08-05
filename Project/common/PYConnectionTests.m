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
    // ignore certificate errors only for this domain
    if ([host hasSuffix:@".pryv.in"]) {
        return YES;
    } else {
        return NO;
    }
}
@end
#endif


@interface PYConnectionTests : PYBaseConnectionTests
@end


@implementation PYConnectionTests

- (void)testConnection
{
    XCTAssertTrue([self.connection.idURL
                  isEqualToString:@"https://perkikiki.pryv.in:443/?auth=Ve-U8SCASM"],
                 @"connection URL is not valid, %@", self.connection.idURL);
    XCTAssertTrue([self.connection.idCaching
                  isEqualToString:@"05c3ee6670ecbd28744c71ec723f0b05_perkikiki.pryv.in__Ve-U8SCASM"],
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
