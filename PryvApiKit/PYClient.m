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
#import "PYAccess.h"
#import "PYAttachment.h"
#import "PYAsyncService.h"


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

+ (void)synchronizeTimeWithAccess:(PYAccess *)access
                   successHandler:(void(^)(NSTimeInterval serverTime))successHandler
                     errorHandler:(void(^)(NSError *error))errorHandler
{
    if (![[self class] isReadyForAccess:access]) {
        NSLog(@"fail synchronize: not initialized");
        
        if (errorHandler)
            errorHandler([[self class] createNotReadyErrorForAccess:access]);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"/"];    
    [self apiRequest:path
              access:access
         requestType:PYRequestTypeAsync
              method:PYRequestMethodGET
            postData:nil
         attachments:nil
             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 NSTimeInterval serverTime = [[[response allHeaderFields] objectForKey:@"Server-Time"] doubleValue];
                 
                 NSLog(@"successfully authorized and synchronized with server time: %f ", serverTime);
                 //        _serverTimeInterval = [[NSDate date] timeIntervalSince1970] - serverTime;
                 
                 if (successHandler)
                     successHandler(serverTime);

        
    } failure:^(NSError *error) {        
        if (errorHandler)
            errorHandler(error);

        
    }];    
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

+ (NSString *)fileMIMEType:(NSString*)file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    
    return [(NSString *)MIMEType autorelease];
}


+ (void) apiRequest:(NSString *)path
             access:(PYAccess *)access
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;
{
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setValue:access.accessToken forHTTPHeaderField:@"Authorization"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[self class] apiBaseUrlForAccess:access], path]];
    [request setURL:url];
    NSLog(@"url path is %@",[url absoluteString]);

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
    
    if (attachments && attachments.count) {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:postDataa options:0 error:nil];

        NSMutableData *bodyData = [[NSMutableData alloc] init];
        NSString *boundaryIdentifier = [NSString stringWithFormat:@"--%@--", [[NSProcessInfo processInfo] globallyUniqueString]];
        NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundaryIdentifier] dataUsingEncoding:NSUTF8StringEncoding];
        
        // start
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryIdentifier] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];        
        
        // param: JSON
        [bodyData appendData:boundaryData];
        [bodyData appendData:[@"Content-Disposition: form-data; name=\"event\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:data];
        [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        // param: attachment
        for (PYAttachment *attachment in attachments) {
        
            [bodyData appendData:boundaryData];
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", attachment.name, attachment.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self fileMIMEType:attachment.fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:attachment.fileData];
            [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
    
        // end
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundaryIdentifier] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:bodyData];
        [bodyData release];
        
    }else{
        
        if (method == PYRequestMethodPOST || method == PYRequestMethodPUT) {
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        
        NSString *httpMethod = [[self class] getMethodName:method];
        request.HTTPMethod = httpMethod;
        request.timeoutInterval = 60.0f;
        
        if (postDataa) {
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:postDataa options:NSJSONReadingMutableContainers error:nil];
        }
        

    }
    
    switch (reqType) {
        case PYRequestTypeAsync:{
            
            [PYAsyncService JSONRequestServiceWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                if (successHandler) {
                    successHandler(request,response,JSON);
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                if (failureHandler) {
                    NSError *errorToReturn = [PyErrorUtility getErrorFromJSONResponse:JSON error:error withResponse:response];
                    failureHandler(errorToReturn);
                }
            }];
                        
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
