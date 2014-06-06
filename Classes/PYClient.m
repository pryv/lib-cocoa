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
#import "PYClient+Utils.h"
#import "PYConstants.h"
#import "PYErrorUtility.h"
#import "PYConnection.h"
#import "PYAttachment.h"
#import "PYAsyncService.h"
#import "PYJSONUtility.h"

@implementation PYClient

static NSString *s_myDefaultDomain;
static NSString *s_myLanguageCodePrefered;



+ (NSString *)languageCodePrefered {
    if (s_myLanguageCodePrefered == nil) s_myLanguageCodePrefered = kLanguageCodeDefault;
    return s_myLanguageCodePrefered;
}

+ (void)setLanguageCodePrefered:(NSString*) languageCode {
     s_myLanguageCodePrefered = languageCode;
}

+ (NSString *)defaultDomain {
    if (s_myDefaultDomain == nil) s_myDefaultDomain = kPYAPIDomain;
    return s_myDefaultDomain;
}

+ (void)setDefaultDomain:(NSString*) domain {
    s_myDefaultDomain = domain;
}

+ (void)setDefaultDomainStaging {
    [PYClient setDefaultDomain:kPYAPIDomainStaging];
}

+ (PYConnection *)createConnectionWithUsername:(NSString *)username andAccessToken:(NSString *)token;
{
    PYConnection *connection = [[PYConnection alloc] initWithUsername:username andAccessToken:token];
    return [connection autorelease];
}

/**
 @discussion
 this method simply connect to the PrYv API to retrive the server time in the returned header
 This method will be called when you start the manager
 
 GET /
 
 */
#pragma mark - PrYv API authorize and get server time (GET /)




/**
 * Prepare the request for the API
 */
+ (NSMutableURLRequest*) apiRequest:(NSString *)fullURL
            headers:(NSDictionary *)headers
             method:(PYRequestMethod)method
           postData:(NSDictionary *)postData
        attachments:(NSArray *)attachments
            success:(PYClientSuccessBlockDict)successHandler
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
        
        [NSException raise:@"There is no fullURL string" format:@"fullURL can't be nil"];
    }
    
    url = [NSURL URLWithString:fullURL];
    
    
    [request setURL:url];
    NSDictionary *postDataa = postData;
    
    if ( (method == PYRequestMethodGET  && postDataa != nil) || (method == PYRequestMethodDELETE && postDataa != nil) )
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"postData must be nil for GET method or DELETE method" ];
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
             // eventually load all attachments data from cached data
            if (attachment.fileData && attachment.fileData.length > 0) {
            
                
                [bodyData appendData:boundaryData];
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", attachment.name, attachment.fileName] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self fileMIMEType:attachment.fileName]] dataUsingEncoding:NSUTF8StringEncoding]];
                [bodyData appendData:attachment.fileData];
                [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
            } else {
                NSLog(@"<warning> Skipped upload of empty attachement: %@", attachment.name);
            }
            
        }
        
        // end
        [bodyData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundaryIdentifier] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:bodyData];
        request.timeoutInterval = 60.0f;
        
        //####### DISPLAY SENT REQUEST (use with plain text attachment(s) only)#########
        
        //        NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
        //        NSLog(@"Request : %@\n%@",[request allHTTPHeaderFields],bodyString);
        [bodyData release];
        
    }else{ //--- no attachements --
        
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
    [self sendJSONDictRequest:request success:successHandler failure:failureHandler];
    return request;
}

/**
 *
 */
+ (void)sendJSONDictRequest:(NSURLRequest *)request
            success:(PYClientSuccessBlockDict)successHandler
            failure:(PYClientFailureBlock)failureHandler
{

    //NSLog(@"started JSON request with url: %@",[[request URL] absoluteString]);
    [PYAsyncService JSONRequestServiceWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, id JSON) {
        if (successHandler) {
            NSAssert([JSON isKindOfClass:[NSDictionary class]], @"result is not NSDictionary");
            successHandler(req, resp,(NSDictionary*) JSON);
        }
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, NSMutableData *responseData) {
        
        if (failureHandler) {
            NSDictionary *JSON = [PYJSONUtility getJSONObjectFromData:responseData];
            NSError *errorToReturn;
            if (JSON == nil) {
                errorToReturn = [PYErrorUtility getErrorFromStringResponse:responseData error:error withResponse:resp andRequest:request];
            } else {
                errorToReturn = [PYErrorUtility getErrorFromJSONResponse:JSON error:error withResponse:resp andRequest:request];
            }
             NSLog(@"** PYClient.sendJSONDictRequest Async \n** Error: %@, \n** requestUrl: %@,\n** body: %@ ",
                   errorToReturn, [[request URL] absoluteString],
                   [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
            failureHandler(errorToReturn);
        }
    }];
}

+ (void)sendRAWRequest:(NSURLRequest *)request
               success:(PYClientSuccessBlock)successHandler
               failure:(PYClientFailureBlock)failureHandler
{
    //NSLog(@"started RAW request with url: %@",[[request URL] absoluteString]);
    [PYAsyncService RAWRequestServiceWithRequest:request success:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *result) {
        if (successHandler) {
            successHandler(req,resp,result);
        }
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error,  NSMutableData *responseData) {
        
        if (failureHandler) {
            failureHandler([PYErrorUtility getErrorFromStringResponse:responseData error:error withResponse:resp andRequest:request]);
        }
    }];
}

@end
