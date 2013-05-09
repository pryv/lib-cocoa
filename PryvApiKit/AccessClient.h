//
//  AccessClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/25/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

/*
 
 Administration is only allowed for trusted apps; to register your app as trusted, please get in touch with us. If you're only interested in obtaining access tokens for your app, see the app access documentation instead.
 
 Access to admin methods is managed by sessions. To create a session, you must successfully authenticate with a /admin/login request, which will return the session ID. Each request sent during the duration of the session must then contain the session ID in its Authorization header or, alternatively, in the query string's auth parameter. The session is terminated when /admin/logout is called or when the session times out (TODO: indicate session timeout delay).
 

 NSDictionary *params = @{
 @"requestingAppId": @"pryv-mobile-position-ios",
 @"returnURL": @"false",
 @"languageCode" : preferredLanguageCode,
 
 @"requestedPermissions": @[
 @{
 @"channelId" : kPrYvApplicationChannelId,
 @"level" : @"manage",
 @"defaultName" : kPrYvApplicationChannelName,
 }
 ]};

 
 */


#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface AccessClient : PYClient

+ (instancetype)accessClient;

/*
 POST /admin/login
 */
//- (void)getSessionWithRequestType:(PYRequestType)reqType
//                         username:(NSString *)username
//                         password:(NSString *)password
//                    applicationId:(NSString *)appLicationId
//                   successHandler:(void (^)(NSArray *folderList))successHandler
//                     errorHandler:(void (^)(NSError *error))errorHandler;
//
//
//- (void)accessesStufWithRequestType:(PYRequestType)reqType
//                     successHandler:(void (^)(NSArray *folderList))successHandler
//                       errorHandler:(void (^)(NSError *error))errorHandler;
//
//- (void)accessesStufPostWithRequestType:(PYRequestType)reqType
//                         successHandler:(void (^)(NSArray *folderList))successHandler
//                           errorHandler:(void (^)(NSError *error))errorHandler;


@end
