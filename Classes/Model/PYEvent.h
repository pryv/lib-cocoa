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
#define PYEvent_RUNNING -DBL_MAX

#import <Foundation/Foundation.h>
#import "PYStream.h"

@interface PYEvent : NSObject
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

@property (nonatomic, retain) NSError *synchError; // This is set when an error occured on creation / delete / update

@property (nonatomic) NSTimeInterval modified;

# pragma mark - synch status


@property (nonatomic, retain) NSMutableSet *modifiedEventPropertiesToBeSync;

- (id) initWithConnection:(PYConnection*) connection;

/**
 * clientId can be null.. Then a new object with a new clientId will be generated
 */
+ (PYEvent*) createOrReuseWithClientId:(NSString*) clientId;

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

/**
 * get the event endDate, return nil if no endDate
 * return a NSDate with now value if running !!!
 *
 * if (no start Date and has a duration.. then returns nil) .. faulty state
 **/
- (NSDate *)eventEndDate;

/** return true if event is running, same as event.duration   **/
- (BOOL)isRunning;

/** set the state of the event as running, sugar go event.duration = PYEvent_RUNNING **/
- (void)setStateRunning;

/** no duration for event, sugar go event.duration = 0 **/
- (void)resetDuration;

/**
 * date must be > eventDate otherwise will duration will be set to 0
 * if date = nil, the end date will be set to 0
 * if the date has no start date this will be ignored
 **/
- (void)setEventEndDate:(NSDate*)date;

# pragma mark - attachment

- (void)addAttachment:(PYAttachment *)attachment;
- (void)removeAttachment:(PYAttachment *)attachmentToRemove;

# pragma mark - serialization


/**
 * Convert PYEvent object to json-like NSDictionary representation for synching with server
 */
- (NSDictionary *)dictionary;


/**
 * Convert PYEvent object to json-like NSDictionary representation for caching on disk
 */
- (NSDictionary *)cachingDictionary;

/**
 * Reset all the fields from a cachingDictionary. Can be used to rollback an edit change
 */
- (void)resetFromCachingDictionary:(NSDictionary*)dictionary;


- (NSMutableSet *)listModifiedPropertiesAgainstCachedVersion;

# pragma mark - event Types accessors

/**
 Sugar to get the corresponding PYEventType of this event
 */
- (PYEventType *)pyType;

@end
