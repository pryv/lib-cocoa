//
//  PYUtilsLocalization.m
//  PryvApiKit
//
//  Created by Perki on 02.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYUtilsLocalization.h"
#import "PYClient.h"
#import "PYConstants.h"

@implementation PYUtilsLocalization

/**
 *
 */
+ (NSString *)fromDictionary:(NSDictionary *) dict defaultValue:(NSString *) defaultString {
    if (dict) {
        if ([dict objectForKey:[PYClient languageCodePrefered]]) { return [dict objectForKey:[PYClient languageCodePrefered]]; };
        if ([dict objectForKey:kLanguageCodeDefault]) { return [dict objectForKey:kLanguageCodeDefault]; };
    }
    return defaultString;
}

@end
