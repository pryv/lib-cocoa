//
//  PYStreamsTests.m
//  PryvApiKit
//
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYBaseConnectionTests.h"

#import "PYConnection.h"
#import "PYConnection+Streams.h"
#import "PYStream.h"
#import "PYCachingController+Streams.h"
#import "PYTestsUtils.h"
#import "PYTestConstants.h"

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
    [self.connection streamsFromCache:^(NSArray *cachedStreamsList) {
                                     
                                 } andOnline:^(NSArray *onlineStreamList) {
                                     
                                     XCTAssertTrue(onlineStreamList.count > 0, @"Something is wrong with method because we need to have some online streams.");
                                     
                                     finished1 = YES;
                                 } errorHandler:^(NSError *error) {
                                     XCTFail(@"error fetching streams %@", error);
                                     finished1 = YES;
                                 }];
    [PYTestsUtils execute:^{
        XCTFail(@"Cannot get streams within 10 seconds");
    } ifNotTrue:&finished1 afterSeconds:10];
    
}


- (void)testStreamFetching
{
    __block BOOL finished1 = NO;
    [self.connection streamsEnsureFetched:^(NSError *error) {
        if (error) {
            XCTFail(@"should have no error");
        }
        
        __block PYEvent *event = [[PYEvent alloc] initWithConnection:self.connection];
        event.streamId = kPYAPITestStreamId;
        event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
        event.type = @"note/txt";
        
        PYStream* stream = [event stream];
        XCTAssertNotNil(stream, @"stream shouldn't be nil");
        XCTAssertNotNil(self.connection.fetchedStreamsRoots, @"fetchedStreamsRoots shouldn't be nil");
        XCTAssertTrue(self.connection.fetchedStreamsRoots.count > 0, @"fetchedStreamsRoots shouldn't be empty");
        finished1 = YES;
     }];
    
    
    [PYTestsUtils execute:^{
        XCTFail(@"Cannot get streams within 10 seconds");
    } ifNotTrue:&finished1 afterSeconds:10];
    
}


