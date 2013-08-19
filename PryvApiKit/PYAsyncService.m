//
//  PYAsyncService.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/15/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAsyncService.h"
#import "PYErrorUtility.h"
#import "PYJSONUtility.h"
#import "PYClient.h"

@interface PYAsyncService ()

@property (nonatomic) BOOL running;

@property (nonatomic, copy) PAAsyncServiceSuccessBlock onSuccess;
@property (nonatomic, copy) PAAsyncServiceFailureBlock onFailure;


@end

@implementation PYAsyncService

@synthesize responseData = _responseData;
@synthesize connection = _connection;
@synthesize request = _request;
@synthesize response = _response;
@synthesize running = _running;
@synthesize onSuccess = _onSuccess;
@synthesize onFailure = _onFailure;

- (void)dealloc
{
    [_request release];
    _request = nil;
    [_response release];
    _response = nil;
        
    [super dealloc];
}

- (id)initWithRequest:(NSURLRequest *)request
{
    self = [super init];
    if (self) {
        // create the connection with the request
        // and start loading the data asynchronously
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (_connection) {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            _responseData = [[NSMutableData data] retain];
            _running = YES;
        } else {
            // Inform the user that the connection failed.
        }
 
    }
    
    return self;
}

+ (void)JSONRequestServiceWithRequest:(NSURLRequest *)req
                            success:(PAAsyncServiceSuccessBlock)success
                            failure:(PAAsyncServiceFailureBlock)failure
{
    PYAsyncService *requestOperation = [[[self alloc] initWithRequest:req] autorelease];
    
    [requestOperation setCompletionBlockWithSuccess:^(NSURLRequest *req, NSHTTPURLResponse *resp, id JSON) {
        if (success) {
            success (req, resp, JSON);
        }
    } failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, id JSON) {
        if (failure) {
            failure (req, resp, error, JSON);
        }
    }];
}

- (void)setCompletionBlockWithSuccess:(PAAsyncServiceSuccessBlock)success
                              failure:(PAAsyncServiceFailureBlock)failure
{
    self.onSuccess = success;
    self.onFailure = failure;
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
    
//    float progress = data.length / _response.expectedContentLength;

}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [_responseData release];
    
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
    id JSON = [PYJSONUtility getJSONObjectFromData:self.responseData];
    
    BOOL isUnacceptableStatusCode = [PYClient isUnacceptableStatusCode:self.response.statusCode];
    
    if (isUnacceptableStatusCode)
	{
        if (self.onFailure){
            self.onFailure(self.request, self.response, nil, JSON);
        }
        // release the connection, and the data object
        [connection release];
        [_responseData release];

        return;
	}
    
    if (JSON == nil) {
        //This is not valid JSON object, this means that this is attached file (NSData)
        JSON = self.responseData;
    }
    
    if (self.onSuccess)
    {
        self.onSuccess(self.request, self.response, JSON);
    }
    
    // release the connection, and the data object
    [connection release];
    [_responseData release];
}


@end
