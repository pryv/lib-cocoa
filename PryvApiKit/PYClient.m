//
//  PYClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYApiConnectionClient.h"
#import "PYError.h"
#import "PyErrorUtility.h"


@implementation PYClient


#pragma mark - Utilities

//When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an error object detailing the cause

+ (NSIndexSet *)unacceptableStatusCodes {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(400, 200)];
}

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode {
    
    return [[self unacceptableStatusCodes] containsIndex:statusCode] ? YES : NO;
}

+ (NSString *)getMethodName:(PYRequestMethod)method
{
    switch (method) {
        case PYRequestMethodGET:
            return @"GET";
            break;
        case PYRequestMethodPOST:
            return @"POST";
            break;
        case PYRequestMethodPUT:
            return @"PUT";
            break;
        case PYRequestMethodDELETE:
            return @"DELETE";
            break;
            
        default:
            break;
    }

}

+ (void) apiRequest:(NSString *)path
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
            success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))successHandler
            failure:(void (^)(NSError *error))failureHandler;
{
    if (![[PYApiConnectionClient sharedPYApiConnectionClient] isReady])
    {
        NSError *notReadyError = [[PYApiConnectionClient sharedPYApiConnectionClient] createNotReadyError];
        [NSException raise:notReadyError.domain format:@"Error code %d",notReadyError.code];
        return;
    }
    
    
    if ( (method == PYRequestMethodGET  && postData != nil) || (method == PYRequestMethodDELETE && postData != nil) )
    {
        [NSException raise:NSInvalidArgumentException format:@"postData must be nil for GET method or DELETE method"];
        return;
        
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[PYApiConnectionClient sharedPYApiConnectionClient] apiBaseUrl], path]];
    NSLog(@"url path is %@",[url absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setValue:[PYApiConnectionClient sharedPYApiConnectionClient].oAuthToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSString *httpMethod = [self getMethodName:method];
    request.HTTPMethod = httpMethod;
    
    if (postData) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONReadingMutableContainers error:nil];
    }
    
    switch (reqType) {
        case PYRequestTypeAsync:{
            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
             {
                 if (successHandler) {
                     successHandler(request, response, JSON);
                 }
                 
             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                 
                 if (failureHandler) {
                     NSError *errorToReturn = [PyErrorUtility getErrorFromJSONResponse:JSON error:error withResponse:response];
                     failureHandler(errorToReturn);
                 }
                 
             }];
            
            [operation start];

        }
            break;
        case PYRequestTypeSync:{
            NSHTTPURLResponse *httpURLResponse = nil;
            NSURLResponse *urlResponse = nil;
            
            NSData *responseData = nil;
            responseData = [NSURLConnection sendSynchronousRequest: request returningResponse: &urlResponse error: NULL];
            
            id JSON = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
            
            if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                httpURLResponse = (NSHTTPURLResponse *)urlResponse;
            }

            BOOL isUnacceptableStatusCode = [self isUnacceptableStatusCode:httpURLResponse.statusCode];
            if ( isUnacceptableStatusCode && failureHandler ) {
                
                NSString *errorStr = [NSString stringWithFormat:@"Unxpected status code, got %d",httpURLResponse.statusCode];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorStr forKey:NSLocalizedDescriptionKey];
                NSError *errorToReturn = [NSError errorWithDomain:PryvSDKDomain code:-1011 userInfo:userInfo];

                failureHandler (errorToReturn);
            }else if (successHandler) {
                successHandler (request, httpURLResponse, JSON);
            }
            
            
        }
            break;
            
        default:
            break;
    }

}

@end
