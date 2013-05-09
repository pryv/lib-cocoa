//
//  PyErrorUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvErrorUtility.h"
#import "PryvError.h"

@implementation PryvErrorUtility

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

+ (NSError *)getErrorFromJSONResponse:(id)JSONerror error:(NSError *)error withResponse: (NSHTTPURLResponse *)response;
{
    if (!JSONerror) {
        if (error) {
            return error;
        }
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];        
        [userInfo setObject:[NSNumber numberWithInteger:response.statusCode] forKey:PryvErrorHTTPStatusCodeKey];
        [userInfo setObject:[NSString stringWithFormat:@"Http error: API returns with status code %d",response.statusCode] forKey:NSLocalizedDescriptionKey];
//        [userInfo setObject:[NSString stringWithFormat:@"Http error: API returns with status code %ld",(long)response.statusCode] forKey:NSLocalizedDescriptionKey];


        return [[[NSError alloc] initWithDomain:PryvSDKDomain code:response.statusCode userInfo:[userInfo autorelease]] autorelease];
        
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    
    [userInfo setObject:[JSONerror objectForKey:@"id"] forKey:PryvErrorJSONResponseId];
    [userInfo setObject:[NSNumber numberWithInteger:response.statusCode] forKey:PryvErrorHTTPStatusCodeKey];
    [userInfo setObject:[JSONerror objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
    
    NSArray *arrayOfErrros = [JSONerror objectForKey:@"subErrors"];
    if (arrayOfErrros) {
        NSMutableDictionary *userInfoSuberrors = [[NSMutableDictionary alloc] init];
        NSMutableArray *arrayOfSubErrors = [[NSMutableArray alloc] initWithCapacity:arrayOfErrros.count];
        for (NSDictionary *error in arrayOfErrros) {
            [userInfoSuberrors setObject:[JSONerror objectForKey:@"id"] forKey:PryvErrorJSONResponseId];
            [userInfoSuberrors setObject:[JSONerror objectForKey:@"message"] forKey:NSLocalizedDescriptionKey];
            [arrayOfSubErrors addObject:userInfoSuberrors];
        }
        
        [userInfo setObject:arrayOfSubErrors forKey:PryvErrorSubErrorsKey];
    }
    
    
    return [[[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:[userInfo autorelease]] autorelease];
}

@end
