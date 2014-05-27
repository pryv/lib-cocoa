//
//  PYLocalStorage+PYEvent.m
//  Pods
//
//  Created by Perki on 27.05.14.
//
//

#import "PYLocalStorage+Event.h"

@implementation PYLocalStorage (PYEvent)



+ (PYEvent*) createTempEvent {
    return (PYEvent*)[[PYLocalStorage sharedInstance] createTempEntityForName:@"PYEvent"];
}


- (PYEvent*) _eventById:(NSString*)eventId onConnection:(PYConnection*)connection {

    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"PYEvent" inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"eventId = %@", eventId];
    [request setPredicate:predicate];
    
    
    NSError *error;
    NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    if ([array count] > 1) {
       return (PYEvent*)[array objectAtIndex:0];
    }
    return nil;
}

+ (PYEvent*) eventById:(NSString*)eventId onConnection:(PYConnection*)connection {
    return [[PYLocalStorage sharedInstance] _eventById:eventId onConnection:connection];
}


@end
