//
//  Event.m
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYEvent.h"
#import "PYEventType.h"
#import "PYEventAttachment.h"
#import "PYEventValueLocation.h"
#import "PYEventValueWebclip.h"
#import "PYEventNote.h"
#import "PYEventPosition.h"

@implementation PYEvent
@synthesize eventId = _eventId;
@synthesize channelId = _channelId;
@synthesize time = _time;
@synthesize duration = _duration;
@synthesize type = _type;
@synthesize folderId = _folderId;
@synthesize tags = _tags;
@synthesize description = _description;
@synthesize attachments = _attachments;
@synthesize clientData = _clientData;
@synthesize trashed = _trashed;
@synthesize modified = _modified;

- (NSDictionary *)dictionary {
    return @{@"time" : [NSNumber numberWithFloat:self.time],
             @"type" : @{@"class": self.type.eventClassName, @"format" : self.type.eventFormatName},
//             @"folderId" : self.folderId,
//             @"tags" : self.tags,
//             @"description" : self.description,
//             @"clientData" : self.clientData,
             };
}

- (void)dealloc
{
    [_eventId release];
    [_channelId release];
    [_type release];
    [_folderId release];
    [_tags release];
    [_description release];
    [_attachments release];
    [_clientData release];
    [_modified release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.time = [NSDate timeIntervalSinceReferenceDate];
        self.trashed = NO;
    }
    
    return self;
}

+ (void)setPropertiesForEvent:(PYEvent *)event withJSON:(NSDictionary *)JSON
{
    event.eventId = [JSON objectForKey:@"id"];
    event.channelId = [JSON objectForKey:@"channelId"];
    event.time = [[JSON objectForKey:@"time"] doubleValue];
    event.duration = [[JSON objectForKey:@"duration"] doubleValue];
    event.type = [PYEventType eventTypeFromDictionary:[JSON objectForKey:@"type"]];
    event.folderId = [JSON objectForKey:@"folderId"];
    event.tags = [JSON objectForKey:@"tags"];
    event.description = [JSON objectForKey:@"description"];
    
    NSDictionary *attachments = [JSON objectForKey:@"attachments"];
    NSMutableDictionary *attachmentsDic = [[NSMutableDictionary alloc] init];
    [attachments enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        [attachmentsDic setObject:[PYEventAttachment attachmentFromDictionary:obj]
                           forKey:key];
    }];
    
    event.attachments = attachmentsDic;
    [attachmentsDic release];
    
    event.clientData = [JSON objectForKey:@"clientData"];
    event.trashed = [[JSON objectForKey:@"trashed"] boolValue];
    event.modified = [NSDate dateWithTimeIntervalSince1970:[[JSON objectForKey:@"modified"] doubleValue]];
    

}

//Factory method
+ (id)eventFromDictionary:(NSDictionary *)JSON
{    
    PYEventType *eventType = [PYEventType  eventTypeFromDictionary:[JSON objectForKey:@"type"]];
    if ([eventType.eventClassName caseInsensitiveCompare:@"note"] == NSOrderedSame) {
        PYEventNote *noteEvent = [[PYEventNote alloc] init];
        [self setPropertiesForEvent:noteEvent withJSON:JSON];
        
        if ([JSON objectForKey:@"value"]) {
            [noteEvent initWithType:eventType andNoteValue:[JSON objectForKey:@"value"]];
        }
        return [noteEvent autorelease];
        
    }else if ([eventType.eventClassName caseInsensitiveCompare:@"position"] == NSOrderedSame) {
        PYEventPosition *positionEvent = [[PYEventPosition alloc] init];
        [self setPropertiesForEvent:positionEvent withJSON:JSON];
        
        return [positionEvent autorelease];
    }else{
        PYEvent *generalEvent = [[PYEvent alloc] init];
        [self setPropertiesForEvent:generalEvent withJSON:JSON];
        
        return [generalEvent autorelease];
    }

    
    return nil;
    
}

//+ (id)eventValueFromType:(PYEventType *)eventType andDictionary:(NSDictionary *)JSON
//{
//    if ([eventType.eventFormat caseInsensitiveCompare:@"wgs84"] == NSOrderedSame) {
//        
//        NSDictionary *locationDic = [[JSON allValues] objectAtIndex:0];
//        
//        return [PYEventValueLocation locatinFromDictionary:locationDic];
//    }
//    
//    if ([eventType.eventFormat caseInsensitiveCompare:@"webclip"] == NSOrderedSame) {
//        return [PYEventValueWebclip webclipFromDictionary:JSON];
//    }
//    
//    return nil;
//
//}


@end
