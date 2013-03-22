//
//  PPrYvApiClient.h
//  AT PrYv
//
//  Created by Nicolas Manzini on 21.12.12.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


/*
Implementing the authorization process and obtaining an access token all by yourself.

For testing: Use our staging servers: https://access.rec.la/access

Steps:

start an access request by calling POST https://access.pryv.io/access
open response.url in a webview
poll response.pollurl ﻿until you get the an ACCEPTED / REFUSED or ERROR status
*/


/**
 @discussion
 This class provides an easy way to upload events to the RESTful PrYv API using the well known AFNetworking library.
 You can find AFNetworking on github at this address https://github.com/AFNetworking/AFNetworking
 

 Each Application uses one Channel and can have multiple folders within this channel
 You have only one channelId per application.

 Visit http://dev.pryv.com/ for the complete documentation on the PrYv API
 
 */

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class PYEvent;
@class PYChannelClient;
@class PYEventClient;
@class PYFolderClient;

@interface PYApiConnectionClient : NSObject

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *oAuthToken;
@property (copy, nonatomic) NSString *channelId;
@property (readonly, nonatomic) NSTimeInterval serverTimeInterval;

// perform check before trying to connect to the PrYv API
- (BOOL)isReady;

// if isReady returns Falsereturn a reason based
- (NSError *)createNotReadyError;

// construct the baseUrl with schema
- (NSString *)apiBaseUrl;

// for creating infoObjects for errors
// @return empty NSString if @param object is nil
- (id)nonNil:(id)object;


/**
 @discussion
 Allows you to access the Pryv Api Client singleton
 You must first set the userId, oAuthToken and channelId before
 Communicating with the API
 
 # method
 +[PPrYvApiClient startClientWithUserId:oAuthToken:channelId:successHandler:errorHandler]
 */
+ (PYApiConnectionClient *)sharedClient;

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






@end