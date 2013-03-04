//
//  PryvJSONUtils.m
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/4/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvJSONUtils.h"

@implementation PryvJSONUtils{
    
}
-(NSArray*)parseEvents:(NSString *)jsonString{
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSArray *jsonObjects = [jsonParser objectWithString:jsonString error:&error];
    [jsonParser release], jsonParser = nil;
    
    NSMutableArrary *events = [NSMutableArray array];
    
    for (NSDictionary *dict in jsonObjects)
    {
         PryvEvent *event = [[[PryvEvent alloc] init] autorelease];
        
         event.description=[dict objectForKey:@"description"];
         event.eventId=[dict objectForKey:@"eventId"];
         event.folderId=[dict objectForKey:@"folderId"];
         event.duration=[dict objectForKey:@"duration"];//handling of attachments todo
         [events addObject:event];
        event.
    }
}


@end


