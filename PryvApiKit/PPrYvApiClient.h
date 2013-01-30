//
//  PPrYvApiClient.h
//  AT PrYv
//
//  Created by Nicolas Manzini on 21.12.12.
//  Copyright (c) 2012 PrYv. All rights reserved.
//

/**
 @discussion
 This class provides an easy way to upload events to the RESTful PrYv API using the well known AFNetworking library.
 You can find AFNetworking on github at this address https://github.com/AFNetworking/AFNetworking
 
 On PrYv, Events are sent as JSON Data parameters. Single event can have files attached to them.
 Events can be of differents types.
 See http://dev.pryv.com/event-types.html
     http://dev.pryv.com/standard-structure.html

 Each Application uses one Channel and can have multiple folders within this channel
 You have only one channelId per application.

 Visit http://dev.pryv.com/ for the complete documentation on the PrYv API
 
 */

#import <Foundation/Foundation.h>

@class Event;

@interface PPrYvApiClient : NSObject {
}

@property (copy, nonatomic) NSString * userId;
@property (copy, nonatomic) NSString * oAuthToken;
@property (copy, nonatomic) NSString * channelId;
@property (readonly, nonatomic) NSTimeInterval serverTimeInterval;


/**
 @discussion
 Allows you to access the Pryv Api Client singleton
 You must first set the userId, oAuthToken and channelId before
 Communicating with the API
 
 # method
 +[PPrYvApiClient startClientWithUserId:oAuthToken:channelId:successHandler:errorHandler]
 */
+ (PPrYvApiClient *)sharedClient;

 // ---------------------------------------------------------------------------------------------------------------------
 // @name Initiation of protocol
 // ---------------------------------------------------------------------------------------------------------------------

/**
 @discussion
 You need to call this method at least once prior to any action with the api. but you can call it as many time as you want.
 You can modify the client properties during the application lifetime by setting its properties directly.
 
 */
- (void)startClientWithUserId:(NSString *)userId
                   oAuthToken:(NSString *)token
                    channelId:(NSString *)channelId
               successHandler:(void (^)(NSTimeInterval serverTime))successHandler
                 errorHandler:(void(^)(NSError *error))errorHandler;


/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager

    GET /

 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTime))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler;

// ---------------------------------------------------------------------------------------------------------------------
// @name Channel operations
// ---------------------------------------------------------------------------------------------------------------------


- (void)getChannelsWithSuccessHandler:(void (^)(NSArray *channelList))successHandler
                        errorHandler:(void (^)(NSError *error))errorHandler;


// ---------------------------------------------------------------------------------------------------------------------
// @name Event operations
// ---------------------------------------------------------------------------------------------------------------------


/**
 @discussion
 Send an position event with one or more attachments

    POST /{channel-id}/events/

 @param event to send attachments to Api set the attachmentList propery of Event: NSArray of EventAttachment

 @see Event
 @see EventAttachment
*/
- (void)sendEvent:(Event *)event
withSuccessHandler:(void(^)(void))successHandler
      errorHandler:(void(^)(NSError *error))errorHandler;


/**
 @discussion
 get events between two dates, pass nil to both @param startDate and @param endDate to get the last 24h 
 pass nil to @param folderId to get events from all folders in the current channel Id

    GET /{channel-id}/events/

 */
- (void)getEventsFromStartDate:(NSDate *)startDate
                     toEndDate:(NSDate *)endDate
                    inFolderId:(NSString *)folderId
                successHandler:(void (^)(NSArray *eventList))successHandler
                  errorHandler:(void(^)(NSError *error))errorHandler;


// ---------------------------------------------------------------------------------------------------------------------
// @name Folder operations
// ---------------------------------------------------------------------------------------------------------------------


/**
 @discussion
 Get list of all folders

    GET /{channel-id}/folders/

 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of Folder objects

 */
- (void)getFoldersWithSuccessHandler:(void (^)(NSArray *folderList))successHandler
                        errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Create a new folder in the current channel Id
 folders have one unique Id AND one unique name. Both must be unique

    POST /{channel-id}/folders/

 */
- (void)createFolderId:(NSString *)folderId
              withName:(NSString *)folderName
        successHandler:(void (^)(NSString *createdFolderId, NSString *createdFolderName))successHandler
          errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Rename an existing folder Id in the current channel Id with a new name

    PUT /{channel-id}/folders/{id}

 */
- (void)renameFolderId:(NSString *)folderId
     withNewFolderName:(NSString *)folderName
        successHandler:(void(^)(NSString *createdFolderId, NSString *newFolderName))successHandler
          errorHandler:(void(^)(NSError *error))errorHandler;

@end