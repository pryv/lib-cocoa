//
//  Channel.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYChannel : NSObject

@property (nonatomic, retain) PYAccess *access;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic, assign, getter = isEnforceNoEventsOverlap) BOOL enforceNoEventsOverlap;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

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
- (void)createFolderId:(NSString *)folderId
       withRequestType:(PYRequestType)reqType
              withName:(NSString *)folderName
        successHandler:(void (^)(NSString *createdFolderId, NSString *createdFolderName))successHandler
          errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Rename an existing folder Id in the current channel Id with a new name
 
 PUT /{channel-id}/folders/{id}
 
 */
- (void)renameFolderId:(NSString *)folderId
       withRequestType:(PYRequestType)reqType
     withNewFolderName:(NSString *)folderName
        successHandler:(void(^)(NSString *createdFolderId, NSString *newFolderName))successHandler
          errorHandler:(void(^)(NSError *error))errorHandler;


@end
