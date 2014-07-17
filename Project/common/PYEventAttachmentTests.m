//
//  PYEventAttachmentTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import <PryvAPIKit/PYAPIConstants.h>


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
    event.streamId = @"TVKoK036of";
    event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"note/txt";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSLog(@"imageDataPath: %@", imageDataPath);
    STAssertNotNil(imageDataPath, @"should have found image in the bundle");
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    STAssertNotNil(imageData, @"could not create nsdata from image");

    STAssertEquals([event.attachments count], (NSUInteger)0, @"there should be zero attachments");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    STAssertTrue([[att description] length] > 0, @"attachment description exists");
    
    STAssertEquals([event.attachments count], (NSUInteger)1, @"there should be just one attachment");
    STAssertTrue([event.attachments firstObject] == att, @"attachment not found");
    
    [event removeAttachment:att];
    STAssertEquals([event.attachments count], (NSUInteger)0, @"there should be zero attachments after attachment remove");

    [event addAttachment:att];
    
    STAssertEquals([event.attachments count], (NSUInteger)1, @"there should be just one attachment");
    
    {
        PYAttachment *eventAtt = [event.attachments firstObject];
        STAssertNil(eventAtt.attachmentId, @"before synchronization attachment id should be nil");
        STAssertNil(eventAtt.size, @"before synchronization size should be nil");
        STAssertNil(eventAtt.mimeType, @"before synchronization mimeType should be nil");
        STAssertNotNil(eventAtt.fileData, @"fileData should not be nil");
        STAssertEqualObjects(eventAtt.name, @"Name", @"unexpected attachment name");
        STAssertEqualObjects(eventAtt.fileName, @"SomeFileName123", @"unexpected attachment fileName");
    }
    
    NOT_DONE(done);
    [event preview:^(PYImage *img) {
        STFail(@"when there is no connection there is no preview");
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
    event.streamId = @"TVKoK036of";
    event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"note/txt";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    STAssertNotNil(imageData, @"could not create nsdata from image");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
        STAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
        //STAssertTrue([stoppedId length] > 0, @"stopped event id should not be nil %@", stoppedId);
        
        PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
        STAssertNotNil(createdAttachment, @"");

        STAssertTrue([[createdAttachment description] length] > 0, @"attachment description exists");
        
        //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
        
        DONE(done);
    }
    errorHandler:^(NSError *error) {
        STFail(@"Failed creating event. %@", error);
        DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}


- (void)testImageAttachmentNotCreatedOnImageEvent
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    //event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"picture/attached";
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
      STAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
      
      PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
      STAssertNil(createdAttachment, @"");
      
      [createdOrUpdatedEvent preview:^(PYImage *img) {
          STFail(@"Should not get preview");
          DONE(done);
      } failure:^(NSError *error) {
          STAssertEquals(error.code, (NSInteger)422, @""); // corrupted data expected
          DONE(done);
      }];
      //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
    }
    errorHandler:^(NSError *error) {
            STFail(@"Failed creating event. %@", error);
            DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}


- (void)testImageAttachment
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    event.type = @"picture/attached";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSLog(@"imageDataPath: %@", imageDataPath);
    STAssertNotNil(imageDataPath, @"should have found image in the bundle");
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    STAssertNotNil(imageData, @"could not create nsdata from image");
    
    STAssertEquals([event.attachments count], (NSUInteger)0, @"there should be zero attachments");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    
    NOT_DONE(done00);
    [event dataForAttachment:att
      successHandler:^(NSData *data) {
          DONE(done00);
      } errorHandler:^(NSError *error) {
          STFail(@"should not fail %@", error);
          DONE(done00);
      }];
    WAIT_FOR_DONE(done00);
    
    
    NOT_DONE(done2);
    [event preview:^(PYImage *img) {
        STFail(@"there should not be an image if there is no connection");
        DONE(done2);
    } failure:^(NSError *error) {
        DONE(done2);
    }];
    WAIT_FOR_DONE(done2);
    
    
    NOT_DONE(done);
    [self.connection eventCreate:event
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
      STAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
      
      PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
      STAssertNotNil(createdAttachment, @"");
      
      [createdOrUpdatedEvent preview:^(PYImage *img) {
          STAssertNotNil(img, @"");
          DONE(done);
      } failure:^(NSError *error) {
          STFail(@"there should be an preview at this point");
          DONE(done);
      }];
    }
    errorHandler:^(NSError *error) {
            STFail(@"Failed creating event. %@", error);
            DONE(done);
    }];
    WAIT_FOR_DONE(done);
    
    
    
    NOT_DONE(done3);
    [event preview:^(PYImage *img) {
        STAssertNotNil(img, @"there should be an image after it was downloaded");
        DONE(done3);
    } failure:^(NSError *error) {
        STFail(@"there should be an image after it was downloaded");
        DONE(done3);
    }];
    WAIT_FOR_DONE(done3);
    

}


@end
