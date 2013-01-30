//
//  Channel+Extras.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Channel.h"

@interface Channel (Extras)

+ (id)channelWithDictionary:(NSDictionary *)dictionary andContext:(NSManagedObjectContext *)context;

@end
