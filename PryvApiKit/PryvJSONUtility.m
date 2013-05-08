//
//  JSONUtility.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "JSONUtility.h"
#import "JSONKit.h"

@implementation JSONUtility


+ (NSData *)getDataFromJSONObject:(id)JSON
{
    if ([NSJSONSerialization class]) {
        return [NSJSONSerialization dataWithJSONObject:JSON options:0 error:nil];
    }
    
    return [JSON JSONData];
}


+ (id)getJSONObjectFromData:(NSData *)JSONData
{
    if ([NSJSONSerialization class]) {
        return [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:nil];
    }
    
    return [JSONData objectFromJSONData];

}


@end
