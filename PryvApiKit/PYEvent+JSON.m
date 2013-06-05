//
//  PYEvent+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEvent+JSON.h"
#import "PYAttachment.h"

@implementation PYEvent (JSON)

+ (id)eventFromDictionary:(NSDictionary *)JSON
{
    PYEvent *event = [[self alloc] init];
    event.eventId = [JSON objectForKey:@"id"];
    event.channelId = [JSON objectForKey:@"channelId"];
    event.time = [[JSON objectForKey:@"time"] doubleValue];
    
    if ([JSON objectForKey:@"duration"] == [NSNull null]) {
        event.duration = 0;
    }else{
        event.duration = [[JSON objectForKey:@"duration"] doubleValue];
    }
    
    NSDictionary *typeDic = [JSON objectForKey:@"type"];
    event.eventClass = [typeDic objectForKey:@"class"];
    event.eventFormat = [typeDic objectForKey:@"format"];
    event.value = [JSON objectForKey:@"value"];
    
    id folderId = [JSON objectForKey:@"folderId"];
    if ([folderId isKindOfClass:[NSNull class]]) {
        event.folderId = nil;
    }else{
        event.folderId = folderId;
    }

    
    id tags = [JSON objectForKey:@"tags"];
    if ([tags isKindOfClass:[NSNull class]]) {
        event.tags = nil;
    }else{
        event.tags = tags;
    }
    
    event.eventDescription = [JSON objectForKey:@"description"];
    
    NSDictionary *attachmentsDic = [JSON objectForKey:@"attachments"];
    
    if (attachmentsDic) {
        NSMutableArray *attachmentObjects = [[NSMutableArray alloc] initWithCapacity:attachmentsDic.count];
        
        [attachmentsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            [attachmentObjects addObject:[PYAttachment attachmentFromDictionary:obj]];
        }];
        
        event.attachments = attachmentObjects;
        [attachmentObjects release];

    }
    
    event.clientData = [JSON objectForKey:@"clientData"];
    event.trashed = [[JSON objectForKey:@"trashed"] boolValue];
    event.modified = [NSDate dateWithTimeIntervalSince1970:[[JSON objectForKey:@"modified"] doubleValue]];

    return event;
}

@end
