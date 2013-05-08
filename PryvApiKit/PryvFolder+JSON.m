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
    folder.parentId = [jsonDictionary objectForKey:@"parentId"];
    folder.clientData = [jsonDictionary objectForKey:@"clientData"];
        
    folder.timeCount = [[jsonDictionary objectForKey:@"timeCount"] doubleValue];
    folder.hidden = [[jsonDictionary objectForKey:@"hidden"] boolValue];
    folder.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    
    NSArray *childrenArray = [jsonDictionary objectForKey:@"children"];
    [self setChildrenForFolder:folder withArray:childrenArray];
    
    
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
