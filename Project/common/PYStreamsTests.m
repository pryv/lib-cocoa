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
#import "PYCachingController+Stream.h"

@implementation PYStreamsTests

- (void)setUp
{
    [super setUp];
    
}

- (void)validateStream:(PYStream*)stream
        withConnection:(PYConnection*)connection
             andParent:(PYStream*)parentStream
{
    NSString *streamInfo = [NSString stringWithFormat:@"streamID: %@", stream.streamId];
    //NSLog(@"tested %@", streamInfo);
    STAssertEqualObjects(stream.connection, connection,
                         @"connection should match %@", streamInfo);
    STAssertNotNil(stream.clientId, @"Client Id shouldn't be nil %@", streamInfo);
    
    if (parentStream != nil) {
       STAssertTrue([parentStream.streamId isEqualToString:stream.parentId],
                   @"parent Ids don't match %@", streamInfo);
    }
    
    if (stream.children != nil) {
        for (int i = 0; i < stream.children.count; i++) {
         [self validateStream:[stream.children objectAtIndex:i]
               withConnection:connection
                    andParent:stream];
        }
    }
    
}

- (void)testStreams
{
    STAssertNotNil(self.connection, @"Access isn't created");
    
    //[self testGettingStreams];
    
    
    PYStream *stream = [[PYStream alloc] init];
    stream.streamId = @"pystreamstest";
    stream.name = @"PYStreamsTests123";
   
    NOT_DONE(done1);
    
    __block NSString *createdStreamIdFromServer;
    [self.connection createStream:stream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
        STAssertNotNil(createdStreamId, @"Stream couldn't be created.");
        createdStreamIdFromServer = [NSString stringWithString:createdStreamId];
        NSLog(@"New stream ID : %@",createdStreamIdFromServer);
        [self.connection.cache cacheStream:stream];
   
    
        NSString *fakeStreamId = @"ashdgasgduasdfgdhjsgfjhsgdhjf";
        PYStream *streamFromCacheWithFakeId = [self.connection.cache streamFromCacheWithStreamId:fakeStreamId];
        STAssertNil(streamFromCacheWithFakeId, @"This must be nil. It's fake stream id");
        
        PYStream *streamFromCache = [self.connection.cache streamFromCacheWithStreamId:createdStreamIdFromServer];
        STAssertNotNil(streamFromCache, @"No stream with corresponding ID found in cache.");

        DONE(done1);
    } errorHandler:^(NSError *error) {
        
        STFail(@"Change stream name or stream id to run this test correctly see error from server : %@", error);
        DONE(done1);
    }];
    
    WAIT_FOR_DONE(done1);
    
    
    NOT_DONE(done2);
    
    [self.connection getAllStreamsWithRequestType:PYRequestTypeAsync
                                 gotCachedStreams:^(NSArray *cachedStreamsList) {
        
    } gotOnlineStreams:^(NSArray *onlineStreamList) {
        STAssertTrue(onlineStreamList.count > 0, @"Didn't retrieve any stream online.");
        
        //TODO test stream structure
        
        for (int i = 0; i < onlineStreamList.count; i++) {
            [self validateStream:[onlineStreamList objectAtIndex:i]
                  withConnection:self.connection
                       andParent:nil];
        }
        
        DONE(done2);
        
    } errorHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
        DONE(done2);
    }];
     
    WAIT_FOR_DONE(done2);
    
    
    NOT_DONE(done3);
    [self.connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
        [self.connection trashOrDeleteStream:stream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
            NSLog(@"Test stream deleted.");
            DONE(done3);
        } errorHandler:^(NSError *error) {
            STFail(@"Failed while deleting stream : %@",error);
            DONE(done3);
        }];
    } errorHandler:^(NSError *error) {
        STFail(@"Failed while trashing stream : %@",error);
        DONE(done3);
    }];
    
    WAIT_FOR_DONE(done3);
}

- (void)tearDown
{
    [super tearDown];
}


@end
