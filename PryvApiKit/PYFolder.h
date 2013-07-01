//
//  Created by Konstantin Dorodov on 1/9/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface PYFolder : NSObject
{
    NSString *_folderId;
    NSString *_channelId;
    NSString *_name;
    NSString *_parentId;
    NSDictionary *_clientData;
    NSTimeInterval _timeCount;
    NSArray *_children;
    BOOL _hidden;
    BOOL _trashed;
    
    BOOL _isSyncTriedNow;
    BOOL _hasTmpId;
    BOOL _notSyncAdd;
    BOOL _notSyncModify;
    NSTimeInterval _synchedAt;
    NSDictionary *_modifiedFolderPropertiesAndValues;
}

@property (nonatomic, copy) NSString *folderId;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *parentId;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic) NSTimeInterval timeCount;

//@children -> array of PYFolder objects
@property (nonatomic, retain) NSArray *children;

@property (nonatomic, assign, getter = isHidden) BOOL hidden;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

/**
 @property isSyncTriedNow - Flag for non sync folder. If app tries to sync folder a few times this is used to determine what flags should be added to folder
 */
@property (nonatomic) BOOL isSyncTriedNow;
/**
 @property hasTmpId - Check if folder from cache has tmpId. If folder has it it means that isn't sync from server (created offline)
 */
@property (nonatomic) BOOL hasTmpId;
/**
 @property notSyncAdd - Flag for non sync folder. It describes that user tried to create folder but it failed due to offline status of library
 When library goes online this flag is used to sync folder
 */
@property (nonatomic) BOOL notSyncAdd;
/**
 @property notSyncModify - Flag for non sync folder. It describes that user tried to modify folder but it failed due to offline status of library
 When library goes online this flag is used to sync folder
 */
@property (nonatomic) BOOL notSyncModify;
@property (nonatomic) NSTimeInterval synchedAt;
/**
 @property modifiedFolderPropertiesAndValues - NSDictionary that describes what folder properties should be modified on server during the synching
 */
@property (nonatomic, retain) NSDictionary *modifiedFolderPropertiesAndValues;

/**
 Convert PYFolder object to json-like NSDictionary representation for synching with server
 */
- (NSDictionary *)dictionary;
/**
 Convert PYFolder object to json-like NSDictionary representation for caching on disk
 */
- (NSDictionary *)cachingDictionary;

@end