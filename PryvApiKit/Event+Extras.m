//
//  Created by Konstantin Dorodov on 1/4/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "Event+Extras.h"
#import "PPrYvApiClient.h"

@implementation Event (Extras)

+ (Event *)createEventInLocation:(CLLocation *)location
                                     withMessage:(NSString *)message
                                      attachment:(NSURL *)fileURL
                                          folder:(NSString *)folderId
                                       inContext:(NSManagedObjectContext *)context
{
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
    event.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    event.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    event.message = message;
    event.folderId = folderId;
    event.attachment = [fileURL absoluteString];
    event.uploaded = [NSNumber numberWithBool:NO];
    event.date = [NSDate dateWithTimeIntervalSince1970:([[NSDate date] timeIntervalSince1970] - [PPrYvApiClient sharedClient].serverTimeInterval)];

    [context save:nil];

    return event;
}


- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.folderId=%@", self.folderId];
    [description appendFormat:@", self.message=%@", self.message];
    [description appendFormat:@", self.attachment=%@", self.attachment];
    [description appendFormat:@", self.latitude=%@", self.latitude];
    [description appendFormat:@", self.longitude=%@", self.longitude];
    [description appendFormat:@", self.uploaded=%@", self.uploaded];
    [description appendFormat:@", self.date=%@", self.date];
    [description appendString:@">"];
    return description;
}



@end