//
//  PYFolder+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYFolder+JSON.h"

@implementation PYFolder (JSON)

+ (PYFolder *)folderFromJSON:(id)JSON
{
    NSDictionary *jsonDictionary = JSON;
    PYFolder *folder = [[PYFolder alloc] init];
    folder.folderId = [jsonDictionary objectForKey:@"id"];
    
    [folder setValue:[jsonDictionary objectForKey:@"channelId"] forKey:@"channelId"];
    
    folder.name = [jsonDictionary objectForKey:@"name"];
    
    NSString *parentId = [jsonDictionary objectForKey:@"parentId"];
    if ([parentId isKindOfClass:[NSNull class]]) {
        folder.parentId = nil;
    }else{
        folder.parentId = parentId;
    }
    
    folder.clientData = [jsonDictionary objectForKey:@"clientData"];
        
    folder.timeCount = [[jsonDictionary objectForKey:@"timeCount"] doubleValue];
    folder.hidden = [[jsonDictionary objectForKey:@"hidden"] boolValue];
    folder.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    
    NSArray *childrenArray = [jsonDictionary objectForKey:@"children"];
    [self setChildrenForFolder:folder withArray:childrenArray];
    
    NSNumber *hasTmpId = [jsonDictionary objectForKey:@"hasTmpId"];
    if ([hasTmpId isKindOfClass:[NSNull class]]) {
        folder.hasTmpId = NO;
    }else{
        folder.hasTmpId = [hasTmpId boolValue];
    }
    
    NSNumber *notSyncAdd = [jsonDictionary objectForKey:@"notSyncAdd"];
    if ([notSyncAdd isKindOfClass:[NSNull class]]) {
        folder.notSyncAdd = NO;
    }else{
        folder.notSyncAdd = [notSyncAdd boolValue];
    }
    
    NSNumber *notSyncModify = [jsonDictionary objectForKey:@"notSyncModify"];
    if ([notSyncModify isKindOfClass:[NSNull class]]) {
        folder.notSyncModify = NO;
    }else{
        folder.notSyncModify = [notSyncModify boolValue];
    }
    
    NSNumber *synchedAt = [jsonDictionary objectForKey:@"synchedAt"];
    if ([synchedAt isKindOfClass:[NSNull class]]) {
        folder.synchedAt = 0;
    }else{
        folder.synchedAt = [synchedAt doubleValue];
    }
    
    NSDictionary *modifiedProperties = [jsonDictionary objectForKey:@"modifiedProperties"];
    if ([modifiedProperties isKindOfClass:[NSNull class]]) {
        folder.modifiedEventPropertiesAndValues = nil;
    }else{
        folder.modifiedEventPropertiesAndValues = modifiedProperties;
    }

    
    return [folder autorelease];
}

+ (void)setChildrenForFolder:(PYFolder *)folder withArray:(NSArray *)children
{
    NSMutableArray *childrenArrayOfFolders = [[NSMutableArray alloc] init];
    for (NSDictionary *folderDic in children) {
        [childrenArrayOfFolders addObject:[self folderFromJSON:folderDic]];
    }
    
    folder.children = [childrenArrayOfFolders copy];
    [childrenArrayOfFolders release];
}

@end
