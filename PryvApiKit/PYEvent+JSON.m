//
//  PYEvent+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEvent+JSON.h"
#import "PryvEventType.h"

@implementation PryvEvent (JSON)

+ (id)eventFromDictionary:(NSDictionary *)JSON
{
    PryvEvent *event = [[self alloc] init];
    event.eventId = [JSON objectForKey:@"id"];
    event.channelId = [JSON objectForKey:@"channelId"];
    event.time = [[JSON objectForKey:@"time"] doubleValue];
    
    if ([JSON objectForKey:@"duration"] == [NSNull null]) {
        event.duration = 0;
    }else{
        event.duration = [[JSON objectForKey:@"duration"] doubleValue];
    }
    
    event.type = [PryvEventType eventTypeFromDictionary:[JSON objectForKey:@"type"]];
    event.folderId = [JSON objectForKey:@"folderId"];
    event.tags = [JSON objectForKey:@"tags"];
    event.eventDescription = [JSON objectForKey:@"description"];
    
    NSDictionary *attachmentsDic = [JSON objectForKey:@"attachments"];
    
    if (attachmentsDic) {
        NSMutableArray *attachmentObjects = [[NSMutableArray alloc] initWithCapacity:attachmentsDic.count];
        
        [attachmentsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            [attachmentObjects addObject:[PryvAttachment attachmentFromDictionary:obj]];
        }];
//        for (NSDictionary *attachmentDic in attachments) {
//            [attachmentObjects addObject:[PYAttachment attachmentFromDictionary:attachmentDic]];
//        }
        
        event.attachments = attachmentObjects;
        [attachmentObjects release];

    }
    
    event.clientData = [JSON objectForKey:@"clientData"];
    event.trashed = [[JSON objectForKey:@"trashed"] boolValue];
    event.modified = [NSDate dateWithTimeIntervalSince1970:[[JSON objectForKey:@"modified"] doubleValue]];

    return event;
}

@end
