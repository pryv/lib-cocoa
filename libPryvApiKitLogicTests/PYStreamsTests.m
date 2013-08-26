//
//  PYChannelsTests.m
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
    
    STAssertNotNil(self.streamForTest, @"Test stream isn't created");
    
    PYStream *stream = [[PYStream alloc] init];
    stream.streamId = @"snfjsgfujkasf";
    stream.name = @"jskdhf738rjhadgdsf";
    
    
    __block NSString *createdStreamIdFromServer;
    [self.connection createStream:stream withRequestType:PYRequestTypeSync successHandler:^(NSString *createdStreamId) {
        STAssertNotNil(createdStreamId, @"Stream couldn't be created.");
        createdStreamIdFromServer = [NSString stringWithString:createdStreamId];
        [PYStreamsCachingUtillity cacheStream:stream];
    } errorHandler:^(NSError *error) {
        STFail(@"Change stream name or stream id to run this test correctly see error from server : %@",error);
    }];
    
    NSString *fakeStreamId = @"ashdgasgduasdfgdhjsgfjhsgdhjf";
    PYStream *streamFromCacheWithFakeId = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:fakeStreamId];
    STAssertNil(streamFromCacheWithFakeId, @"This must be nil. It's fake stream id");
    
    PYStream *streamFromCache = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:createdStreamIdFromServer];
    STAssertNotNil(streamFromCache, @"");
    
    [self.connection getAllStreamsWithRequestType:PYRequestTypeSync gotCachedStreams:^(NSArray *cachedStreamsList) {
        
    } gotOnlineStreams:^(NSArray *onlineStreamList) {
        STAssertTrue(onlineStreamList.count > 0, @"Didn't retrieve any stream online.");
    } errorHandler:^(NSError *error) {
        
    }];
}

- (void)tearDown
{
    [super tearDown];
}


@end
