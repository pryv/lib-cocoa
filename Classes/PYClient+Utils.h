//
//  PYClient+Utils.h
//  Pods
//
//  Created by Perki on 06.06.14.
//
//

#import "PYClient.h"

@interface PYClient (Utils)

+ (NSString *)getMethodName:(PYRequestMethod)method;

+ (NSString *)fileMIMEType:(NSString*)file;

+ (BOOL)isUnacceptableStatusCode:(NSUInteger)statusCode;

+ (NSString *)getURLPath:(NSString *)path withParams:(NSDictionary *)params;

@end
