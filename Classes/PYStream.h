//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>

@class PYConnection;


@interface PYStream : NSObject
{
    NSString  *_clientId;
    PYConnection *_connection;
    NSString *_streamId;
    NSString *_name;
    NSString *_parentId;
    NSDictionary *_clientData;
    NSTimeInterval _timeCount;
    NSArray *_children;
    BOOL _singleActivity;
    BOOL _trashed;
    
    BOOL _isSyncTriedNow;
    BOOL _hasTmpId;
    BOOL _notSyncAdd;
    BOOL _notSyncModify;
    NSTimeInterval _synchedAt;
    NSDictionary *_modifiedStreamPropertiesAndValues;
}
/** client side id only.. remain the same before and after synching **/
@property (nonatomic, retain) NSString  *clientId;
@property (nonatomic, retain) PYConnection *connection;
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic) NSTimeInterval timeCount;

//@children -> array of PYStream objects
@property (nonatomic, retain) NSArray *children;

@property (nonatomic, assign, getter = isSingleActivity) BOOL singleActivity;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

/**
 @property isSyncTriedNow - Flag for non sync stream. If app tries to sync stream a few times this is used to determine what flags should be added to stream
 */
@property (nonatomic) BOOL isSyncTriedNow;
/**
 @property hasTmpId - Check if stream from cache has tmpId. If stream has it it means that isn't sync from server (created offline)
 */
@property (nonatomic) BOOL hasTmpId;
/**
 @property notSyncAdd - Flag for non sync stream. It describes that user tried to create stream but it failed due to offline status of library
 When library goes online this flag is used to sync stream
 */
@property (nonatomic) BOOL notSyncAdd;
/**
 @property notSyncModify - Flag for non sync stream. It describes that user tried to modify stream but it failed due to offline status of library
 When library goes online this flag is used to sync stream
 */
@property (nonatomic) BOOL notSyncModify;
@property (nonatomic) NSTimeInterval synchedAt;
/**
 @property modifiedStreamPropertiesAndValues - NSDictionary that describes what stream properties should be modified on server during the synching
 */
@property (nonatomic, retain) NSDictionary *modifiedStreamPropertiesAndValues;

/**
 Convert PYStream object to json-like NSDictionary representation for synching with server
 */
- (NSDictionary *)dictionary;
/**
 Convert PYStream object to json-like NSDictionary representation for caching on disk
 */
- (NSDictionary *)cachingDictionary;

@end