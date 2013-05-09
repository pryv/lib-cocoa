//
//  Event.m
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYEvent.h"
#import "PYEvent+JSON.h"
#import "PYAttachment.h"

@implementation PYEvent
@synthesize eventId = _eventId;
@synthesize channelId = _channelId;
@synthesize time = _time;
@synthesize duration = _duration;
@synthesize type = _type;
@synthesize value = _value;
@synthesize folderId = _folderId;
@synthesize tags = _tags;
@synthesize eventDescription = _eventDescription;
@synthesize attachments = _attachments;
@synthesize clientData = _clientData;
@synthesize trashed = _trashed;
@synthesize modified = _modified;


- (NSDictionary *)dictionary {
    
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (_type) {
        [dic setObject:_type forKey:@"type"];
    }
    
    if (_value) {
        [dic setObject:_value forKey:@"value"];
    }
    
    if (_folderId && _folderId.length > 0) {
        [dic setObject:_folderId forKey:@"folderId"];
    }
    
    if (_tags && _tags.count > 0) {
        [dic setObject:_tags forKey:@"tags"];
    }
    
    if (_eventDescription && _eventDescription.length > 0) {
        [dic setObject:_eventDescription forKey:@"description"];
    }
    
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }
    
    return [dic autorelease];
    
}

- (NSArray *)attachments
{
    if (!_attachments) {
        _attachments = [[NSMutableArray alloc] init];
    }
    
    return _attachments;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.eventId=%@", self.eventId];
    [description appendFormat:@", self.channelId=%@", self.channelId];
    [description appendFormat:@", self.time=%f", self.time];
    [description appendFormat:@", self.duration=%f", self.duration];
    [description appendFormat:@", self.type=%@", self.type];
    [description appendFormat:@", self.folderId=%@", self.folderId];
    [description appendFormat:@", self.tags=%@", self.tags];
    [description appendFormat:@", self.description=%@", self.eventDescription];
    [description appendFormat:@", self.attachments=%@", self.attachments];
    [description appendFormat:@", self.clientData=%@", self.clientData];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendFormat:@", self.modified=%@", self.modified];
    [description appendFormat:@", self.TYPE=%@", self.type];
    [description appendFormat:@", self.VALUE=%@",self.value];

    [description appendString:@">"];
    
    return description;
}

- (void)dealloc
{
    [_eventId release];
    [_channelId release];
    [_type release];
    [_value release];
    [_folderId release];
    [_tags release];
    [_eventDescription release];
    [_attachments release];
    [_clientData release];
    [_modified release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
//        self.trashed = NO;
    }
    
    return self;
}

- (void)addAttachment:(PYAttachment *)attachment
{
    [self.attachments addObject:attachment];
}

- (void)removeAttachment:(PYAttachment *)attachmentToRemove
{
    [self.attachments removeObject:attachmentToRemove];
}

+ (id)getEventFromDictionary:(NSDictionary *)JSON;
{        
    PYEvent *generalEvent = [PYEvent eventFromDictionary:JSON];
    return [generalEvent autorelease];
    
}


@end
