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
    folder.folderId = @"testFolderId12qwe";
    folder.name = @"testFolderName8736qweq";
    
    
    __block NSString *createdFolderIdFromServer;
    [self.channelForTest createFolder:folder withRequestType:PYRequestTypeSync successHandler:^(NSString *createdFolderId) {
        STAssertNotNil(createdFolderId, @"Error");
        createdFolderIdFromServer = createdFolderId;
    } errorHandler:^(NSError *error) {
        NSLog(@"error %@",error);
    }];
    
    
    NSString *fakeFolderId = @"ashdgasgduasd";
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
