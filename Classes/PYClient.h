//
//  PYClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    PYRequestTypeAsync = 1,
    PYRequestTypeSync
} PYRequestType;

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

+ (NSString *)languageCodePrefered;
+ (void)setLanguageCodePrefered:(NSString*) languageCode;

+ (NSString *)defaultDomain;
+ (void)setDefaultDomain:(NSString*) domain;
+ (void)setDefaultDomainStaging;

+ (PYConnection *)createConnectionWithUsername:(NSString *)username andAccessToken:(NSString *)token;

+ (NSString *)fileMIMEType:(NSString*)file;

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode;

+ (NSString *)getURLPath:(NSString *)path withParams:(NSDictionary *)params;

+ (void)sendJSONDictRequest:(NSURLRequest *)request
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler;

+ (void)sendRAWRequest:(NSURLRequest *)request
                success:(PYClientSuccessBlock)successHandler
                failure:(PYClientFailureBlock)failureHandler;

+ (NSMutableURLRequest*) apiRequest:(NSString *)fullURL
            headers:(NSDictionary*)headers
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler;


@end
