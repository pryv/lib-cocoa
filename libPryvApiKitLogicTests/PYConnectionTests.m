//
//  PYAccessTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYTestConstants.h"
#import "PYConnectionTests.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"
#import "PYTestsUtils.h"

@implementation PYConnectionTests

@synthesize connection = _connection;


- (void)setUp
{
    [super setUp];
    [PYClient setDefaultDomainStaging];
    self.connection = [PYClient createConnectionWithUsername:kPYAPITestAccount
                                              andAccessToken:kPYAPITestAccessToken];
    STAssertNotNil(self.connection, @"Connection not created.");
   
}

- (void)testConnection
{
    STAssertTrue([self.connection.idURL
                  isEqualToString:@"https://perkikiki.pryv.in:443/?auth=Ve-U8SCASM"],
                 @"connection URL is not valid, %@", self.connection.idURL);
    STAssertTrue([self.connection.idCaching
                  isEqualToString:@"05c3ee6670ecbd28744c71ec723f0b05_perkikiki.pryv.in__Ve-U8SCASM"],
                 @"id caching is unexpected, %@", self.connection.idCaching);
}

- (void)testGettingStreams
{
    
    [self.connection getAllStreamsWithRequestType:PYRequestTypeAsync
     
      gotCachedStreams:^(NSArray *cachedStreamsList) {
        
    } gotOnlineStreams:^(NSArray *onlineStreamList) {
        
        STAssertTrue(onlineStreamList.count > 0, @"Something is wrong with method because we need to have some online streams.");
        
        //NSLog(@"*********** %i", onlineStreamList.count);
        for (PYStream *stream in onlineStreamList) {
            //NSLog(@"*********** %@", stream.streamId);
            //Nenad_test stream
            //if ([stream.streamId isEqualToString:@"TVKoK036of"]) {
            //    STAssertNotNil(stream, @"Error with creating stream object");
            //}
        }
        
    } errorHandler:^(NSError *error) {
        
    }];
    
}

- (void)testSynchronizeTime
{
    __block BOOL finished = NO;
    [self.connection synchronizeTimeWithSuccessHandler:^(NSTimeInterval serverTime) {
        NSLog(@"ServerTime %f", serverTime);
        finished = YES;
    } errorHandler:^(NSError *error) {
        STFail(@"Cannot get ServerTime %@", error);
        finished = YES;
    }];
    
    [PYTestsUtils execute:^{
        STFail(@"Cannot get ServerTime within 10 seconds");
    } ifNotTrue:&finished afterSeconds:10];
    
}



- (void)tearDown
{
    [_connection release];
    [super tearDown];
    
}

@end
