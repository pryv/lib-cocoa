//
//  PYEvent+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 3/18/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEvent+JSON.h"

@implementation PYEvent (JSON)

+ (PYEvent *)eventFromDictionary:(NSDictionary *)eventDictionary
{
    //    PYEvent *event = [[PYEvent alloc] init];
    //
    //    double latitude = [[[[eventDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
    //    double longitude = [[[[eventDictionary objectForKey:@"value"] objectForKey:@"location"] objectForKey:@"long"] doubleValue];
    //    NSString *folderId = [eventDictionary objectForKey:@"folderId"];
    //    double time = [[eventDictionary objectForKey:@"time"] doubleValue];
    //
    //    event.latitude = [NSNumber numberWithDouble:latitude];
    //    event.longitude = [NSNumber numberWithDouble:longitude];
    //    event.folderId = folderId;
    //    event.uploaded = @YES; // do not try to upload it
    //    event.message = [[eventDictionary objectForKey:@"value"] objectForKey:@"message"];
    //    event.date = [NSDate dateWithTimeIntervalSince1970:time];
    //
    //    return [event autorelease];
}

- (NSData *)dataWithJSONObject
{
    //    // set empty message if no message
    //    NSString * message = self.message == nil ? @"" : self.message;
    //
    //    // turn the date into server format time
    //    NSNumber * time = [NSNumber numberWithDouble:[self.date timeIntervalSince1970]];
    //
    //    NSDictionary *eventDictionary =
    //                         @{
    //                                 @"type" :
    //                                 @{
    //                                         @"class" : @"position",
    //                                         @"format" : @"wgs84"
    //                                 },
    //                                 @"value" :
    //                                 @{
    //                                         @"location" :
    //                                         @{
    //                                                 @"lat" : self.latitude,
    //                                                 @"long" : self.longitude
    //                                         },
    //                                         @"message" : message
    //                                 },
    //                                 @"folderId" : self.folderId,
    //                                 @"time" : time
    //                         };
    //
    //    NSData *result = [NSJSONSerialization dataWithJSONObject:eventDictionary options:0 error:nil];
    //
    //    NSAssert(result != nil, @"Unsuccessful json creation from position event");
    //    NSAssert(result.length > 0, @"Unsuccessful json creation from position event");
    //
    //    return result;
}

@end
