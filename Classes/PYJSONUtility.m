//
//  JSONUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYJSONUtility.h"
//#import "JSONKit.h"
#import <AnyJSON/AnyJSON.h>

@protocol MyNSJSONSerialization

+ (NSData *)dataWithJSONObject:(id)obj options:(id)opt error:(NSError **)error;
+ (id)JSONObjectWithData:(NSData *)data options:(id)opt error:(NSError **)error;

@end

@implementation PYJSONUtility

+ (NSData *)getDataFromJSONObject:(id)JSON
{
    Class<MyNSJSONSerialization> klass = NSClassFromString(@"NSJSONSerialization");
    if (klass) {
        return [klass dataWithJSONObject:JSON options:0 error:nil];
    }
    
    //return [JSON JSONData];
	return AnyJSONEncode([JSON ensureFoundationObject:JSON], nil)
}


+ (id)getJSONObjectFromData:(NSData *)JSONData
{
    if (JSONData == nil) return nil;
    Class<MyNSJSONSerialization> klass = NSClassFromString(@"NSJSONSerialization");
    if (klass) {
        return [klass JSONObjectWithData:JSONData options:0 error:nil];
    }
    
    //return [JSONData objectFromJSONData];
	return AnyJSONDecode([JSONData dataUsingEncoding:NSUTF8StringEncoding], nil);

}


@end
