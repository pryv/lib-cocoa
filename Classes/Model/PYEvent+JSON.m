//
//  PYEvent+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEvent+JSON.h"
#import "PYAttachment.h"
#import "PYCachingController.h"
#import "PYConnection.h"
#import "PYEventType.h"

@implementation PYEvent (JSON)



+ (PYEvent*)eventFromDictionary:(NSDictionary *)JSON onConnection:(PYConnection *)connection;
{
    if (connection == nil) {
        [NSException raise:@"Connection cannot be nil" format:nil];
    }
    
    PYEvent *event;
    // we have a clientId if event is loaded from cache
    id clientId = [JSON objectForKey:@"clientId"];
    if ([clientId isKindOfClass:[NSNull class]]) {
        event = [[[self alloc] init] autorelease];
    } else {
        event = [PYEvent createOrReuseWithClientId:clientId];
    }
    
    id eventId = [JSON objectForKey:@"id"];
    if ([eventId isKindOfClass:[NSNull class]]) {
        event.eventId = nil;
    }else{
        event.eventId = eventId;
    }
    
    [event resetFromDictionary:JSON];
    event.connection = connection;
    return event;
}


- (void)resetFromDictionary:(NSDictionary *)JSON
{
    id streamId = [JSON objectForKey:@"streamId"];
    if ([streamId isKindOfClass:[NSNull class]]) {
        self.streamId = nil;
    }else{
        self.streamId = streamId;
    }
    
    [self setEventServerTime:[[JSON objectForKey:@"time"] doubleValue]];
    if ([JSON objectForKey:@"duration"] == [NSNull null]) {
        self.duration = 0;
    }else{
        self.duration = [[JSON objectForKey:@"duration"] doubleValue];
    }
    
    id eventType = [JSON objectForKey:@"type"];
    
    
    if([[eventType class] isSubclassOfClass:[NSDictionary class]])
    {
        NSDictionary *eventTypeDic = (NSDictionary*)eventType;
        self.type = [NSString stringWithFormat:@"%@/%@",
                     [eventTypeDic objectForKey:@"class"],
                     [eventTypeDic objectForKey:@"type"]];
    }
    else
    {
        self.type = eventType;
    }
    
    id _tempcontent = [JSON objectForKey:@"content"];
    if (_tempcontent == [NSNull null]) {
        self.eventContent = nil;
    }else{
         self.eventContent = _tempcontent;
    }
    
    
    id tags = [JSON objectForKey:@"tags"];
    if ([tags isKindOfClass:[NSNull class]]) {
        self.tags = nil;
    }else{
        self.tags = tags;
    }
    
    self.eventDescription = [JSON objectForKey:@"description"];
    
   
    id tempAtts = [JSON objectForKey:@"attachments"];
   
    
   
    if (tempAtts) {
        //**** v0.6 to 0.7 switch
        NSArray *attachmentsArray = nil;
        if([[tempAtts class] isSubclassOfClass:[NSDictionary class]]) {
            attachmentsArray = [tempAtts allValues];
        } else {
            attachmentsArray = tempAtts;
        }
        
        
        NSMutableArray *attachmentObjects = [[NSMutableArray alloc] initWithCapacity:[attachmentsArray count]];
        
        [attachmentsArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            [attachmentObjects addObject:[PYAttachment attachmentFromDictionary:obj]];
        }];
        
        self.attachments = attachmentObjects;
        [attachmentObjects release];
    }
    
    self.clientData = [JSON objectForKey:@"clientData"];
    self.trashed = [[JSON objectForKey:@"trashed"] boolValue];
    
    NSNumber *modified = [JSON objectForKey:@"modified"];
    if ([modified isKindOfClass:[NSNull class]]) {
        self.modified = PYEvent_UNDEFINED_TIME;
    }else{
        self.modified = [modified doubleValue];
    }
    
    
    NSArray *modifiedProperties = [JSON objectForKey:@"modifiedProperties"];
    if ([modifiedProperties isKindOfClass:[NSNull class]]) {
        self.modifiedEventPropertiesToBeSync = nil;
    }else{
        self.modifiedEventPropertiesToBeSync =
        [NSMutableSet setWithArray:modifiedProperties];
    }
    
    NSNumber *synchedAt = [JSON objectForKey:@"synchedAt"];
    if ([synchedAt isKindOfClass:[NSNull class]]) {
        self.synchedAt = PYEvent_UNDEFINED_TIME;
    }else{
        self.synchedAt = [synchedAt doubleValue];
    }
}

@end
