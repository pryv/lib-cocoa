//
//  PYChannel+JSON.m
//  PryvApiKit
//
//  Created by Nemanja Kovacevic on 3/25/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannel+JSON.h"

@implementation PYChannel (JSON)

+ (PYChannel *)channelFromJson:(id)json
{
    NSDictionary *jsonDictionary = json;
    PYChannel *channel = [[PYChannel alloc] init];
    
    //because it's readonly property in this case is used KVC to set property
    [channel setValue:[jsonDictionary objectForKey:@"id"] forKey:@"channelId"];
    
//    channel.channelId = [jsonDictionary objectForKey:@"id"];
    channel.name = [jsonDictionary objectForKey:@"name"];
    channel.enforceNoEventsOverlap = [[jsonDictionary objectForKey:@"enforceNoEventsOverlap"] boolValue];
    channel.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    channel.timeCount = [[jsonDictionary objectForKey:@"timeCount"] doubleValue];
    channel.clientData = [jsonDictionary objectForKey:@"clientData"];
    return [channel autorelease];
}

@end
