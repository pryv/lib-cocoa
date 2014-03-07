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

#import "PYEventType.h"
#import "PYEventTypes.h"
#import "PYConnection+DataManagement.h"
#import "PYConnection+TimeManagement.h"
#import "PYEvent+Supervisor.h"
#import "PYConnection.h"
#import "PYCachingController+Event.h"

@interface PYEvent ()


@property (nonatomic) NSTimeInterval time;

- (id) initWithConnection:(PYConnection*) connection andClientId:(NSString*) clientId;

+ (NSString *)createClientId;

/**
 @property modifiedEventPropertiesToBeSync 
 - NSMutableSet that list event properties should be modified on server during the synching
 - Those values are set when updating fails by comparing values from the cache
 */

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
@synthesize modifiedEventPropertiesToBeSync = _modifiedEventPropertiesToBeSync;
@synthesize connection = _connection;
@synthesize isSyncTriedNow = _isSyncTriedNow;

+ (NSString *)createClientId
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return [(NSString *)uuidStringRef autorelease];
}

- (id) init
{
    return [self initWithConnection:nil];
}

+ (PYEvent*) createOrRetreiveWithClientId:(NSString*) clientId {
    if (clientId) {
        PYEvent* liveEvent = [PYEvent liveEventForClientId:clientId];
        if (liveEvent) {
            return liveEvent;
        }
    }
    return [[[PYEvent alloc] initWithConnection:nil andClientId:clientId] autorelease];
}

- (id) initWithConnection:(PYConnection*) connection {
    return [self initWithConnection:connection andClientId:nil];
}

- (id) initWithConnection:(PYConnection*) connection andClientId:(NSString*) clientId {
    self = [super init];
    if (self)
    {
        if (clientId) {
            _clientId = clientId;
        } else {
            _clientId = [PYEvent createClientId];
        }
        #warning fixme
        [_clientId retain]; // should we retain?
        
        [self superviseIn];
        
        self.time = PYEvent_UNDEFINED_TIME;
        self.duration = PYEvent_UNDEFINED_DURATION;
        self.synchedAt = PYEvent_UNDEFINED_TIME;
        self.modified = PYEvent_UNDEFINED_TIME;
        self.connection = connection;
    }
    return self;
}





- (BOOL) hasTmpId {
    return (self.eventId == nil || [self.eventId isEqualToString:self.clientId]);
}


/**
 * toBeSync - return True if event has to be Synched
 * True if is known by cache (i.e. has been created) AND 
 *  (hasTmpId <-- to be created OR modifiedPropertiesAndValues.count > 0 to be updated)
 */
- (BOOL) toBeSync {
   return ([self toBeSyncSkipCacheTest] && [self.connection.cache eventIsKnownByCache:self]);
}

- (BOOL) isDraft {
    return ([self hasTmpId] && (! [self toBeSync]));
}

- (BOOL) toBeSyncSkipCacheTest {
    return (self.hasTmpId ||
             (self.modifiedEventPropertiesToBeSync != nil &&
              self.modifiedEventPropertiesToBeSync.count > 0));
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
    
    
    if (_clientData && _clientData.count > 0) {
        [dic setObject:_clientData forKey:@"clientData"];
    }
    
    
    if (_attachments && _attachments.count > 0) {
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        [_attachments enumerateObjectsUsingBlock:^(PYAttachment *attachment, NSUInteger idx, BOOL *stop) {
            [attachments addObject:[attachment cachingDictionary]];
        }];
        
        [dic setObject:attachments forKey:@"attachments"];
    }
    
    
    if (_modifiedEventPropertiesToBeSync) {
        [dic setObject:[_modifiedEventPropertiesToBeSync allObjects] forKey:@"modifiedProperties"];
    }
    
    if (_synchedAt != PYEvent_UNDEFINED_TIME) {
        [dic setObject:[NSNumber numberWithDouble:_synchedAt] forKey:@"synchedAt"];
    }
    
    if (_modified != PYEvent_UNDEFINED_TIME) {
        [dic setObject:[NSNumber numberWithDouble:_modified] forKey:@"modified"];
    }
    
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
        
        if ([[self pyType] isNumerical] && ! [_eventContent isKindOfClass:[NSNumber class]]) {
            if ([_eventContent isKindOfClass:[NSString class]]) {
                self.eventContent = [NSNumber numberWithDouble: [(NSString*)_eventContent doubleValue]] ;
            } else {
                NSLog(@"<WARNING> invalid value for numerical event %@", [self clientId]);
            }
        }
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
    
    if (_time != PYEvent_UNDEFINED_TIME) {
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
    [description appendFormat:@", self.modified=%f", self.modified];
    [description appendFormat:@", self.content=%@",self.eventContent];
    
    [description appendString:@">"];
    
    return description;
}

- (void)dealloc
{
    [self superviseOut];
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
    [_modifiedEventPropertiesToBeSync release];
    [super dealloc];
}

#pragma mark - date


- (NSDate*)eventDate {
    if (self.time == PYEvent_UNDEFINED_TIME) return nil;
    if (! self.connection) {
# warning do the following comment
        /**
         * If an event has a time without serverTime It should keep a tempTime
         * property up to date that will be updated..
         */

        return [NSDate dateWithTimeIntervalSince1970:self.time];
    }

    return [self.connection localDateFromServerTime:self.time];
}

- (void) setEventDate:(NSDate *)newDate {
    if (newDate == nil) {
        self.time = PYEvent_UNDEFINED_TIME;
        return;
    }
    if (! self.connection) {
        self.time = [newDate timeIntervalSince1970];
# warning do the following comment
        /**
         * If an event has a time without serverTime It should keep a tempTime 
         * property up to date that will be updated..
         */
        return ;
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

# pragma mark - changes tools
/**
 Reset all the fields from the cache. Can be used to rollback an edit change
 */
- (void) resetFromCache {
    if (self.connection) {
        [self.connection.cache resetEventFromDictionary:self];
    }
}


- (NSMutableSet*) listModifiedPropertiesAgainstCachedVersion {
#warning TODO
    return nil;
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

+ (id)eventFromDictionary:(NSDictionary *)JSON onConnection:(PYConnection*)connection;
{
    PYEvent *generalEvent = [PYEvent _eventFromDictionary:JSON onConnection:connection];
    return generalEvent;
    
}

- (PYEventType *)pyType
{
    return [[PYEventTypes sharedInstance] pyTypeForEvent:self];
}



@end
