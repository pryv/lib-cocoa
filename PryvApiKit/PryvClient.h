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

@class PryvAccess;

//#if TARGET_OS_MAC
//#import <CoreServices/CoreServices.h>


#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface PryvClient : NSObject 

//@property (nonatomic, copy) NSString *username;
//@property (nonatomic, copy) NSString *accessToken;
//@property (readonly, nonatomic) NSTimeInterval serverTimeInterval;


+ (NSString *)defaultDomain;
+ (void)setDefaultDomain:(NSString*) domain;
+ (void)setDefaultDomainStaging;

+ (PryvAccess *)createAccessWithUsername:(NSString *)username andAccessToken:(NSString *)token;

+ (NSString *)fileMIMEType:(NSString*)file;

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode;

+ (NSString *)urlPath:(NSString *)path withParams:(NSDictionary *)params;


+ (void) apiRequest:(NSString *)fullURL
            headers:(NSDictionary*)headers
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;




@end
