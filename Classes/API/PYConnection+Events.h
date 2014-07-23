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

/**
 * @discussion temporary method until offline first is implemented
 */
- (void)eventCreate:(PYEvent *)event andCacheFirst:(BOOL)cacheFirst
                  successHandler:(void (^) (NSString *newEventId, NSString *stoppedId, PYEvent *event))successHandler
                    errorHandler:(void (^)(NSError *error))errorHandler;

/** to be removed and replace by eventsGet.. **/
- (void)eventsWithFilter:(PYFilter *)filter
               fromCache:(void (^) (NSArray *cachedEventList))cachedEvents
               andOnline:(void (^) (NSArray *onlineEventList, NSNumber *serverTime))onlineEvents
    onlineDiffWithCached:(void (^) (NSArray *eventsToAdd, NSArray *eventsToRemove, NSArray *eventModified))syncDetails
            errorHandler:(void (^)(NSError *error))errorHandler;


- (void) eventCreateOrReuseFromDictionary:(NSDictionary*) eventDic
                                   create:(void(^) (PYEvent*event))create
                                   update:(void(^) (PYEvent*event))update
                                     same:(void(^) (PYEvent*event))same;

@end
