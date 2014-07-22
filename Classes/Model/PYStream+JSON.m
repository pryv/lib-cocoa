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
    PYStream *stream = nil;
    
    stream.streamId = [jsonDictionary objectForKey:@"id"];
    [stream resetFromDictionary:jsonDictionary];

    // we have a clientId if event is loaded from cache
    id clientId = [JSON objectForKey:@"clientId"];
    if ([clientId isKindOfClass:[NSNull class]]) {
        stream = [[[self alloc] init] autorelease];
    } else {
        stream = [PYStream createOrReuseWithClientId:clientId];
    }
    
    id streamId = [JSON objectForKey:@"id"];
    if ([streamId isKindOfClass:[NSNull class]]) {
        stream.streamId = nil;
    }else{
        stream.streamId = streamId;
    }
    
    [stream resetFromDictionary:JSON];
    return stream;
}

- (void)resetFromDictionary:(NSDictionary *)jsonDictionary {

    self.name = [jsonDictionary objectForKey:@"name"];
    
    NSString *parentId = [jsonDictionary objectForKey:@"parentId"];
    if ([parentId isKindOfClass:[NSNull class]]) {
        self.parentId = nil;
    }else{
        self.parentId = parentId;
    }
    self.clientData = [jsonDictionary objectForKey:@"clientData"];
        
    self.singleActivity = [[jsonDictionary objectForKey:@"singleActivity"] boolValue];
    self.trashed = [[jsonDictionary objectForKey:@"trashed"] boolValue];
    
    NSArray *childrenArray = [jsonDictionary objectForKey:@"children"];
    [PYStream setChildrenForStream:self withArray:childrenArray];
    
    
    NSNumber *created = [jsonDictionary objectForKey:@"modified"];
    if ([created  isKindOfClass:[NSNull class]]) {
        self.created = PYStream_UNDEFINED_TIME;
    }else{
        self.created = [created  doubleValue];
    }
    self.createdBy = [jsonDictionary objectForKey:@"createdBy"];
   
    NSNumber *modified = [jsonDictionary objectForKey:@"modified"];
    if ([modified isKindOfClass:[NSNull class]]) {
        self.modified = PYStream_UNDEFINED_TIME;
    }else{
        self.modified = [modified doubleValue];
    }
    self.modifiedBy = [jsonDictionary objectForKey:@"modifiedBy"];
   
    
    //---- app support
    NSNumber *hasTmpId = [jsonDictionary objectForKey:@"hasTmpId"];
    if ([hasTmpId isKindOfClass:[NSNull class]]) {
        self.hasTmpId = NO;
    }else{
        self.hasTmpId = [hasTmpId boolValue];
    }
    
    NSNumber *notSyncAdd = [jsonDictionary objectForKey:@"notSyncAdd"];
    if ([notSyncAdd isKindOfClass:[NSNull class]]) {
        self.notSyncAdd = NO;
    }else{
        self.notSyncAdd = [notSyncAdd boolValue];
    }
    
    NSNumber *notSyncModify = [jsonDictionary objectForKey:@"notSyncModify"];
    if ([notSyncModify isKindOfClass:[NSNull class]]) {
        self.notSyncModify = NO;
    }else{
        self.notSyncModify = [notSyncModify boolValue];
    }
    
    NSNumber *synchedAt = [jsonDictionary objectForKey:@"synchedAt"];
    if ([synchedAt isKindOfClass:[NSNull class]]) {
        self.synchedAt = 0;
    }else{
        self.synchedAt = [synchedAt doubleValue];
    }
    
    NSDictionary *modifiedProperties = [jsonDictionary objectForKey:@"modifiedProperties"];
    if ([modifiedProperties isKindOfClass:[NSNull class]]) {
        self.modifiedStreamPropertiesAndValues = nil;
    }else{
        self.modifiedStreamPropertiesAndValues = modifiedProperties;
    }
}

+ (void)setChildrenForStream:(PYStream *)stream withArray:(NSArray *)childrenDict
{
    NSMutableArray *childrenArrayOfStreams = [[NSMutableArray alloc] init];
    for (NSDictionary *streamDic in childrenDict) {
        [childrenArrayOfStreams addObject:[self streamFromJSON:streamDic]];
    }
    
    stream.children = childrenArrayOfStreams;
    [childrenArrayOfStreams release];
}

@end
