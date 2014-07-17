//
//  PYConnection+Synchronization.h
//  Pods
//
//  Created by Perki on 06.06.14.
//
//  Synchronization of events and streams created and modified online.
//  This  does not handle Synchronization of events created remotly

#import "PYConnection.h"

@interface PYConnection (Synchronization)

/**
 * Trigger synch request for all streams created or modified offline
 */
- (void)syncNotSynchedStreamsIfAny;

/**
 * Trigger synch request for all events created  or modified offline
 */
- (void)syncNotSynchedEventsIfAny:(void(^)(int successCount, int overEventCount))done;


/**
 @discussion
 this method simply connect to the Pryv API and synchronize with the localTime
 Delta time in seconds between server and machine is returned
 
 GET /
 */
- (void)synchronizeTimeWithSuccessHandler:(void(^)(NSTimeInterval serverTimeInterval))successHandler
                             errorHandler:(void(^)(NSError *error))errorHandler;

# pragma mark - private

/**
 * list of not yet snchronized events
 * @private
 */
- (NSArray*)eventsNotSync;



@end
