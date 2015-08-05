//
//  PYEventAttachmentTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import <PryvAPIKit/PYAPIConstants.h>
#import "PYTestConstants.h"


@interface PYEventAttachmentTests : PYBaseConnectionTests
@property (nonatomic, strong) id observer;
@end


@implementation PYEventAttachmentTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testAttachmentCreationJustLocally
{
    //NOT_DONE(done);
    
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = kPYAPITestStreamId;
    event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"note/txt";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSLog(@"imageDataPath: %@", imageDataPath);
    XCTAssertNotNil(imageDataPath, @"should have found image in the bundle");
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    XCTAssertNotNil(imageData, @"could not create nsdata from image");

    XCTAssertEqual([event.attachments count], (NSUInteger)0, @"there should be zero attachments");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    XCTAssertTrue([[att description] length] > 0, @"attachment description exists");
    
    XCTAssertEqual([event.attachments count], (NSUInteger)1, @"there should be just one attachment");
    XCTAssertTrue([event.attachments firstObject] == att, @"attachment not found");
    
    [event removeAttachment:att];
    XCTAssertEqual([event.attachments count], (NSUInteger)0, @"there should be zero attachments after attachment remove");

    [event addAttachment:att];
    
    XCTAssertEqual([event.attachments count], (NSUInteger)1, @"there should be just one attachment");
    
    {
        PYAttachment *eventAtt = [event.attachments firstObject];
        XCTAssertNil(eventAtt.attachmentId, @"before synchronization attachment id should be nil");
        XCTAssertNil(eventAtt.size, @"before synchronization size should be nil");
        XCTAssertNil(eventAtt.mimeType, @"before synchronization mimeType should be nil");
        XCTAssertNotNil(eventAtt.fileData, @"fileData should not be nil");
        XCTAssertEqualObjects(eventAtt.name, @"Name", @"unexpected attachment name");
        XCTAssertEqualObjects(eventAtt.fileName, @"SomeFileName123", @"unexpected attachment fileName");
    }
    
    NOT_DONE(done);
    [event preview:^(PYImage *img) {
        XCTFail(@"when there is no connection there is no preview");
        DONE(done);
    } failure:^(NSError *error) {
        // failure expected
        DONE(done);
    }];
    WAIT_FOR_DONE(done);
    
    for (PYAttachment *a in event.attachments) {
        [event removeAttachment:a];
    }
}

- (void)testAttachmentCreation
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = kPYAPITestStreamId;
    event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"note/txt";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    XCTAssertNotNil(imageData, @"could not create nsdata from image");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
        XCTAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
        //STAssertTrue([stoppedId length] > 0, @"stopped event id should not be nil %@", stoppedId);
        
        PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
        XCTAssertNotNil(createdAttachment, @"");

        XCTAssertTrue([[createdAttachment description] length] > 0, @"attachment description exists");
        
        //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
        
        DONE(done);
    }
    errorHandler:^(NSError *error) {
        XCTFail(@"Failed creating event. %@", error);
        DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}


- (void)testImageAttachmentNotCreatedOnImageEvent
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = kPYAPITestStreamId;
    //event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"picture/attached";
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
      XCTAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
      
      PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
      XCTAssertNil(createdAttachment, @"");
      
      [createdOrUpdatedEvent preview:^(PYImage *img) {
          XCTFail(@"Should not get preview");
          DONE(done);
      } failure:^(NSError *error) {
          XCTAssertEqual(error.code, (NSInteger)422, @""); // corrupted data expected
          DONE(done);
      }];
      //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
    }
    errorHandler:^(NSError *error) {
            XCTFail(@"Failed creating event. %@", error);
            DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}


- (void)testImageAttachment
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = kPYAPITestStreamId;
    event.type = @"picture/attached";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSLog(@"imageDataPath: %@", imageDataPath);
    XCTAssertNotNil(imageDataPath, @"should have found image in the bundle");
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    XCTAssertNotNil(imageData, @"could not create nsdata from image");
    
    XCTAssertEqual([event.attachments count], (NSUInteger)0, @"there should be zero attachments");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    
    NOT_DONE(done00);
    [event dataForAttachment:att
      successHandler:^(NSData *data) {
          DONE(done00);
      } errorHandler:^(NSError *error) {
          XCTFail(@"should not fail %@", error);
          DONE(done00);
      }];
    WAIT_FOR_DONE(done00);
    
    
    NOT_DONE(done2);
    [event preview:^(PYImage *img) {
        XCTFail(@"there should not be an image if there is no connection");
        DONE(done2);
    } failure:^(NSError *error) {
        DONE(done2);
    }];
    WAIT_FOR_DONE(done2);
    
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
      XCTAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
      
      PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
      XCTAssertNotNil(createdAttachment, @"");
      
      [createdOrUpdatedEvent preview:^(PYImage *img) {
          XCTAssertNotNil(img, @"");
          DONE(done);
      } failure:^(NSError *error) {
          XCTFail(@"there should be an preview at this point");
          DONE(done);
      }];
    }
    errorHandler:^(NSError *error) {
            XCTFail(@"Failed creating event. %@", error);
            DONE(done);
    }];
    WAIT_FOR_DONE(done);
    
    
    
    NOT_DONE(done3);
    [event preview:^(PYImage *img) {
        XCTAssertNotNil(img, @"there should be an image after it was downloaded");
        DONE(done3);
    } failure:^(NSError *error) {
        XCTFail(@"there should be an image after it was downloaded");
        DONE(done3);
    }];
    WAIT_FOR_DONE(done3);
    

}


@end
