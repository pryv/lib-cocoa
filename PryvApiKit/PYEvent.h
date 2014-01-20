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

#import <Foundation/Foundation.h>

@interface PYEvent : NSObject
{
    NSString  *_clientId;
    NSString  *_eventId;
    NSString  *_streamId;
    
    NSTimeInterval _time;
    NSTimeInterval _duration;
    
    NSString *_type;
    id _eventContent;
    
    NSArray *_tags;
    NSString  *_eventDescription;
    NSMutableArray *_attachments;
    NSDictionary *_clientData;
    BOOL _trashed;
    NSDate *_modified;
    NSTimeInterval _synchedAt;
//    NSTimeInterval _timeIntervalWhenCreationTried;
    
    BOOL _hasTmpId;
    BOOL _notSyncAdd;
    BOOL _notSyncModify;
    BOOL _notSyncTrashOrDelete;
    BOOL _isSyncTriedNow;
    NSDictionary *_modifiedEventPropertiesAndValues;
    
    PYConnection  *_connection;

}
/** client side id only.. remain the same before and after synching **/
@property (nonatomic, retain) NSString  *clientId;
@property (nonatomic, retain) NSString  *eventId;
@property (nonatomic, retain) NSString  *streamId;

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, retain) NSString *type;

@property (nonatomic, retain) id eventContent;

@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSString  *eventDescription;

@property (nonatomic, retain) PYConnection  *connection;

//array of PYEventAttachment objects
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, retain) NSDictionary *clientData;
@property (nonatomic) BOOL trashed;
@property (nonatomic, retain) NSDate *modified;

/**
 @property hasTmpId - Check if event from cache has tmpId. If event has it it means that isn't sync from server (created offline)
 */
@property (nonatomic) BOOL hasTmpId;
/**
 @property notSyncAdd - Flag for non sync event. It describes that user tried to create event but it failed due to offline status of library
 When library goes online this flag is used to sync event
 */
@property (nonatomic) BOOL notSyncAdd;
/**
 @property notSyncModify - Flag for non sync event. It describes that user tried to modify event but it failed due to offline status of library
 When library goes online this flag is used to sync event
 */
@property (nonatomic) BOOL notSyncModify;
/**
 @property notSyncTrashOrDelete - Flag for non sync event. It describes that user tried to trash event but it failed due to offline status of library
 When library goes online this flag is used to sync event
 */
@property (nonatomic) BOOL notSyncTrashOrDelete;
/**
 @property isSyncTriedNow - Flag for non sync event. If app tries to sync event a few times this is used to determine what flags should be added to event
 */
@property (nonatomic) BOOL isSyncTriedNow;
/**
 @property modifiedEventPropertiesAndValues - NSDictionary that describes what event properties should be modified on server during the synching
 */
@property (nonatomic, retain) NSDictionary *modifiedEventPropertiesAndValues;

/**
 @property synchedAt - Timestamp when event is synced with server
 */
@property NSTimeInterval synchedAt;

- (void)addAttachment:(PYAttachment *)attachment;
- (void)removeAttachment:(PYAttachment *)attachmentToRemove;
/**
 Get PYEvent object from json dictionary representation (JSON representation can include additioanl helper properties for event). It means that this method 'read' event from disk and from server
 */
+ (id)getEventFromDictionary:(NSDictionary *)JSON onConnection:(PYConnection*)connection;
/**
 Convert PYEvent object to json-like NSDictionary representation for synching with server
 */
- (NSDictionary *)dictionary;
/**
 Convert PYEvent object to json-like NSDictionary representation for caching on disk
 */
- (NSDictionary *)cachingDictionary;

/**
 Sugar to get the corresponding PYEventType of this event
 */
@property (nonatomic, readonly) PYEventType *pyType;

+ (NSString *)newClientId;

@end
