//
//  PYError.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/19/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The NSError domain of all errors returned by the Pryv SDK.
 */
FOUNDATION_EXPORT NSString *const PryvSDKDomain;

FOUNDATION_EXPORT NSString *const PryvErrorSubErrorsKey;

FOUNDATION_EXPORT NSString *const PryvErrorJSONResponseId;

FOUNDATION_EXPORT NSString *const PryvErrorHTTPStatusCodeKey;


typedef enum PryvErrorCode {

    PYErrorUserNotSet = 0,
    
    PYErrorTokenNotSet,
    
    PYErrorChannelNotSet,
    
    PYErrorUnknown,
    
} PryvErrorCode;

