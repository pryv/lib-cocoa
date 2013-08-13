//
//  PYFoldersTests.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/26/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYFoldersTests.h"

@implementation PYFoldersTests

- (void)setUp
{
    [super setUp];
    
}

- (void)testFolders
{
    STAssertNotNil(self.access, @"Access isn't created");
    [self testGettingChannels];
    STAssertNotNil(self.channelForTest, @"Test channel isn't created");
    
    PYStream *folder = [[PYStream alloc] init];
    folder.streamId = @"snfjsgfu6";
    folder.name = @"jskdhf738rgwjh";
    
    
    __block NSString *createdFolderIdFromServer;
    [self.channelForTest createFolder:folder withRequestType:PYRequestTypeSync successHandler:^(NSString *createdFolderId) {
        STAssertNotNil(createdFolderId, @"Error");
        createdFolderIdFromServer = createdFolderId;
    } errorHandler:^(NSError *error) {
        STFail(@"Change folder name or folder id to run this test correctly see error from server %@",error);
    }];
    
    
    NSString *fakeFolderId = @"ashdgasgduasdfgdhjsgfjhsgdhjf";
    PYStream *folderFromCacheWithFakeId = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:fakeFolderId];
    STAssertNil(folderFromCacheWithFakeId, @"This must be nil. It's fake folder id");
    
    PYStream *folderFromCache = [PYStreamsCachingUtillity getStreamFromCacheWithStreamId:createdFolderIdFromServer];
    STAssertNotNil(folderFromCache, @"");
    
    [self.channelForTest getAllFoldersWithRequestType:PYRequestTypeSync filterParams:nil gotCachedFolders:NULL gotOnlineFolders:^(NSArray *onlineFolderList) {
        STAssertTrue(onlineFolderList.count > 0, @"");
    } errorHandler:NULL];
}

- (void)tearDown
{
    [super tearDown];
}

@end
