//
//  PYEventAttachmentTests.m
//  PrYv-iOS-Example
//
//  Created by Konstantin Dorodov on 03.03.2014.
//  Copyright (c) 2014 PrYv. All rights reserved.
//

#import "PYBaseConnectionTests.h"
#import <PryvAPIKit/PYConstants.h>


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
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    STAssertTrue([event.attachments count] == 1, @"");
    STAssertTrue([event.attachments firstObject] == att, @"attachment not found");
    
    {
        PYAttachment *eventAtt = [event.attachments firstObject];
        STAssertNil(eventAtt.attachmentId, @"before synchronization attachment id should be nil");
        STAssertNil(eventAtt.size, @"before synchronization size should be nil");
        STAssertNil(eventAtt.mimeType, @"before synchronization mimeType should be nil");
        STAssertNotNil(eventAtt.fileData, @"fileData should not be nil");
        STAssertEqualObjects(eventAtt.name, @"Name", @"unexpected attachment name");
        STAssertEqualObjects(eventAtt.fileName, @"SomeFileName123", @"unexpected attachment fileName");
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
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
    successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
        STAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
        //STAssertTrue([stoppedId length] > 0, @"stopped event id should not be nil %@", stoppedId);
        
        PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
        STAssertNotNil(createdAttachment, @"");
        
        //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
        
        DONE(done);
    }
    errorHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
        DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}


- (void)testImageAttachmentCreationOnImageEvent
{
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"TVKoK036of";
    //event.eventContent = [NSString stringWithFormat:@"Test %@", [NSDate date]];
    event.type = @"picture/attached";
    
    NSString *imageDataPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"350x150" ofType:@"png"];
    NSData *imageData = [NSData dataWithContentsOfFile:imageDataPath];
    STAssertNotNil(imageData, @"could not create nsdata from image");
    
    PYAttachment *att = [[PYAttachment alloc] initWithFileData:imageData name:@"Name" fileName:@"SomeFileName123"];
    [event addAttachment:att];
    
    
    NOT_DONE(done);
    [self.connection createEvent:event
                     requestType:PYRequestTypeAsync
      successHandler:^(NSString *newEventId, NSString *stoppedId, PYEvent *createdOrUpdatedEvent) {
          STAssertTrue(newEventId != nil, @"new event id should not be nil %@", newEventId);
          //STAssertTrue([stoppedId length] > 0, @"stopped event id should not be nil %@", stoppedId);
          
          PYAttachment *createdAttachment = [createdOrUpdatedEvent.attachments firstObject];
          STAssertNotNil(createdAttachment, @"");
          
          [createdOrUpdatedEvent preview:^(NSImage *img) {
              
              STAssertNotNil(img, @"");
              
              DONE(done);
              
          } failure:^(NSError *error) {
              STFail(@"unexpected %@", error);
              
              DONE(done);
          }];
          
          //STAssertNotNil(createdAttachment.mimeType, @"mime type should be set");
          
      }
    errorHandler:^(NSError *error) {
        NSLog(@"error: %@", error);
        DONE(done);
    }];
    
    WAIT_FOR_DONE(done);
}

- (void)eventCreated:(NSNotification *)notification
{

}

@end
