//
//  PYStreamsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYStreamsTests.h"
#import "PYConnection+DataManagement.h"
#import "PYStream.h"

@implementation PYStreamsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testStreams
{
    STAssertNotNil(self.connection, @"Access isn't created");
    
    [self testGettingStreams];
    
    
    PYStream *stream = [[PYStream alloc] init];
    stream.streamId = @"pystreamstest";
    stream.name = @"PYStreamsTests123";
   
    
    __block NSString *createdStreamIdFromServer;
    [self.connection createStream:stream withRequestType:PYRequestTypeSync successHandler:^(NSString *createdStreamId) {
        STAssertNotNil(createdStreamId, @"Stream couldn't be created.");
        createdStreamIdFromServer = [NSString stringWithString:createdStreamId];
        NSLog(@"New stream ID : %@",createdStreamIdFromServer);
        [PYStreamsCachingUtillity cacheStream:stream];
    } errorHandler:^(NSError *error) {
        
        STFail(@"Change stream name or stream id to run this test correctly see error from server : %@", error);
    }];
    
    NSString *fakeStreamId = @"ashdgasgduasdfgdhjsgfjhsgdhjf";
    PYStream *streamFromCacheWithFakeId = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:fakeStreamId];
    STAssertNil(streamFromCacheWithFakeId, @"This must be nil. It's fake stream id");
    
    PYStream *streamFromCache = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:createdStreamIdFromServer];
    STAssertNotNil(streamFromCache, @"No stream with corresponding ID found in cache.");
    
    [self.connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamsList) {
        
    } gotOnlineStreams:^(NSArray *onlineStreamList) {
        STAssertTrue(onlineStreamList.count > 0, @"Didn't retrieve any stream online.");
    } errorHandler:^(NSError *error) {
        
    }];
     
    
    [self.connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeSync successHandler:^{
        [self.connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeSync successHandler:^{
            NSLog(@"Test stream deleted.");
        } errorHandler:^(NSError *error) {
            STFail(@"Failed while deleting stream : %@",error);
        }];
    } errorHandler:^(NSError *error) {
        STFail(@"Failed while trashing stream : %@",error);
    }];
    
}

- (void)tearDown
{
    [super tearDown];
}


@end
