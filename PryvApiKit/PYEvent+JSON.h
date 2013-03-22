//
//  PYEvent+JSON.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PYEvent (JSON)

+ (PYEvent *)eventFromDictionary:(NSDictionary *)eventDictionary;
- (NSData *)dataWithJSONObject;

@end
