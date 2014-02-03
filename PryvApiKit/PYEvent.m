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

#import "PYEventTypes.h"
#import "PYConnection+DataManagement.h"
#import "PYConnection+TimeManagement.h"

@interface PYEvent ()
{
    NSTimeInterval _time;
}

@property (nonatomic) NSTimeInterval time;

@end

@implementation PYEvent
@synthesize clientId = _clientId;
@synthesize eventId = _eventId;
@synthesize time = _time;
@synthesize duration = _duration;
@synthesize type = _type;
@synthesize eventContent = _eventContent;
@synthesize streamId = _streamId;
@synthesize tags = _tags;
@synthesize eventDescription = _eventDescription;
@synthesize attachments = _attachments;
@synthesize clientData = _clientData;
@synthesize trashed = _trashed;
@synthesize modified = _modified;
@synthesize synchedAt = _synchedAt;
@synthesize hasTmpId = _hasTmpId;
@synthesize notSyncAdd = _notSyncAdd;
@synthesize notSyncModify = _notSyncModify;
@synthesize notSyncTrashOrDelete = _notSyncTrashOrDelete;
@synthesize isSyncTriedNow = _isSyncTriedNow;
@synthesize modifiedEventPropertiesAndValues = _modifiedEventPropertiesAndValues;
@synthesize connection = _connection;

+ (NSString *)createClientId
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [(NSString *)uuidStringRef autorelease];
}

- (NSDictionary *)cachingDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if (_clientId && _clientId.length > 0) {
        [dic setObject:_clientId forKey:@"clientId"];
    }
    
    if (_eventId && _eventId.length > 0) {
        [dic setObject:_eventId forKey:@"id"];
    }
    
    if (_time != PYEvent_UNDEFINED_TIME) {
        [dic setObject:[NSNumber numberWithDouble:_time] forKey:@"time"];
    }
    
    if (_duration >= 0) {
        [dic setObject:[NSNumber numberWithDouble:_duration] forKey:@"duration"];
    }
    
    //    if ((_eventClass && _eventClass.length > 0) && (_eventFormat && _eventFormat.length > 0)) {
    //        NSArray *objects = [NSArray arrayWithObjects:_eventClass, _eventFormat, nil];
    //        NSArray *keys = [NSArray arrayWithObjects:@"class", @"format", nil];
    //        NSDictionary *typeDic = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    //        [dic setObject:typeDic forKey:@"type"];
    //    }
    if (_type) {
        [dic setObject:_type forKey:@"type"];
    }
    
    
    if (_eventContent) {
        [dic setObject:_eventContent forKey:@"content"];
    }
    
    if (_streamId && _streamId.length > 0) {
        [dic setObject:_streamId forKey:@"streamId"];
    }
    
    if (_tags && _tags.count > 0) {
        [dic setObject:_tags forKey:@"tags"];
    }
    
    if (_eventDescription && _eventDescription.length > 0) {
        [dic setObject:_eventDescription forKey:@"description"];
    }
    
    [dic setObject:[NSNumber numberWithBool:_trashed] forKey:@"trashed"];
    [dic setObject:[NSNumber numberWithDouble:[_modified timeIntervalSince1970]] forKey:@"modified"];
    
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }
    
    
    if (_attachments && _attachments.count > 0) {
        NSMutableDictionary *attachments = [[NSMutableDictionary alloc] init];
        [_attachments enumerateObjectsUsingBlock:^(PYAttachment *attachment, NSUInteger idx, BOOL *stop) {
            [attachments setObject:[attachment cachingDictionary] forKey:attachment.fileName];
        }];
        
        [dic setObject:attachments forKey:@"attachments"];
    }
    
    [dic setObject:[NSNumber numberWithBool:_hasTmpId] forKey:@"hasTmpId"];
    [dic setObject:[NSNumber numberWithBool:_notSyncAdd] forKey:@"notSyncAdd"];
    [dic setObject:[NSNumber numberWithBool:_notSyncModify] forKey:@"notSyncModify"];
    [dic setObject:[NSNumber numberWithBool:_notSyncTrashOrDelete] forKey:@"notSyncTrashOrDelete"];
    if (_modifiedEventPropertiesAndValues) {
        [dic setObject:_modifiedEventPropertiesAndValues forKey:@"modifiedProperties"];
    }
    
    [dic setObject:[NSNumber numberWithDouble:_synchedAt] forKey:@"synchedAt"];
    
    return [dic autorelease];
    
}


