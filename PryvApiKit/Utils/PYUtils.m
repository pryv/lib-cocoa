//
//  PYUtils.m
//  PryvApiKit
//
//  Created by Perki on 20.01.14.
//  Copyright (c) 2014 Pryv. All rights reserved.
//

#import "PYUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PYUtils

+ (NSString*)md5FromString:(NSString*)source
{
    // Create pointer to the string as UTF8
    const char *ptr = [source UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
