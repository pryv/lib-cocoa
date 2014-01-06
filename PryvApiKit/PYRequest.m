//
//  PYRequest.m
//  PryvApiKit
//
//  Created by Perki on 03.01.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYRequest.h"

@implementation PYRequest

@synthesize serverTime = _serverTime;


- (PYRequest*) initWithfullURL:(NSString *)fullURL
                       headers:(NSDictionary*)headers
                   requestType:(PYRequestType)reqType
                        method:(PYRequestMethod)method
                      postData:(NSDictionary *)postData
                   attachments:(NSArray *)attachments
                       success:(PYClientSuccessBlock)successHandler
                       failure:(PYClientFailureBlock)failureHandler
{
    self = [super init];
    if (self) {
       
    }
    return self;

}

@end
