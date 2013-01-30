//
//  Channel+Extras.m
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import "Channel+Extras.h"

@implementation Channel (Extras)

+ (id)channelWithDictionary:(NSDictionary *)dictionary andContext:(NSManagedObjectContext *)context {

    Channel *c = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:context];
    c.channelId = [dictionary objectForKey:@"id"];
    c.name = [dictionary objectForKey:@"name"];
    c.enforceNoEventsOverlap = [dictionary objectForKey:@"enforceNoEventsOverlap"];
    c.trashed = [NSNumber numberWithBool:[[dictionary objectForKey:@"trashed"] boolValue]];

    [context save:nil];

    return c;
}

@end
