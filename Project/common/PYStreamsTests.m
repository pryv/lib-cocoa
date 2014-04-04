//
//  PYStreamsTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"

#import "PYConnection+DataManagement.h"
#import "PYStream.h"
#import "PYCachingController+Stream.h"
#import "PYTestsUtils.h"

@interface PYStreamsTests : PYBaseConnectionTests
@property (nonatomic, strong) PYStream *stream;
@end

@implementation PYStreamsTests

- (void)setUp
{
    [super setUp];
    
    self.stream = [[PYStream alloc] initWithConnection:self.connection];
    self.stream.streamId = @"pystreamstest";
    self.stream.name = @"PYStreamsTests123";
}

- (void)tearDown
{
    // insert teardown here
    
    [super tearDown];
}


- (void)testGettingStreams
{
    __block BOOL finished1 = NO;
    [self.connection getAllStreamsWithRequestType:PYRequestTypeAsync
     
                                 gotCachedStreams:^(NSArray *cachedStreamsList) {
                                     
                                 } gotOnlineStreams:^(NSArray *onlineStreamList) {
                                     
                                     STAssertTrue(onlineStreamList.count > 0, @"Something is wrong with method because we need to have some online streams.");
                                     
                                     finished1 = YES;
                                 } errorHandler:^(NSError *error) {
                                     STFail(@"error fetching streams");
                                     finished1 = YES;
                                 }];
    [PYTestsUtils execute:^{
        STFail(@"Cannot get streams within 10 seconds");
    } ifNotTrue:&finished1 afterSeconds:10];
    
}


- (void)testStreamFetching
{
    __block BOOL finished1 = NO;
    [self.connection ensureStreamAreFetched:^(NSError *error) {
        if (error) {
            STFail(@"should have no error");
        }
        
        __block PYEvent *event = [[PYEvent alloc] initWithConnection:self.connection];
        event.streamId = @"TVKoK036of";
        event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
        event.type = @"note/txt";
        
        PYStream* stream = [event stream];
        STAssertNotNil(stream, @"stream shouldn't be nil");
        
        finished1 = YES;
     }];
    
    
    [PYTestsUtils execute:^{
        STFail(@"Cannot get streams within 10 seconds");
    } ifNotTrue:&finished1 afterSeconds:10];
    
}


- (void)validateStream:(PYStream *)stream
        withConnection:(PYConnection *)connection
             andParent:(PYStream *)parentStream
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

// create stream locally
// check stream
- (void)testStreamFactory
{
    //
    PYStream *newStream = [[PYStream alloc] initWithConnection:self.connection];
    newStream.streamId = @"pystreamstestcreate";
    newStream.name = @"PYStreamsTests321";
    
    [self deleteStream:newStream];
    
    //STAssertTrue(newStream.connection, @"");
    
    NOT_DONE(done1);
    [self.connection createStream:newStream withRequestType:PYRequestTypeAsync successHandler:^(NSString *createdStreamId) {
        //
        DONE(done1);
    } errorHandler:^(NSError *error) {
        STFail(@"could not create stream");
        DONE(done1);
    }];
    
    WAIT_FOR_DONE(done1);
    
    STAssertTrue(newStream.connection == self.connection, @"connection is not set and not equal to original connection");
}


- (void)testStreamCreation
{
    STAssertNotNil(self.connection, @"Access isn't created");
    
    [self deleteStream:self.stream];
    
    NOT_DONE(streamNotificationReceived);

    id connectionStreamObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kPYNotificationStreams
                                                                                    object:self.connection
                                                                                     queue:nil
    usingBlock:^(NSNotification *note) {
//        if (! eventCreationReceived) {
//              NSDictionary *message = (NSDictionary*) note.userInfo;
//              NSArray* toAdd = [message objectForKey:kPYNotificationKeyAdd];
//              STAssertNotNil(toAdd, @"We should get toAdd Array");
//              STAssertEquals((NSUInteger)1, toAdd.count , @"Array should contain just one event");
//              STAssertEquals([toAdd firstObject], event, @"Event should be the same than the one created");
//              DONE(streamNotificationReceived);
//        } else {
        NSLog(@"stream notification received");
              DONE(streamNotificationReceived);
//        }
    }];
    [connectionStreamObserver retain];
    
    NOT_DONE(done1);
    
    __block NSString *createdStreamIdFromServer = nil;
    [self.connection createStream:self.stream
                  withRequestType:PYRequestTypeAsync
    successHandler:^(NSString *createdStreamId) {
                       
        STAssertNotNil(createdStreamId, @"Stream couldn't be created.");
        createdStreamIdFromServer = [[NSString stringWithString:createdStreamId] retain];
        NSLog(@"New stream ID : %@",createdStreamIdFromServer);
        [self.connection.cache cacheStream:self.stream];
   
    
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
    WAIT_FOR_DONE(streamNotificationReceived);

    
    
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
    [self.connection getOnlineStreamWithId:createdStreamIdFromServer
                               requestType:PYRequestTypeAsync
                            successHandler:^(PYStream *stream) {
                                     STAssertNotNil(stream, @"should return single stream requested by id from the server");
                                     DONE(done3);
                                     
                         } errorHandler:^(NSError *error) {
                                     NSLog(@"error: %@", error);
                                     DONE(done3);
                         }];
    WAIT_FOR_DONE(done3);
}

- (void)deleteStream:(PYStream *)testStream
{
    NSLog(@"deleting stream: %@", testStream);
    NOT_DONE(done3);
    [self.connection trashOrDeleteStream:testStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
        [self.connection trashOrDeleteStream:testStream filterParams:nil withRequestType:PYRequestTypeAsync successHandler:^{
            NSLog(@"Test stream deleted. %@", testStream);
            DONE(done3);
        } errorHandler:^(NSError *error) {
            //NSLog(@"Failed while deleting stream : %@",error);
            DONE(done3);
        }];
    } errorHandler:^(NSError *error) {
        //NSLog(@"Failed while trashing stream : %@",error);
        DONE(done3);
    }];
    
    WAIT_FOR_DONE(done3);
}


@end
