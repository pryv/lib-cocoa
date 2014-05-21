//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

@class PYEventType;
@class PYAttachment;
@class PYConnection;


#define PYEvent_UNDEFINED_TIME -DBL_MAX
#define PYEvent_UNDEFINED_DURATION -DBL_MAX

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import "PYStream.h"

@interface PYEvent : NSManagedObject
{
    NSString  *_clientId;
    
    NSString  *_eventId;
    NSString  *_streamId;
    NSTimeInterval _duration;
    NSString *_type;
    id _eventContent;
    NSArray *_tags;
    NSString  *_eventDescription;
    NSMutableArray *_attachments;
    NSDictionary *_clientData;
    BOOL _trashed;
    
    /** in server TimeSpace **/
    NSTimeInterval _modified;
    
    
//    NSTimeInterval _timeIntervalWhenCreationTried;
    
    
    /** timestamp in client time space **/
    NSTimeInterval _synchedAt;
    BOOL _toBeSync;
    BOOL _isSyncTriedNow;
    NSMutableSet *_modifiedEventPropertiesToBeSync;
    
    PYConnection  *_connection;

@private
    NSTimeInterval _time;
}

@property (nonatomic, retain) PYConnection  *connection;
/** client side id only.. remain the same before and after synching **/
@property (nonatomic, retain) NSString  *clientId;

# pragma mark - API Matching properties
@property (nonatomic, copy) NSString  *eventId;
@property (nonatomic, copy) NSString  *streamId;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, retain) id eventContent;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, copy) NSString  *eventDescription;
/** array of PYEventAttachment objects **/
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, retain) NSDictionary *clientData;
@property (nonatomic) BOOL trashed;

@property (nonatomic) NSTimeInterval modified;

# pragma mark - synch status


@property (nonatomic, retain) NSMutableSet *modifiedEventPropertiesToBeSync;

- (id) initWithConnection:(PYConnection*) connection;

+ (PYEvent*) createOrRetreiveWithClientId:(NSString*) clientId;

/**
 hasTmpId - Check if event from cache has tmpId. If event has it it means that isn't sync from server (created offline)
 */
- (BOOL) hasTmpId;

/**
 toBeSync - return True if event has to be Synched
 */
- (BOOL) toBeSync;

/**
 isDraft - return True if event has NOT to be Synched and had a Temp Id (sugar for hasTmpId && !toBeSync)
 */
- (BOOL) isDraft;

/** 
 * private , used by PyConnection
 **/
- (BOOL) toBeSyncSkipCacheTest;

/**
 @property isSyncTriedNow - Flag for non sync event. If app tries to sync event a few times this is used to determine what flags should be added to event
 */
@property (nonatomic) BOOL isSyncTriedNow;


/**
 @property synchedAt - (PRIVATE) Timestamp in serverTime when event is synced with server
 */
@property NSTimeInterval synchedAt;


# pragma mark - stream

/** return the stream linked to this object of nil if unkown or not fetched **/
- (PYStream*)stream;


# pragma mark - date

/** get event Date, return "nil" if undefined **/
- (NSDate *)eventDate;

/** set event Date. "nil" if undefined. If nil will be synched as "NOW" **/
- (void)setEventDate:(NSDate *)newDate;

/** (PRIVATE) set eventTime in "server-Time space" .. for internal user only **/
- (void)setEventServerTime:(NSTimeInterval)newTimeStamp;

/** (PRIVATE) get eventTime in "server-Time space" .. for internal user only **/
- (NSTimeInterval)getEventServerTime;

# pragma mark - attachment

- (void)addAttachment:(PYAttachment *)attachment;
- (void)removeAttachment:(PYAttachment *)attachmentToRemove;

# pragma mark - serialization

/**
 Get PYEvent object from json dictionary representation (JSON representation can include additioanl helper properties for event). It means that this method 'read' event from disk and from server
 */
+ (id)eventFromDictionary:(NSDictionary *)JSON onConnection:(PYConnection *)connection;
/**
 Convert PYEvent object to json-like NSDictionary representation for synching with server
 */
- (NSDictionary *)dictionary;
/**
 Convert PYEvent object to json-like NSDictionary representation for caching on disk
 */
- (NSDictionary *)cachingDictionary;


# pragma mark - changes tools
/**
 Reset all the fields from the cache. Can be used to rollback an edit change
 */
- (void)resetFromCache;


- (NSMutableSet *)listModifiedPropertiesAgainstCachedVersion;

# pragma mark - event Types accessors

/**
 Sugar to get the corresponding PYEventType of this event
 */
- (PYEventType *)pyType;

@end
