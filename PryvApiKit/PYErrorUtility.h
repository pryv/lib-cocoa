//
//  PyErrorUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/21/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYErrorUtility : NSObject

+ (NSError *)getErrorFromJSONResponse:(id)JSONerror
                                error:(NSError *)error
                         withResponse:(NSHTTPURLResponse *)response
                           andRequest:(NSURLRequest *)request;

@end
