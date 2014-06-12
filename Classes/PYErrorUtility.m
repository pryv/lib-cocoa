//
//  PyErrorUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYErrorUtility.h"
#import "PYError.h"

@implementation PYErrorUtility

/*
 When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an error object detailing the cause.
 
 Here's an example "401 Unauthorized" error response:
 
 {
 "id": "invalid-access-token",
 "message": "Cannot find access with token 'bad-token'."
 }
 
 Error Fields:
 
 id (string): Identifier for the error; complements the response's HTTP error code.
 message (string): A human-readable description of the error.
 subErrors (array of errors): Optional. Lists the detailed causes of the main error, if any.
 
 */

+ (NSError *)getErrorFromJSONResponse:(NSDictionary*) JSONerror
                                error:(NSError *)error
                         withResponse:(NSHTTPURLResponse *)response
                           andRequest:(NSURLRequest *)request;
{
    if (!JSONerror) {
        if (error) {
            
            NSMutableDictionary *userInfoDic = nil;
            if (error.userInfo && error.userInfo.count > 0) {
                userInfoDic = [error.userInfo mutableCopy];
                [userInfoDic setObject:request forKey:PryvRequestKey];

            }else{
                userInfoDic = [[NSMutableDictionary alloc] init];
                [userInfoDic setObject:request forKey:PryvRequestKey];

            }
            
            NSError *errorToReturn = [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:userInfoDic];
            [userInfoDic autorelease];
            return [errorToReturn autorelease];
        }
        
        NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
        [userInfo setObject:[NSNumber numberWithInteger:response.statusCode] forKey:PryvErrorHTTPStatusCodeKey];
        [userInfo setObject:[NSString stringWithFormat:@"Http error: API returns with status code %d",(unsigned int)response.statusCode] forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:request forKey:PryvRequestKey];


        return [[[NSError alloc] initWithDomain:PryvSDKDomain code:response.statusCode userInfo:userInfo] autorelease];
        
    }
    
    NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];

    if ([[JSONerror objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
        [userInfo setObject:[JSONerror valueForKeyPath:@"error.id"] forKey:PryvErrorJSONResponseId];
        [userInfo setObject:[JSONerror valueForKeyPath:@"error.message"] forKey:NSLocalizedDescriptionKey];
    } else {
        NSString *responseId = [JSONerror valueForKeyPath:@"id"];
        if (! responseId) responseId = [JSONerror valueForKeyPath:@"reasonID"];
        if (! responseId) responseId = @"UNKOWN_ERROR";
        
        NSString *message = [JSONerror valueForKeyPath:@"message"];
        if (! message) message = @"UNKNOWN_MESSAGE";
        
        [userInfo setObject:responseId forKey:PryvErrorJSONResponseId];
        [userInfo setObject:message forKey:NSLocalizedDescriptionKey];
        
    }
    [userInfo setObject:[NSNumber numberWithInteger:response.statusCode] forKey:PryvErrorHTTPStatusCodeKey];
    [userInfo setObject:request forKey:PryvRequestKey];
    
    NSArray *arrayOfErrors = [JSONerror objectForKey:@"subErrors"];
    if (arrayOfErrors) {
        NSMutableDictionary *userInfoSuberrors = [[NSMutableDictionary alloc] init];
        NSMutableArray *arrayOfSubErrors = [[NSMutableArray alloc] initWithCapacity:arrayOfErrors.count];
        for (NSDictionary *error in arrayOfErrors) {
            if ([[JSONerror objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
                [userInfoSuberrors setObject:[JSONerror valueForKeyPath:@"error.id"] forKey:PryvErrorJSONResponseId];
                [userInfoSuberrors setObject:[JSONerror valueForKeyPath:@"error.message"] forKey:NSLocalizedDescriptionKey];
            } else {
                [userInfoSuberrors setObject:[JSONerror valueForKeyPath:@"id"] forKey:PryvErrorJSONResponseId];
                [userInfoSuberrors setObject:[JSONerror valueForKeyPath:@"message"] forKey:NSLocalizedDescriptionKey];
            }
            [arrayOfSubErrors addObject:userInfoSuberrors];
        }
        
        [userInfo setObject:arrayOfSubErrors forKey:PryvErrorSubErrorsKey];
        [userInfoSuberrors release];
        [arrayOfSubErrors release];
    }
    
    return [[[NSError alloc] initWithDomain:PryvSDKDomain code:error.code userInfo:userInfo] autorelease];
}

+ (NSError *)getErrorFromStringResponse:(NSData*)responseData error:(NSError *)error
                           withResponse:(NSHTTPURLResponse *)response
                             andRequest:(NSURLRequest *)request;
{
  
    NSString *content = @"";
    if (responseData != nil) {
        content = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    }
    
    
    NSMutableDictionary *userInfo = [[[NSMutableDictionary alloc] init] autorelease];
    
    if (content != nil) [userInfo setObject:content forKey:@"content"];
    [userInfo setObject:[NSNumber numberWithInteger:response.statusCode] forKey:PryvErrorHTTPStatusCodeKey];
    if (error != nil) [userInfo setObject:error forKey:@"error"];
    
    NSLog(@"** PYClient.getErrorFromStringResponse ** : %@\n>> %@\n>>%@", error, [[request URL] absoluteString], content);
    
    return [[[NSError alloc] initWithDomain:PryvSDKDomain code:error.code userInfo:userInfo] autorelease];
}

+ (NSString*) contentForRequest:(NSURLRequest *)request {
    return [NSString stringWithFormat:@"%@ url: %@ \n%@", request, request.URL.absoluteString,
                                      [[[NSString alloc] initWithData:request.HTTPBody
                                                             encoding:NSUTF8StringEncoding] autorelease]];
    
    //NSLog(@"Method: %@", self.HTTPMethod);
    
}


@end
