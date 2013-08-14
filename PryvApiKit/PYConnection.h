//
//  PYConnection.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"
#import "Reachability.h"
@class PYEvent;
@class PYStream;

@interface PYConnection : NSObject
{
    NSString *_userID;
    NSString *_accessToken;
    NSString *_apiScheme;
    NSString *_apiDomain;
    NSTimeInterval _serverTimeInterval;
    NSTimeInterval _lastTimeServerContact;
    
    Reachability *_connectionReachability;
    BOOL _online;
    NSMutableSet *_eventsNotSync;
    NSMutableSet *_foldersNotSync;
    NSUInteger _attachmentsCountNotSync;
    NSInteger _attachmentSizeNotSync;
}

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *apiScheme;
@property (nonatomic, copy) NSString *apiDomain;
@property (nonatomic, readonly) NSTimeInterval serverTimeInterval;
@property (nonatomic, readonly) NSTimeInterval lastTimeServerContact;
@property (nonatomic, retain) Reachability *connectionReachability;

//online/offline
@property (nonatomic, readonly, getter = isOnline) BOOL online;
@property (nonatomic, retain) NSMutableSet *eventsNotSync;
@property (nonatomic, retain) NSMutableSet *foldersNotSync;
@property (nonatomic, readonly) NSUInteger attachmentsCountNotSync;
@property (nonatomic, readonly) NSInteger attachmentSizeNotSync;



- (id) initWithUsername:(NSString *)username andAccessToken:(NSString *)token;

- (NSString *)apiBaseUrl;
/**
 Add event to unsync list. If app tryed to create, modify or trash event and it fails due to no internet access it will be added to unsync list
 */
- (void)addEvent:(PYEvent *)event toUnsyncList:(NSError *)error;
/**
 Add folder to unsync list. If app tryed to create, modify or trash folder and it fails due to no internet access it will be added to unsync list
 */
- (void)addFolder:(PYStream *)folder toUnsyncList:(NSError *)error;

/**
 Low level method for web service communication
 */
- (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;

/**
 @discussion
 Gets the accessible activity channels
 
 GET /channels/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYChannel objects
 @param filterParams  Query string parameters (state ...) Optional. If you don't filter put nil Example : state=all
 @param successHandler A block object to be executed when the operation finishes successfully.
 @param errorHandler   NSError object if some error occurs
 */

- (void)getAllChannelsWithRequestType:(PYRequestType)reqType
                    gotCachedChannels:(void (^) (NSArray *cachedChannelList))cachedChannels
                    gotOnlineChannels:(void (^) (NSArray *onlineChannelList))onlineChannels
                         errorHandler:(void (^)(NSError *error))errorHandler;


- (void)getChannelsWithRequestType:(PYRequestType)reqType
                            filter:(NSDictionary*)filterDic
                    successHandler:(void (^) (NSArray *channelsList))onlineChannelList
                      errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Gets the accessible streams
 
 GET /streams/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYChannel objects
 @param filterParams  Query string parameters (state ...) Optional. If you don't filter put nil Example : state=all
 @param successHandler A block object to be executed when the operation finishes successfully.
 @param errorHandler   NSError object if some error occurs
 */

- (void)getAllStreamsWithRequestType:(PYRequestType)reqType
                    gotCachedStreams:(void (^) (NSArray *cachedStreamList))cachedStreams
                    gotOnlineStreams:(void (^) (NSArray *onlineStreamList))onlineStreams
                         errorHandler:(void (^)(NSError *error))errorHandler;


- (void)getStreamsWithRequestType:(PYRequestType)reqType
                            filter:(NSDictionary*)filterDic
                    successHandler:(void (^) (NSArray *streamsList))onlineStreamList
                      errorHandler:(void (^)(NSError *error))errorHandler;


/**
 @discussion
 Creates new activity channel
 
 POST /channels/
 
 @param channel : A PYChannel object to be created. Id is optional, if you don't set it server will generate one for you.
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument of PYChannel object. The channelId property of this object will have it's value set at this point if you choose not to set it yourself and server generated one for you.
 @param errorHandler   NSError object if some error occurs

 */

// commented out for now, there is no support for trusted apps yet

//- (void)createChannelWithRequestType:(PYRequestType)reqType
//                             channel:(PYChannel *)newChannel
//                      successHandler:(void (^)(PYChannel *channel))successHandler
//                        errorhandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Modifies the activity channel's attributes.
 
 PUT /channels/{channel-id}
 
 @param channelId : id of the channel to be modified. Required.
 @param data : NSDictionary with new values for the channel's fields. All fields are optional, and only modified values must be included.
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and no arguments.
 @param errorHandler   NSError object if some error occurs
 */

- (void)editChannelWithRequestType:(PYRequestType)reqType
                         channelId:(NSString *)channelId
                              data:(NSDictionary *)data
                    successHandler:(void (^)())successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler;

/**
 @discussion
 Trashes or deletes the given channel, depending on its current state
 
 DELETE /channels/{channel-id}
 
 @param channelId : id of the channel to be deleted. Required.
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and no arguments.
 @param errorHandler   NSError object if some error occurs
 */

- (void)deleteChannelWithRequestType:(PYRequestType)reqType
                         channelId:(NSString *)channelId
                    successHandler:(void (^)())successHandler
                      errorHandler:(void (^)(NSError *error))errorHandler;



/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTime))successHandler
                     errorHandler:(void(^)(NSError *error))errorHandler;

@end
