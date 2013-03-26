//
//  PPrYvApiClient.m
//  AT PrYv
//
//  Created by Nicolas Manzini on 21.12.12.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import "PYApiConnectionClient.h"
#import "PYEventAttachment.h"
#import "PYChannel.h"
#import "PYEvent.h"
#import "PYConstants.h"
#import "PYFolderClient.h"
#import "PYError.h"


@interface PYApiConnectionClient ()


@end

@implementation PYApiConnectionClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(PYApiConnectionClient)

#pragma mark - Class methods

-(id)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}


#pragma mark - private helpers

- (id)nonNil:(id)object
{
  if (!object) {
    return @"";
  }
  else
    return object;
}

- (NSString *)apiBaseUrl
{
    return [NSString stringWithFormat:@"%@://%@%@", kPYAPIScheme, self.userId, kPYAPIHost];
}

- (BOOL)isReady
{
    // The manager must contain a user, token and a application channel
    if (self.userId == nil || self.userId.length == 0) {
        return NO;
    }
    if (self.oAuthToken == nil || self.oAuthToken.length == 0) {
        return NO;
    }
    if (self.channelId == nil || self.channelId.length == 0) {
        return NO;
    }

    return YES;
}

- (NSError *)createNotReadyError
{
    NSError *error;
    if (self.userId == nil || self.userId.length == 0) {
            error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorUserNotSet userInfo:nil];
        }
        else if (self.oAuthToken == nil || self.oAuthToken.length == 0) {
            error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorTokenNotSet userInfo:nil];
        }
        else if (self.channelId == nil || self.channelId.length == 0) {
            error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorChannelNotSet userInfo:nil];
        }
        else {
            error = [NSError errorWithDomain:PryvSDKDomain code:PYErrorUnknown userInfo:nil];
        }
    return error;
}


#pragma mark - Initiate

- (void)startClientWithUserId:(NSString *)userId
                   oAuthToken:(NSString *)token
                    channelId:(NSString *)channelId
               successHandler:(void (^)(NSTimeInterval serverTime))successHandler
                 errorHandler:(void(^)(NSError *error))errorHandler;
{
    NSParameterAssert(userId);
    NSParameterAssert(token);
    NSParameterAssert(channelId);

    self.userId = userId;
    self.oAuthToken = token;
    self.channelId = channelId;

    [self synchronizeTimeWithSuccessHandler:successHandler
                               errorHandler:errorHandler];
}

#pragma mark - PrYv API authorize and get server time (GET /)

- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTime))successHandler errorHandler:(void(^)(NSError *error))errorHandler
{
    if (![self isReady]) {
        NSLog(@"fail synchronize: not initialized");

        if (errorHandler)
            errorHandler([self createNotReadyError]);
        return;
    }
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/", [self apiBaseUrl]]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    [client setDefaultHeader:@"Authorization" value:self.oAuthToken];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:self.oAuthToken forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSTimeInterval serverTime = [[[operation.response allHeaderFields] objectForKey:@"Server-Time"] doubleValue];
        
        NSLog(@"successfully authorized and synchronized with server time: %f ", serverTime);
        _serverTimeInterval = [[NSDate date] timeIntervalSince1970] - serverTime;

        if (successHandler)
            successHandler(serverTime);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"could not synchronize");
        NSDictionary *userInfo = @{
                @"connectionError": [self nonNil:error],
                @"NSHTTPURLResponse" : [self nonNil:operation.response],
                @"serverError" : [self nonNil:operation.responseString]
        };
        NSError *requestError = [NSError errorWithDomain:@"connection failed" code:100 userInfo:userInfo];

        if (errorHandler)
            errorHandler(requestError);

    }];
    [operation start];
}

@end

