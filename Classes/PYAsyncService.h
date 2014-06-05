//
//  PYAsyncService.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/15/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PYAsyncServiceSuccessBlock)(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *responseData);
typedef void(^PYAsyncServiceSuccessBlockJSON)(NSURLRequest *req, NSHTTPURLResponse *resp, id JSON);
typedef void(^PYAsyncServiceFailureBlock)(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, NSMutableData *responseData);

typedef enum {
	PYRequestResultTypeJSON = 1,
	PYRequestResultTypeRAW
} PYRequestResultType;



/*!
 @class PYAsyncService
 
 @abstract PYAsyncService is used for handling asynchroneous HTTP requests
 
 */
@interface PYAsyncService : NSObject {

@private
    NSURLConnection *_connection;
    NSURLRequest *_request;
    NSHTTPURLResponse *_response;
    NSMutableData *_responseData;
    PYRequestResultType _requestResultType;
    
    BOOL _running;
    PYAsyncServiceSuccessBlock _onSuccess;
    PYAsyncServiceFailureBlock _onFailure;
}

/*!
 @method JSONRequestServiceWithRequest:
 @abstract The result expected is JSON formated
 */
+ (void)JSONRequestServiceWithRequest:(NSURLRequest *)request
                            success:(PYAsyncServiceSuccessBlockJSON)success
                            failure:(PYAsyncServiceFailureBlock)failure;

/*!
 @method RAWRequestServiceWithRequest:
 @abstract The result is returned as NSMutableData
 */
+ (void)RAWRequestServiceWithRequest:(NSURLRequest *)request
                              success:(PYAsyncServiceSuccessBlock)success
                              failure:(PYAsyncServiceFailureBlock)failure;


- (id)initWithRequest:(NSURLRequest *)request;

- (void)stop;

@end
