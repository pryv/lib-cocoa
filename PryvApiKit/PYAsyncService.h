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

@interface PYAsyncService : NSObject

+ (void)JSONRequestServiceWithRequest:(NSURLRequest *)request
                            success:(PYAsyncServiceSuccessBlockJSON)success
                            failure:(PYAsyncServiceFailureBlock)failure;

+ (void)RAWRequestServiceWithRequest:(NSURLRequest *)request
                              success:(PYAsyncServiceSuccessBlock)success
                              failure:(PYAsyncServiceFailureBlock)failure;


- (id)initWithRequest:(NSURLRequest *)request;

- (void)stop;

@end
