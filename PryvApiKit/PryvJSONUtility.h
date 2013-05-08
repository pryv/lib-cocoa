//
//  JSONUtility.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONUtility : NSObject

+ (NSData *)getDataFromJSONObject:(id)JSON;
+ (id)getJSONObjectFromData:(NSData *)JSONData;

@end
