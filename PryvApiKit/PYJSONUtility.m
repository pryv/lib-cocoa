//
//  JSONUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYJSONUtility.h"
#import "JSONKit.h"

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
    
    return [JSON JSONData];
}


+ (id)getJSONObjectFromData:(NSData *)JSONData
{
    Class<MyNSJSONSerialization> klass = NSClassFromString(@"NSJSONSerialization");
    if (klass) {
        return [klass JSONObjectWithData:JSONData options:0 error:nil];
    }
    
    return [JSONData objectFromJSONData];

}


@end