- (void)validateStream:(PYStream *)stream
        withConnection:(PYConnection *)connection
             andParent:(PYStream *)parentStream
{
    NSString *streamInfo = [NSString stringWithFormat:@"streamID: %@", stream.streamId];
    XCTAssertEqualObjects(stream.connection, connection,
                         @"connection should match %@", streamInfo);
    XCTAssertNotNil(stream.clientId, @"Client Id shouldn't be nil %@", streamInfo);
    
    if (parentStream != nil) {
       XCTAssertTrue([parentStream.streamId isEqualToString:stream.parentId],
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
    [self.connection streamCreate:newStream successHandler:^(NSString *createdStreamId) {
        DONE(done1);
    } errorHandler:^(NSError *error) {
        XCTFail(@"could not create stream");
        DONE(done1);
    }];
    
    WAIT_FOR_DONE(done1);
    
    XCTAssertTrue(newStream.connection == self.connection, @"connection is not set and not equal to original connection");
}


- (void)testStreamCreation
{
    XCTAssertNotNil(self.connection, @"Access isn't created");
    
    [self deleteStream:self.stream];
    
    NOT_DONE(streamNotificationReceived);

    id connectionStreamObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kPYNotificationStreams
                                                                                    object:self.connection
                                                                                     queue:nil
    usingBlock:^(NSNotification *note) {
              DONE(streamNotificationReceived);

    }];
    [connectionStreamObserver retain];
    
    NOT_DONE(streamCreate);
    
    __block NSString *createdStreamIdFromServer = nil;
    [self.connection streamCreate:self.stream
    successHandler:^(NSString *createdStreamId) {
                       
        XCTAssertNotNil(createdStreamId, @"Stream couldn't be created.");
        createdStreamIdFromServer = [[NSString stringWithString:createdStreamId] retain];
        DONE(streamCreate);
    } errorHandler:^(NSError *error) {
        
        XCTFail(@"Change stream name or stream id to run this test correctly see error from server : %@", error);
        DONE(streamCreate);
    }];
    
    WAIT_FOR_DONE(streamCreate);
    WAIT_FOR_DONE(streamNotificationReceived);

    
    
    NOT_DONE(streamsFromCache);
    
    [self.connection streamsFromCache:^(NSArray *cachedStreamsList) {
        
    } andOnline:^(NSArray *onlineStreamList) {
        XCTAssertTrue(onlineStreamList.count > 0, @"Didn't retrieve any stream online.");
        
        //TODO test stream structure
        
        for (int i = 0; i < onlineStreamList.count; i++) {
            [self validateStream:[onlineStreamList objectAtIndex:i]
                  withConnection:self.connection
                       andParent:nil];
        }
        
        DONE(streamsFromCache);
        
    } errorHandler:^(NSError *error) {
        XCTFail(@"Unexpected Error: %@", error);
        DONE(streamsFromCache);
    }];
     
    WAIT_FOR_DONE(streamsFromCache);
    
    
    NOT_DONE(streamOnlineWithId);
    [self.connection streamOnlineWithId:createdStreamIdFromServer
                            successHandler:^(PYStream *stream) {
                                     XCTAssertNotNil(stream, @"should return single stream requested by id from the server");
                                     DONE(streamOnlineWithId);
                                     
                         } errorHandler:^(NSError *error) {
                                     XCTFail(@"Unexpected Error: %@", error);
                                     DONE(streamOnlineWithId);
                         }];
    WAIT_FOR_DONE(streamOnlineWithId);
}


- (void)testChangeStreamProperties
{
    
    PYStream *newStream = [[PYStream alloc] initWithConnection:self.connection];
    newStream.streamId = @"pystreamstestchangeproperty";
    newStream.name = @"PYStreamsTests333";
    
   
    
    [self deleteStream:newStream];
    
    //STAssertTrue(newStream.connection, @"");
    
    NOT_DONE(done1);
    [self.connection streamCreate:newStream successHandler:^(NSString *createdStreamId) {
        DONE(done1);
    } errorHandler:^(NSError *error) {
        XCTFail(@"could not create stream");
        DONE(done1);
    }];
    
    WAIT_FOR_DONE(done1);

    
    
    
    NOT_DONE(changeStreamProperties);
   

    newStream.clientData = @{@"test" : @{ @"value" : @"testValue" }};
    
    [self.connection streamSaveModifications:newStream successHandler:^(PYStream *stream) {
        XCTAssertTrue(stream == newStream, @"should very same stream");
        XCTAssertNotNil(stream, @"should return single stream ");
        DONE(changeStreamProperties);
    } errorHandler:^(NSError *error) {
        XCTFail(@"Unexpected Error: %@", error);
        DONE(changeStreamProperties);

    }];
    
    WAIT_FOR_DONE(changeStreamProperties);
    
    
    NOT_DONE(streamOnlineWithId);
    [self.connection streamOnlineWithId:newStream.streamId
                         successHandler:^(PYStream *stream) {
                             XCTAssertNotNil(stream, @"should return single stream requested by id from the server");
                             XCTAssertNotNil(stream.clientData, @"should have client Data");
                             
                             XCTAssertNotNil([stream.clientData objectForKey:@"test"], @"should have property test");
                             
                             DONE(streamOnlineWithId);
                         } errorHandler:^(NSError *error) {
                             XCTFail(@"Unexpected Error: %@", error);
                             DONE(streamOnlineWithId);
                         }];
    WAIT_FOR_DONE(streamOnlineWithId);

}



- (void)deleteStream:(PYStream *)testStream
{
    NOT_DONE(streamTrashOrDelete);
    [self.connection streamTrashOrDelete:testStream mergeEventsWithParent:YES successHandler:^{
        [self.connection streamTrashOrDelete:testStream mergeEventsWithParent:YES successHandler:^{
            DONE(streamTrashOrDelete);
        } errorHandler:^(NSError *error) {
            XCTFail(@"Failed while deleting stream : %@",error);
            DONE(streamTrashOrDelete);
        }];
    } errorHandler:^(NSError *error) {
        XCTFail(@"Failed while trashing stream : %@",error);
        DONE(streamTrashOrDelete);
    }];
    
    WAIT_FOR_DONE(streamTrashOrDelete);
}


@end