- (NSDictionary *)dictionary {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    if (_eventId) {
        [dic setObject:_eventId forKey:@"id"];
    }
    
    if (_type) {
        [dic setObject:_type forKey:@"type"];
    }
    
    if (_eventContent) {
        [dic setObject:_eventContent forKey:@"content"];
    }
    
    if (_streamId && _streamId.length > 0) {
        [dic setObject:_streamId forKey:@"streamId"];
    }
    
    if (_tags) {
        [dic setObject:_tags forKey:@"tags"];
    }
    
    if (_eventDescription) {
        [dic setObject:_eventDescription forKey:@"description"];
    }
    
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }
    
    if (_time > 0) {
        [dic setObject:[NSNumber numberWithDouble:_time] forKey:@"time"];
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
    [description appendFormat:@", self.type=%@", self.type];
    [description appendFormat:@", self.clientId=%@", self.clientId];
    [description appendFormat:@", self.eventId=%@", self.eventId];
    [description appendFormat:@", self.time=%f", self.time];
    [description appendFormat:@", self.duration=%f", self.duration];
    [description appendFormat:@", self.streamId=%@", self.streamId];
    [description appendFormat:@", self.tags=%@", self.tags];
    [description appendFormat:@", self.description=%@", self.eventDescription];
    [description appendFormat:@", self.attachments=%@", self.attachments];
    [description appendFormat:@", self.clientData=%@", self.clientData];
    [description appendFormat:@", self.trashed=%d", self.trashed];
    [description appendFormat:@", self.modified=%@", self.modified];
    [description appendFormat:@", self.content=%@",self.eventContent];
    
    [description appendString:@">"];
    
    return description;
}

- (void)dealloc
{
    [_connection release];
    [_clientId release];
    [_eventId release];
    [_type release];
    [_eventContent release];
    [_streamId release];
    [_tags release];
    [_eventDescription release];
    [_attachments release];
    [_clientData release];
    [_modified release];
    [_modifiedEventPropertiesAndValues release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        #warning fixme
        self.clientId = [PYEvent createClientId];
        self.time = PYEvent_UNDEFINED_TIME;
        self.duration = PYEvent_UNDEFINED_DURATION;
    }
    
    return self;
}

#pragma mark - date



- (NSDate*)eventDate {
    if (self.time == PYEvent_UNDEFINED_TIME) return nil;
    return [self.connection localDateFromServerTime:self.time];
}

- (void) setEventDate:(NSDate *)newDate {
    if (newDate == nil) {
        self.time = PYEvent_UNDEFINED_TIME;
        return;
    }
    self.time = [self.connection serverTimeFromLocalDate:newDate];
}

/** (PRIVATE) set eventTime in "server-Time space" .. for internal user only **/
- (void) setEventServerTime:(NSTimeInterval)newTimeStamp
{
    self.time = newTimeStamp;
}

/** (PRIVATE) get eventTime in "server-Time space" .. for internal user only **/
- (NSTimeInterval) getEventServerTime
{
    return self.time;
}


#pragma mark - attachmennt

- (void)addAttachment:(PYAttachment *)attachment
{
    [self.attachments addObject:attachment];
}

- (void)removeAttachment:(PYAttachment *)attachmentToRemove
{
    [self.attachments removeObject:attachmentToRemove];
}

+ (id)getEventFromDictionary:(NSDictionary *)JSON onConnection:(PYConnection*)connection;
{
    PYEvent *generalEvent = [PYEvent eventFromDictionary:JSON onConnection:connection];
    return generalEvent;
    
}

- (PYEventType *)pyType
{
    return [[PYEventTypes sharedInstance] pyTypeForEvent:self];
}


@end
