//
//  PYClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

//compile time check for OS
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

#import "PYClient.h"
#import "PYConstants.h"
#import "PYError.h"
#import "PYErrorUtility.h"
#import "PYAccess.h"
#import "PYAttachment.h"
#import "PYAsyncService.h"
#import "PYJSONUtility.h"

@implementation PYClient

static NSString *myDefaultDomain;

+ (NSString *)defaultDomain {
    if (myDefaultDomain == nil) myDefaultDomain = kPYAPIDomain;
    return myDefaultDomain;
}

+ (void)setDefaultDomain:(NSString*) domain {
    myDefaultDomain = domain;
}

+ (void)setDefaultDomainStaging {
    [PYClient setDefaultDomain:kPYAPIDomainStaging];
}

+ (PYAccess *)createAccessWithUsername:(NSString *)username andAccessToken:(NSString *)token;
{
    PYAccess *access = [[PYAccess alloc] initWithUsername:username andAccessToken:token];
    return [access autorelease];
}

/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
#pragma mark - PrYv API authorize and get server time (GET /)

+ (id)nonNil:(id)object
{
    if (!object) {
        return @"";
    }
    else
        return object;
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

+ (NSString *)urlPath:(NSString *)path withParams:(NSDictionary *)params
{
    if (path == nil) path = @"";
    NSMutableString *pathString = [NSMutableString stringWithString:path];
    if (params) {
        [pathString appendString:@"?"];
        for (NSString *key in [params allKeys])
        {
            [pathString appendFormat:@"%@=%@&",key,[params valueForKey:key]];
        }
        [pathString deleteCharactersInRange:NSMakeRange([pathString length]-1, 1)];
    }
    return [pathString copy];
}

+ (NSString *)getURLPath:(NSString *)path withParams:(NSDictionary *)params
{
    if (path == nil) path = @"";
    NSMutableString *pathString = [NSMutableString stringWithString:path];

    [pathString appendString:@"?"];
    for (NSString *key in [params allKeys])
    {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *valueArray = value;
            [pathString appendFormat:@"%@=",key];
            for (int i = 0; i < valueArray.count; i++) {
                
                id arrayValue = [valueArray objectAtIndex:i];
                [pathString appendFormat:@"%@",arrayValue];
                
                if (i != valueArray.count - 1) {
                    //If it's not last element add comma (,)
                    [pathString appendString:@","];
                }
            }
            [pathString appendString:@"&"];
        }else{
            [pathString appendFormat:@"%@=%@&",key,[params objectForKey:key]];
            
        }
    }
    [pathString deleteCharactersInRange:NSMakeRange([pathString length]-1, 1)];
    return pathString;

}

+ (void) apiRequest:(NSString *)fullURL
            headers:(NSDictionary *)headers
        requestType:(PYRequestType)reqType
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler;
{
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    
    NSURL *url;

    
    // -- headers
    if (headers != nil) {
        NSEnumerator *e = [(NSDictionary*)headers keyEnumerator];
        NSString *k, *v;
        while ((k = [e nextObject]) != nil)
        {
            v = [(NSDictionary*)headers objectForKey: k];
            [request setValue:v forHTTPHeaderField:k];
        }
    }

    if (!fullURL) {
        [NSException raise:@"There is no path string" format:@"Path can't be nil"];
        return;
    }
    
    url = [NSURL URLWithString:fullURL];
    
    
    [request setURL:url];    
    NSDictionary *postDataa = postData;
        
    if ( (method == PYRequestMethodGET  && postDataa != nil) || (method == PYRequestMethodDELETE && postDataa != nil) )
    {
        [NSException raise:NSInvalidArgumentException format:@"postData must be nil for GET method or DELETE method"];
        return;
        
    }
    
    if (attachments && attachments.count) {
        
        NSData *data = [PYJSONUtility getDataFromJSONObject:postDataa];
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
            request.HTTPBody = [PYJSONUtility getDataFromJSONObject:postDataa];
        }
        

    }
    
    [self sendRequest:request withReqType:reqType success:successHandler failure:failureHandler];
}

+ (void)sendRequest:(NSURLRequest *)request
        withReqType:(PYRequestType)reqType
            success:(PYClientSuccessBlock)successHandler
            failure:(PYClientFailureBlock)failureHandler
{
    switch (reqType) {
        case PYRequestTypeAsync:{
            NSLog(@"started async request with url: %@",[[request URL] absoluteString]);
            [PYAsyncService JSONRequestServiceWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, id JSON) {
                if (successHandler) {
                    successHandler(req,resp,JSON);
                }
            } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, id JSON) {
                if (failureHandler) {
                    NSError *errorToReturn = [PYErrorUtility getErrorFromJSONResponse:JSON error:error withResponse:resp andRequest:request];
                    failureHandler(errorToReturn);
                }
            }];
            
        }
            break;
        case PYRequestTypeSync:{
            
            NSError *error = nil;
            NSHTTPURLResponse *httpURLResponse = nil;
            NSHTTPURLResponse *urlResponse = nil;
            
            NSData *responseData = nil;
            NSLog(@"started sync request with url: %@",[[request URL] absoluteString]);
            responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
            if (error && failureHandler) {
                NSError *errorToReturn = [PYErrorUtility getErrorFromJSONResponse:nil error:error withResponse:urlResponse andRequest:request];
                failureHandler(errorToReturn);
                return;
            }
            
            id JSON = [PYJSONUtility getJSONObjectFromData:responseData];
            if (JSON == nil) {
                //This is not valid JSON object, this means that this is attached file (NSData)
                JSON = responseData;
            }
            
            if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
                httpURLResponse = (NSHTTPURLResponse *)urlResponse;
            }
            
            BOOL isUnacceptableStatusCode = [[self class] isUnacceptableStatusCode:httpURLResponse.statusCode];
            if ( isUnacceptableStatusCode && failureHandler ) {
                
                NSError *errorToReturn = [PYErrorUtility getErrorFromJSONResponse:JSON error:nil withResponse:httpURLResponse andRequest:request];
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
