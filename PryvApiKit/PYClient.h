//
//  PYClient.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


// Superclass for Pryv API classes (PYChannelClient, PYEventClient, PYFolderClient etc.)

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



#import <Foundation/Foundation.h>

@interface PYClient : NSObject

+ (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successHandler
            failure:(void (^)(NSError *error))failureHandler;


@end
