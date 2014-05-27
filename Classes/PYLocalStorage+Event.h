//
//  PYLocalStorage+Event.h
//  Pods
//
//  Created by Perki on 27.05.14.
//
//

@class PYEvent;
@class PYConnection;

#import "PYLocalStorage.h"

@interface PYLocalStorage (Event)

+ (PYEvent*) createTempEvent;

+ (PYEvent*) eventById:(NSString*)eventId onConnection:(PYConnection*)connection;


@end
