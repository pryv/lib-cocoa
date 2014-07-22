//
//  PYOnlineController+Events.h
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import "PYOnlineController.h"
#import "PYEventManagerProtocol.h"

@interface PYOnlineController (Events) <PYEventManagerProtocol>



- (void) eventsGetWithFilter:(PYFilter*)filter
                successHandler:(void (^) (NSArray *eventList, NSNumber *serverTime, NSDictionary *details))successBlock
                  errorHandler:(void (^) (NSError *error))errorHandler;


@end
