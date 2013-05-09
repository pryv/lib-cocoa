//
//  PYEvent+JSON.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <PryvApiKit/PryvApiKit.h>

@interface PryvEvent (JSON)

+ (id)eventFromDictionary:(NSDictionary *)JSON;

@end
