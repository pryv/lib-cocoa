//
//  PYAsyncService.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/15/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAsyncService.h"
#import "PYJSONUtility.h"
#import "PYClient.h"
#import "PYClient+Utils.h"
#import "PYError.h"

@interface PYAsyncService ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, retain) NSMutableData *responseData;

@property (nonatomic) BOOL running;
@property (nonatomic) PYRequestResultType requestResultType;

@property (nonatomic, copy) PYAsyncServiceSuccessBlock onSuccess;
@property (nonatomic, copy) PYAsyncServiceFailureBlock onFailure;
@property (nonatomic, copy) PYAsyncServiceProgressBlock onProgress;

- (id)initWithRequest:(NSURLRequest *)request;
- (void)stop;

@end

@implementation PYAsyncService

@synthesize responseData = _responseData;
@synthesize connection = _connection;
@synthesize request = _request;
@synthesize running = _running;
@synthesize onFailure = _onFailure;
@synthesize onSuccess = _onSuccess;
@synthesize requestResultType = _requestResultType;

- (void)dealloc
{
    [_request release];
    _request = nil;
    _connection = nil;
    _responseData = nil;
    
    [_onSuccess release];
    [_onFailure release];
    [_onProgress release];
    
    [super dealloc];
}

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        // create the connection with the request
        // and start loading the data asynchronously
        _request = request;
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        if (_connection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _responseData = [[NSMutableData data] retain];
            _running = YES;
        } else {
            NSLog(@"<ERROR> PYAsyncService.initWithRequest failed to create an NSURLConnection");
        }
    }
    return self;
}


- (void)setCompletionBlockWithSuccess:(PYAsyncServiceSuccessBlock)success
                              failure:(PYAsyncServiceFailureBlock)failure
                             progress:(PYAsyncServiceProgressBlock)progress
{
    self.onSuccess = success;
    self.onFailure = failure;
    self.onProgress = progress;
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)stop
{
	[_connection cancel];
	if (_running)
	{
		self.request = nil;
		_running = NO;
		
	}
}

#pragma mark - static hooks


+ (void)RAWRequestServiceWithRequest:(NSURLRequest *)request
                             success:(PYAsyncServiceSuccessBlock)success
                             failure:(PYAsyncServiceFailureBlock)failure
{
    [self RAWRequestServiceWithRequest:request success:success failure:failure progress:nil];
}

+ (void)RAWRequestServiceWithRequest:(NSURLRequest *)request
                             success:(PYAsyncServiceSuccessBlock)success
                             failure:(PYAsyncServiceFailureBlock)failure
                            progress:(PYAsyncServiceProgressBlock)progress
{
    PYAsyncService *requestOperation = [[[self alloc] initWithRequest:request] autorelease];
    
    dispatch_async(dispatch_get_main_queue(), ^{ // needed otherwise the connection may be lost
        
        [requestOperation setCompletionBlockWithSuccess:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSMutableData *responseData) {
            if (success) {
                success (req, resp, responseData);
            }
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, id responseData) {
            if (failure) {
                failure (req, resp, error, responseData);
            }
        } progress:progress];
        
    });
    
}


+ (void)JSONRequestServiceWithRequest:(NSURLRequest *)request
                              success:(PYAsyncServiceSuccessBlockJSON)success
                              failure:(PYAsyncServiceFailureBlock)failure
{
    [self JSONRequestServiceWithRequest:request success:success failure:failure progress:nil];
}

+ (void)JSONRequestServiceWithRequest:(NSURLRequest *)request
                              success:(PYAsyncServiceSuccessBlockJSON)success
                              failure:(PYAsyncServiceFailureBlock)failure
                             progress:(PYAsyncServiceProgressBlock)progress
{
    DLog(@"*87 Starting JSONRequestServiceWithRequest: %p, isMainThread: %@", request, [NSThread isMainThread] ? @"YES": @"NO");
    dispatch_async(dispatch_get_main_queue(), ^{ // needed otherwise the request may be lost
                
        PYAsyncService *requestOperation = [[PYAsyncService alloc] initWithRequest:request];
        [requestOperation setCompletionBlockWithSuccess:^(NSURLRequest *req, NSHTTPURLResponse *resp,  NSMutableData *responseData) {
            
            if (success) {
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                
                    id JSON = [PYJSONUtility getJSONObjectFromData:responseData];
                    if (JSON == nil) { // Is not NSDictionary or NSArray
                        if ([resp statusCode] == 204) {
                            // NOTE: special case - Deleting trashed events returns zero length content
                            // maybe need to handle it somewhere else
                            JSON = [[[NSDictionary alloc] init] autorelease];
                        } else {
                            NSDictionary *errorInfoDic = @{ @"message" : @"Data is not JSON"};
                            NSError *error =  [NSError errorWithDomain:PryvErrorJSONResponseIsNotJSON code:PYErrorUnknown userInfo:errorInfoDic];
                            failure (req, resp, error, responseData);
                            return;
                        }
                    }
                        
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        DLog(@"*87 Stopping JSONRequestServiceWithRequest: %p", request);
                        success (req, resp, JSON);
                    });
                    
                });
            }
            
        } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, NSMutableData *responseData) {
            if (failure) {
                failure (req, resp, error, responseData);
            }
        } progress:progress];
    });
    
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [_responseData setLength:0];
    self.response = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [_responseData appendData:data];
    
    //NSLog(@"Progress %lu / %lld", (unsigned long)data.length, _response.expectedContentLength);
    
    if (self.onProgress) {
        self.onProgress(data.length, (unsigned long) _response.expectedContentLength);
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    connection = nil, [connection release];
    // receivedData is declared as a method instance elsewhere
    _responseData = nil, [_responseData release];
    
    self.request = nil;
    
    _running = NO;
    
    // inform the user
    //    NSLog(@"Connection failed! Error - %@ %@",
    //          [error localizedDescription],
    //          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if (self.onFailure){
        self.onFailure(self.request, self.response, error, nil);
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[_responseData length]);
    _running = NO;
    
    BOOL isUnacceptableStatusCode = [PYClient isUnacceptableStatusCode:self.response.statusCode];
    
    if (isUnacceptableStatusCode)
	{
        NSError *e = [NSError errorWithDomain:@"HTTP URL Connection is unacceptable status code"
                                         code:self.response.statusCode userInfo:nil];
        if (self.onFailure){
            self.onFailure(self.request, self.response, e, self.responseData);
        }
        // release the connection, and the data object
        connection = nil, [connection release];
        _responseData = nil, [_responseData release];
        
        return;
	}
    
    if (self.onSuccess)
    {
        self.onSuccess(self.request, self.response, self.responseData);
    }
    
    // release the connection, and the data object
    connection = nil, [connection release];
    _responseData = nil, [_responseData release];
}


@end
