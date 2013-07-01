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
    
    PYFolder *folder = [[PYFolder alloc] init];
    folder.folderId = @"snfjsgfu6";
    folder.name = @"jskdhf738rgwjh";
    
    
    __block NSString *createdFolderIdFromServer;
    [self.channelForTest createFolder:folder withRequestType:PYRequestTypeSync successHandler:^(NSString *createdFolderId) {
        STAssertNotNil(createdFolderId, @"Error");
        createdFolderIdFromServer = createdFolderId;
    } errorHandler:^(NSError *error) {
        STFail(@"Change folder name or folder id to run this test correctly see error from server %@",error);
    }];
    
    
    NSString *fakeFolderId = @"ashdgasgduasdfgdhjsgfjhsgdhjf";
    PYFolder *folderFromCacheWithFakeId = [PYFoldersCachingUtillity getFolderFromCacheWithFolderId:fakeFolderId];
    STAssertNil(folderFromCacheWithFakeId, @"This must be nil. It's fake folder id");
    
    PYFolder *folderFromCache = [PYFoldersCachingUtillity getFolderFromCacheWithFolderId:createdFolderIdFromServer];
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
