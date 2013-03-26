//
//  PYChannelClient.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYChannelClient.h"
#import "AFNetworking.h"
#import "PYChannel.h"

@implementation PYChannelClient

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(PYChannelClient)

-(id)init
{
    self = [super init];
    if(self){
        
    }
    return self;
}

#pragma mark - PrYv API Channel (GET /channnels)

- (void)getChannelsWithSuccessHandler:(void (^)(NSArray *channelList))successHandler
                         errorHandler:(void (^)(NSError *error))errorHandler
{
    if (![self isReady]) {
        NSLog(@"fail retrieving channels: not initialized");
        
        if (errorHandler)
            errorHandler([self createNotReadyError]);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/channels/", [self apiBaseUrl]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:self.oAuthToken forHTTPHeaderField:@"Authorization"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"successfully received channels");
        
        NSMutableArray *channelList = [[[NSMutableArray alloc] init] autorelease];
        for (NSDictionary *channelDictionary in JSON) {
            PYChannel *channelObject = [PYChannel channelWithDictionary:channelDictionary];
            [channelList addObject:channelObject];
        }
        
        if (successHandler) {
            successHandler(channelList);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        NSLog(@"could not receive channels");
        
        NSDictionary *userInfo = @{
                                   @"connectionError": [self nonNil:error],
                                   @"NSHTTPURLResponse" : [self nonNil:response],
                                   @"serverError" : [self nonNil:JSON]
                                   };
        NSError *requestError = [NSError errorWithDomain:@"connection failed" code:200 userInfo:userInfo];
        
        if (errorHandler)
            errorHandler(requestError);
    }];
    [operation start];
}

@end
