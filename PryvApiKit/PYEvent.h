//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

@class PYEventType;
@class PYAttachment;

#import <Foundation/Foundation.h>

@interface PYEvent : NSObject
{
    NSString  *_eventId;
    NSString  *_channelId;
    
    NSTimeInterval _time;
    NSTimeInterval _duration;
    
    NSString *_eventClass;
    NSString *_eventFormat;
    id _value;
    
    NSString *_folderId;
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

}

@property (nonatomic, retain) NSString  *eventId;
@property (nonatomic, retain) NSString  *channelId;

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, retain) NSString *eventClass;
@property (nonatomic, retain) NSString *eventFormat;

@property (nonatomic, retain) id value;

@property (nonatomic, retain) NSString *folderId;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSString  *eventDescription;

//array of PYEventAttachment objects
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, retain) NSDictionary *clientData;
@property (nonatomic) BOOL trashed;
@property (nonatomic, retain) NSDate *modified;

@property (nonatomic) BOOL hasTmpId;
@property (nonatomic) BOOL notSyncAdd;
@property (nonatomic) BOOL notSyncModify;
@property (nonatomic) BOOL notSyncTrashOrDelete;
@property (nonatomic) BOOL isSyncTriedNow;
@property (nonatomic, retain) NSDictionary *modifiedEventPropertiesAndValues;

//event that were in unsyncList
@property NSTimeInterval synchedAt;

- (void)addAttachment:(PYAttachment *)attachment;
- (void)removeAttachment:(PYAttachment *)attachmentToRemove;

+ (id)getEventFromDictionary:(NSDictionary *)JSON;
- (NSDictionary *)dictionary;
- (NSDictionary *)cachingDictionary;

@end
