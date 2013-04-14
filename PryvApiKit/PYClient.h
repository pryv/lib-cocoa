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
#import <MobileCoreServices/MobileCoreServices.h>
#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface PYClient : NSObject

//@property (nonatomic, copy) NSString *username;
//@property (nonatomic, copy) NSString *accessToken;
//@property (readonly, nonatomic) NSTimeInterval serverTimeInterval;

+ (PYAccess *)createAccessWithUsername:(NSString *)username andAccessToken:(NSString *)token;

+ (NSString *)fileMIMEType:(NSString*)file;

+ (void) apiRequest:(NSString *)path
             access:(PYAccess *)access
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;

/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
+ (void)synchronizeTimeWithAccess:(PYAccess *)access successHandler:(void(^)(NSTimeInterval serverTime))successHandler errorHandler:(void(^)(NSError *error))errorHandler;


@end
