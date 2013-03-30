//
//  Channel.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

@class PYFolder;

#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYChannel : NSObject
{
    PYAccess *_access;
    NSString *_channelId;
    NSString *_name;
    NSTimeInterval _timeCount;
    NSDictionary *_clientData;
    BOOL _enforceNoEventsOverlap;
    BOOL _trashed;

}

@property (nonatomic, retain) PYAccess *access;
@property (nonatomic, copy, readonly) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic)       NSTimeInterval timeCount;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic, getter = isEnforceNoEventsOverlap) BOOL enforceNoEventsOverlap;
@property (nonatomic, getter = isTrashed) BOOL trashed;

/**
 @discussion
 Get list of all folders
 
 GET /{channel-id}/folders/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYFolder objects
 @param filterParams - > Query string parameters (parentId, includeHidden, state ...) They are optional. If you don't filter put nil Example : includeHidden=true&state=all
 
 */
- (void)getFoldersWithRequestType:(PYRequestType)reqType
                     filterParams:(NSString *)filter
                   successHandler:(void (^)(NSArray *folderList))successHandler
                     errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Create a new folder in the current channel Id
 folders have one unique Id AND one unique name. Both must be unique
 POST /{channel-id}/folders/
 
 */
- (void)createFolderWithId:(NSString *)folderId
                      name:(NSString *)folderName
                  parentId:(NSString *)parentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
       withRequestType:(PYRequestType)reqType
        successHandler:(void (^)(NSString *createdFolderId))successHandler
          errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Modify an existing folder Id
 
 PUT /{channel-id}/folders/{id}
 
 */
- (void)modifyFolderWithId:(NSString *)folderId
                      name:(NSString *)newfolderName
                  parentId:(NSString *)newparentId
                  isHidden:(BOOL)hidden
          customClientData:(NSDictionary *)clientData
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Trashes or deletes the specified folder, depending on its current state:
 If the folder is not already in the trash, it will be moved to the trash
 If the folder is already in the trash, it will be irreversibly deleted with its possible descendants
 If events exist that refer to the deleted item(s), you must indicate how to handle them with the parameter mergeEventsWithParent
 
 @param filterParams:
        mergeEventsWithParent (true or false): Required if actually deleting the item and if it (or any of its descendants) has linked events, ignored otherwise. If true, the linked events will be assigned to the parent of the deleted item; if false, the linked events will be deleted
 
 DELETE /{channel-id}/folders/{folder-id}
 */

- (void)trashOrDeleteFolderWithId:(NSString *)folderId
                     filterParams:(NSString *)filter
           withRequestType:(PYRequestType)reqType
            successHandler:(void (^)())successHandler
              errorHandler:(void (^)(NSError *error))errorHandler;


@end
