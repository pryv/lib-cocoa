//
//  PyErrorUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYErrorUtility : NSObject

+ (BOOL)isAPIUnreachableError:(NSError*)error;

+ (NSError *)getAPIUnreachableWithUserInfos:(NSDictionary*)userInfos;

/**
 Get NSError object for server response
 */
+ (NSError *)getErrorFromJSONResponse:(NSDictionary* ) JSONerror
                                error:(NSError *)error
                         withResponse:(NSHTTPURLResponse *)response
                           andRequest:(NSURLRequest *)request;

+ (NSError *)getErrorFromStringResponse:(NSData*)responseData error:(NSError *)error
                           withResponse:(NSHTTPURLResponse *)response
                             andRequest:(NSURLRequest *)request;
@end
