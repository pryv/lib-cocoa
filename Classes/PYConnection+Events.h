//
//  PYConnection+Events.h
//  Pods
//
//  Created by Perki on 14.07.14.
//
//

#import "PYConnection.h"
#import "PYEventManagerProtocol.h"
#import "PYFilter.h"


@class PYAttachment;

@interface PYConnection (Events) <PYEventManagerProtocol> 

/** to be removed and replace by eventsGet.. **/
- (void)eventsWithFilter:(PYFilter *)filter
               fromCache:(void (^) (NSArray *cachedEventList))cachedEvents
               andOnline:(void (^) (NSArray *onlineEventList, NSNumber *serverTime))onlineEvents
    onlineDiffWithCached:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
            errorHandler:(void (^)(NSError *error))errorHandler;

@end
