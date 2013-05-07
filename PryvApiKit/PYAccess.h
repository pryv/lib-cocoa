//
//  PYAccess.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/27/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"


@interface PYAccess : NSObject
{
    NSString *_userID;
    NSString *_accessToken;
    NSString *_apiScheme;
    NSString *_apiDomain;
}

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *apiScheme;
@property (nonatomic, copy) NSString *apiDomain;

/**
 @discussion
 Gets the accessible activity channels
 
 GET /channels/
 
 @param successHandler A block object to be executed when the operation finishes successfully. This block has no return value and takes one argument NSArray of PYChannel objects
 @param filterParams  Query string parameters (state ...) Optional. If you don't filter put nil Example : state=all
 @param successHandler A block object to be executed when the operation finishes successfully.
 @param errorHandler   NSError object if some error occurs
 */

- (void)getChannelsWithRequestType:(PYRequestType)reqType
                      filterParams:(NSDictionary *)filter
                    successHandler:(void (^)(NSArray *channelList))successHandler
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



@end
