//
//  PYClient+Utils.m
//  Pods
//
//  Created by Perki on 06.06.14.
//
//
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif

#import "PYClient+Utils.h"

@implementation PYClient (Utils)

#pragma mark - Utilities

//When an error occurs, the API returns a 4xx or 5xx status code, with the response body usually containing an error object detailing the cause

+ (NSIndexSet *)unacceptableStatusCodes {
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(400, 200)];
}

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode {
    
    return [[self unacceptableStatusCodes] containsIndex:statusCode] ? YES : NO;
}

+ (NSString *)getMethodName:(PYRequestMethod)method
{
    switch (method) {
        case PYRequestMethodGET:
            return @"GET";
        case PYRequestMethodPOST:
            return @"POST";
        case PYRequestMethodPUT:
            return @"PUT";
        case PYRequestMethodDELETE:
            return @"DELETE";
        default:
            break;
    }
}


/**
 * Utility to retrieve the mimetype of a file
 * TODO move to utils
 */
+ (NSString *)fileMIMEType:(NSString*)file
{
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return [(NSString *)MIMEType autorelease];
}


/**
 * Create add parameters to this url path
 * TODO move to utils
 */
+ (NSString *)getURLPath:(NSString *)path withParams:(NSDictionary *)params
{
    if (path == nil) path = @"";
    NSMutableString *pathString = [NSMutableString stringWithString:path];
    
    [pathString appendString:@"?"];
    for (NSString *key in [params allKeys])
    {
        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *valueArray = value;
            [valueArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [pathString appendFormat:@"%@[]=%@&",key,obj];
            }];
        }else{
            [pathString appendFormat:@"%@=%@&",key,[params objectForKey:key]];
            
        }
    }
    [pathString deleteCharactersInRange:NSMakeRange([pathString length]-1, 1)];
    return pathString;
    
}

@end
