//
//  PYStream+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYStream+JSON.h"
#import "PYConnection.h"

@implementation PYStream (JSON)

+ (PYStream *)streamFromJSON:(id)JSON
{
    NSDictionary *jsonDictionary = JSON;
    PYStream *stream = [[PYStream alloc] init];
    stream.streamId = [jsonDictionary objectForKey:@"id"];
    
    stream.name = [jsonDictionary objectForKey:@"name"];
    
    NSString *parentId = [jsonDictionary objectForKey:@"parentId"];
    if ([parentId isKindOfClass:[NSNull class]]) {
        stream.parentId = nil;
    }else{
        stream.parentId = parentId;
    }
    stream.clientData = [jsonDictionary objectForKey:@"clientData"];
        
    stream.timeCount = [[jsonDictionary objectForKey:@"timeCount"] doubleValue];
    stream.singleActivity = [[jsonDictionary objectForKey:@"singleActivity"] boolValue];
    stream.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    
    NSArray *childrenArray = [jsonDictionary objectForKey:@"children"];
    [self setChildrenForStream:stream withArray:childrenArray];
    
    NSNumber *hasTmpId = [jsonDictionary objectForKey:@"hasTmpId"];
    if ([hasTmpId isKindOfClass:[NSNull class]]) {
        stream.hasTmpId = NO;
    }else{
        stream.hasTmpId = [hasTmpId boolValue];
    }
    
    NSNumber *notSyncAdd = [jsonDictionary objectForKey:@"notSyncAdd"];
    if ([notSyncAdd isKindOfClass:[NSNull class]]) {
        stream.notSyncAdd = NO;
    }else{
        stream.notSyncAdd = [notSyncAdd boolValue];
    }
    
    NSNumber *notSyncModify = [jsonDictionary objectForKey:@"notSyncModify"];
    if ([notSyncModify isKindOfClass:[NSNull class]]) {
        stream.notSyncModify = NO;
    }else{
        stream.notSyncModify = [notSyncModify boolValue];
    }
    
    NSNumber *synchedAt = [jsonDictionary objectForKey:@"synchedAt"];
    if ([synchedAt isKindOfClass:[NSNull class]]) {
        stream.synchedAt = 0;
    }else{
        stream.synchedAt = [synchedAt doubleValue];
    }
    
    NSDictionary *modifiedProperties = [jsonDictionary objectForKey:@"modifiedProperties"];
    if ([modifiedProperties isKindOfClass:[NSNull class]]) {
        stream.modifiedStreamPropertiesAndValues = nil;
    }else{
        stream.modifiedStreamPropertiesAndValues = modifiedProperties;
    }

    
    return [stream autorelease];
}

+ (void)setChildrenForStream:(PYStream *)stream withArray:(NSArray *)children
{
    NSMutableArray *childrenArrayOfStreams = [[NSMutableArray alloc] init];
    for (NSDictionary *streamDic in children) {
        [childrenArrayOfStreams addObject:[self streamFromJSON:streamDic]];
    }
    
    stream.children = childrenArrayOfStreams;
    [childrenArrayOfStreams release];
}

@end
