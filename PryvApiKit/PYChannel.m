//
//  Channel.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "PYChannel.h"


@implementation PYChannel

+ (id)channelWithDictionary:(NSDictionary *)dictionary
{
    
    PYChannel *c = [[PYChannel alloc] init];
    c.channelId = [dictionary objectForKey:@"id"];
    c.name = [dictionary objectForKey:@"name"];
    c.enforceNoEventsOverlap = [dictionary objectForKey:@"enforceNoEventsOverlap"];
    c.trashed = [NSNumber numberWithBool:[[dictionary objectForKey:@"trashed"] boolValue]];
    
    return [c autorelease];
}
@end
