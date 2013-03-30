//
//  PYClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYClient.h"
#import "PYConstants.h"
#import "PYError.h"
#import "PyErrorUtility.h"
#import "AFNetworking.h"
#import "PYAccess.h"


@implementation PYClient

+ (PYAccess *)createAccessWithUsername:(NSString *)username andAccessToken:(NSString *)token;
{
    PYAccess *access = [[PYAccess alloc] init];
    access.userID = username;
    access.accessToken = token;
    
    return [access autorelease];
}

/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
#pragma mark - PrYv API authorize and get server time (GET /)

+ (void)synchronizeTimeWithAccess:(PYAccess *)access successHandler:(void(^)(NSTimeInterval serverTime))successHandler errorHandler:(void(^)(NSError *error))errorHandler
{
    if (![[self class] isReadyForAccess:access]) {
        NSLog(@"fail synchronize: not initialized");
        
        if (errorHandler)
            errorHandler([[self class] createNotReadyErrorForAccess:access]);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/", [[self class] apiBaseUrlForAccess:access]]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    [client setDefaultHeader:@"Authorization" value:access.accessToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:access.accessToken forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSTimeInterval serverTime = [[[operation.response allHeaderFields] objectForKey:@"Server-Time"] doubleValue];
        
        NSLog(@"successfully authorized and synchronized with server time: %f ", serverTime);
//        _serverTimeInterval = [[NSDate date] timeIntervalSince1970] - serverTime;
        
        if (successHandler)
            successHandler(serverTime);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"could not synchronize");
        NSDictionary *userInfo = @{
                                   @"connectionError": [[self class] nonNil:error],
                                   @"NSHTTPURLResponse" : [[self class] nonNil:operation.response],
                                   @"serverError" : [[self class] nonNil:operation.responseString]
                                   };
        NSError *requestError = [NSError errorWithDomain:@"connection failed" code:100 userInfo:userInfo];
        
        if (errorHandler)
            errorHandler(requestError);
        
    }];
    [operation start];
}

+ (id)nonNil:(id)object
{
    if (!object) {
        return @"";
    }
    else
        return object;
}


+ (NSString *)apiBaseUrlForAccess:(PYAccess *)access
{
    return [NSString stringWithFormat:@"%@://%@%@", kPYAPIScheme, access.userID, kPYAPIHost];
}

+ (BOOL)isReadyForAccess:(PYAccess *)access
{
    // The manager must contain a user, token and a application channel
    if (access.userID == nil || access.userID.length == 0) {
        return NO;
    }
    if (access.accessToken == nil || access.accessToken.length == 0) {
        return NO;
    }
//    if (self.channelId == nil || self.channelId.length == 0) {
//        return NO;
//    }
    
    return YES;
}

+ (NSError *)createNotReadyErrorForAccess:(PYAccess *)access
{
    NSError *error;
    if (access.userID == nil || access.userID.length == 0) {
        error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorUserNotSet userInfo:nil];
    }
    else if (access.accessToken == nil || access.accessToken.length == 0) {
        error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorTokenNotSet userInfo:nil];
    }
//    else if (self.channelId == nil || self.channelId.length == 0) {
//        error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorChannelNotSet userInfo:nil];
//    }
    else {
        error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorUnknown userInfo:nil];
    }
    return error;
}




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
             access:(PYAccess *)access
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;
{
    NSDictionary *postDataa = postData;
    if (![[self class] isReadyForAccess:access])
    {
        NSError *notReadyError = [self createNotReadyErrorForAccess:access];
        [NSException raise:notReadyError.domain format:@"Error code %d",notReadyError.code];
        return;
    }
    
    
    if ( (method == PYRequestMethodGET  && postDataa != nil) || (method == PYRequestMethodDELETE && postDataa != nil) )
    {
        [NSException raise:NSInvalidArgumentException format:@"postData must be nil for GET method or DELETE method"];
        return;
        
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[self class] apiBaseUrlForAccess:access], path]];
    NSLog(@"url path is %@",[url absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setValue:access.accessToken forHTTPHeaderField:@"Authorization"];
    
    if (method == PYRequestMethodPOST || method == PYRequestMethodPUT) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }

    NSString *httpMethod = [[self class] getMethodName:method];
    request.HTTPMethod = httpMethod;
    
    if (postDataa) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDataa options:NSJSONReadingMutableContainers error:nil];
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

            BOOL isUnacceptableStatusCode = [[self class] isUnacceptableStatusCode:httpURLResponse.statusCode];
            if ( isUnacceptableStatusCode && failureHandler ) {
                
                NSError *errorToReturn = [PyErrorUtility getErrorFromJSONResponse:JSON error:nil withResponse:httpURLResponse];
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
