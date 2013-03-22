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
    folder.channelID = [jsonDictionary objectForKey:@"channelId"];
    folder.name = [jsonDictionary objectForKey:@"name"];
    folder.parentId = [jsonDictionary objectForKey:@"parentId"];
    folder.hidden = [[jsonDictionary objectForKey:@"hidden"] boolValue];
    folder.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    return [folder autorelease];
}

@end
