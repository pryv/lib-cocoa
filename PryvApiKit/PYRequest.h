//
//  PYRequest.h
//  PryvApiKit
//
//  Created by Perki on 03.01.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYClient.h"

@interface PYRequest : NSMutableURLRequest
{
    NSNumber *_serverTime;
}

@property (nonatomic, retain) NSNumber *serverTime;


- (PYRequest*) initWithfullURL:(NSString *)fullURL
                       headers:(NSDictionary*)headers
                   requestType:(PYRequestType)reqType
                        method:(PYRequestMethod)method
                      postData:(NSDictionary *)postData
                   attachments:(NSArray *)attachments
                       success:(PYClientSuccessBlock)successHandler
                       failure:(PYClientFailureBlock)failureHandler;

@end
