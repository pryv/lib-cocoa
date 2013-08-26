//
//  PYAccessTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYConnectionTests.h"
#import "PYConnection.h"
#import "PYConnection+DataManagement.h"

@implementation PYConnectionTests

@synthesize connection = _connection;
@synthesize streamForTest = _streamForTest;


- (void)setUp
{
    [super setUp];
    self.connection = [PYClient createConnectionWithUsername:@"perkikiki" andAccessToken:@"Ve-U8SCASM"];
//    self.connection = [[PYConnection alloc] initWithUsername:@"perkikiki" andAccessToken:@"Ve-U8SCASM"];
    STAssertNotNil(self.connection, @"Connection not created.");

}

- (void)testGettingStreams
{
    [PYClient setDefaultDomainStaging];
    
    [self.connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamsList) {
        
    } gotOnlineStreams:^(NSArray *onlineStreamList) {
        STAssertTrue(onlineStreamList.count > 0, @"Something is wrong with method because we need to have some online streams.");
        for (PYStream *stream in onlineStreamList) {
            //Nenad_test stream
            if ([stream.streamId isEqualToString:@"TVKoK036of"]) {
                STAssertNotNil(stream, @"Error with creating stream object");
                self.streamForTest = stream;
            }
        }
        
    } errorHandler:^(NSError *error) {
        
    }];    
    
//    [self.connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamList) {
//        
//    } gotOnlineStreams:^(NSArray *onlineStreamList) {
//        STAssertTrue(onlineStreamList.count > 0, @"Something is wrong with method because we ned to have some online channels");
//        
//        for (PYStream *stream in onlineStreamList) {
//            //Nenad_test channel
//            if ([stream.streamId isEqualToString:@"TVKoK036of"]) {
//                STAssertNotNil(stream, @"Error with creating channel object");
//                self.streamForTest = stream;
//            }
//        }
//
//    } errorHandler:^(NSError *error) {
//        
//    }];
    
}

- (void)tearDown
{
    [_connection release];
    [_streamForTest release];
    [super tearDown];

}

@end
