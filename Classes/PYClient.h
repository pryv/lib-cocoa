//
//  PYClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	PYRequestMethodGET = 1,
	PYRequestMethodPUT,
	PYRequestMethodPOST,
	PYRequestMethodDELETE
} PYRequestMethod;

typedef void(^PYClientSuccessBlockDict)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *JSON);
typedef void(^PYClientSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSMutableData *responseData);
typedef void(^PYClientFailureBlock)(NSError *error);

@class PYConnection;


@interface PYClient : NSObject

/**
 * get user's prefered code
 */
+ (NSString *)languageCodePrefered;
/**
 * set user's preferred code (used for pyWebLogin)
 */
+ (void)setLanguageCodePrefered:(NSString*) languageCode;
/**
 * domain used for request to api
 */
+ (NSString *)defaultDomain;
/**
 * set default domain for connection creation
 */
+ (void)setDefaultDomain:(NSString*) domain;
/**
 * use Pryv's staging domain for connection
 */
+ (void)setDefaultDomainStaging;
/**
 * create a connection with a specific username and accessToken
 */
+ (PYConnection *)createConnectionWithUsername:(NSString *)username andAccessToken:(NSString *)token;

/**
 * low level JSON request to the API.. handles Pryv's error code
 */
+ (void)apiJSONDictRequest:(NSURLRequest *)request
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler;

/**
 * low level RAW request to the API.. handles Pryv's error code
 */
+ (void)apiRawRequest:(NSURLRequest *)request
                success:(PYClientSuccessBlock)successHandler
                failure:(PYClientFailureBlock)failureHandler;

/**
 * High level request to the API .. wrapper for apiJSONDictRequest
 */
+ (NSMutableURLRequest*) apiRequest:(NSString *)fullURL
            headers:(NSDictionary*)headers
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler;


@end
