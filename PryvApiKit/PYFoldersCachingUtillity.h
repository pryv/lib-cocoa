//
//  PYFoldersCachingUtillity.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYFolder;
@class PYChannel;
#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYFoldersCachingUtillity : NSObject

+ (void)cacheFolders:(NSArray *)folders;
+ (void)removeFolder:(PYFolder *)folder;
+ (NSArray *)getFoldersFromCache;
+ (PYFolder *)getFolderFromCacheWithFolderId:(NSString *)folderId;
+ (void)cacheFolder:(PYFolder *)folder;
+ (void)getAndCacheFolderWithServerId:(NSString *)folderId
                           inChannel:(PYChannel *)channel
                         requestType:(PYRequestType)reqType;

@end
