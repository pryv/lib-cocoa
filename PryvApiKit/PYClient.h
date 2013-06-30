//
//  PYClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

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

typedef void(^PYClientSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void(^PYClientFailureBlock)(NSError *error);

@class PYAccess;

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface PYClient : NSObject 

+ (NSString *)defaultDomain;
+ (void)setDefaultDomain:(NSString*) domain;
+ (void)setDefaultDomainStaging;

+ (PYAccess *)createAccessWithUsername:(NSString *)username andAccessToken:(NSString *)token;

+ (NSString *)fileMIMEType:(NSString*)file;

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode;

+ (NSString *)getURLPath:(NSString *)path withParams:(NSDictionary *)params;

+ (void)sendRequest:(NSURLRequest *)request
        withReqType:(PYRequestType)reqType
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;

+ (void) apiRequest:(NSString *)fullURL
            headers:(NSDictionary*)headers
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;

@end
