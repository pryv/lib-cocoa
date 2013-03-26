//
//  PyErrorUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PyErrorUtility.h"
#import "PYError.h"

@implementation PyErrorUtility

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
        return error;
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
    
    
    return [[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:userInfo];
}

@end