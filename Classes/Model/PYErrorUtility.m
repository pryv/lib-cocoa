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


+ (BOOL)isAPIUnreachableError:(NSError*)error {
    if (! error) return NO;
    return [error.domain isEqualToString:PryvErrorAPIUnreachable];
}


+ (NSError *)getAPIUnreachableWithUserInfos:(NSDictionary*)userInfos {
    return [[[NSError alloc] initWithDomain:PryvErrorAPIUnreachable code:0 userInfo:userInfos] autorelease];
}

+ (NSError *)getErrorFromJSONResponse:(NSDictionary*) JSONerror
                                error:(NSError *)error
                         withResponse:(NSHTTPURLResponse *)response
                           andRequest:(NSURLRequest *)request;
{
    
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
        [userInfo setObject:arrayOfErrors forKey:PryvErrorSubErrorsKey];
        [arrayOfErrors release];
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



@end
