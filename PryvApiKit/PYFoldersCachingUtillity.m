//
//  PYFoldersCachingUtillity.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 6/12/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYFoldersCachingUtillity.h"
#import "PYCachingController.h"
#import "PYJSONUtility.h"
#import "PYFolder.h"
#import "PYChannel.h"

@implementation PYFoldersCachingUtillity

+ (BOOL)cachingEnabled
{
#if CACHE
    return YES;
#endif
    return NO;
}

+ (void)removeFolder:(PYFolder *)folder
{
    [self removeFolder:folder WithKey:[self getKeyForFolder:folder]];
}

+ (void)removeFolder:(PYFolder *)folder WithKey:(NSString *)key
{
    NSString *folderKey = [NSString stringWithFormat:@"folder_%@",key];
    [[PYCachingController sharedManager] removeFolder:folderKey];
    
}

+ (void)getAndCacheFolderWithServerId:(NSString *)folderId
                            inChannel:(PYChannel *)channel
                          requestType:(PYRequestType)reqType;
{
    //In this method we will ask server for folder with folder and we'll cache it
    
    [channel getOnlineFolderWithId:folderId requestType:reqType successHandler:^(PYFolder *folder) {
        
        [PYFoldersCachingUtillity cacheFolder:folder];
        
    } errorHandler:^(NSError *error) {
        NSLog(@"error");
    }];
}


+ (void)cacheFolders:(NSArray *)folders;
{
    if ([self cachingEnabled]) {
        for (NSDictionary *folderDic in folders) {
            [self cacheFolder:folderDic WithKey:folderDic[@"id"]];
        }        
    }
}

+ (void)cacheFolder:(NSDictionary *)folder WithKey:(NSString *)key
{
    NSString *folderKey = [NSString stringWithFormat:@"folder_%@",key];
    [[PYCachingController sharedManager] cacheData:[PYJSONUtility getDataFromJSONObject:folder] withKey:folderKey];
}

+ (void)cacheFolder:(PYFolder *)folder
{
    NSDictionary *folderDic = [folder cachingDictionary];
//    [self cacheEvent:eventDic WithKey:[self getKeyForEvent:event]];
    [self cacheFolder:folderDic WithKey:[self getKeyForFolder:folder]];
}

+ (NSString *)getKeyForFolder:(PYFolder *)folder
{    
    return folder.folderId;
}


+ (NSArray *)getFoldersFromCache
{
    return [[PYCachingController sharedManager] getAllFoldersFromCache];
}

+ (PYFolder *)getFolderFromCacheWithFolderId:(NSString *)folderId
{
    NSString *folderKey = [NSString stringWithFormat:@"folder_%@",folderId];
    return [[PYCachingController sharedManager] getFolderWithKey:folderKey];
    
}

@end
