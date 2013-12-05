//
//  EventTypes.h
//  PryvApiKit
//
//  Created by Perki on 28.11.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYEventType;

typedef void (^PYEventTypesCompletionBlock)(id object, NSError *error);

@interface PYEventTypes : NSObject
{
    NSDictionary* _hierarchical;
    NSMutableDictionary* _flat;
    NSDictionary* _extras;
    NSMutableArray* _measurementSets;
}


+ (PYEventTypes*)sharedInstance;

- (void)reloadWithCompletionBlock:(PYEventTypesCompletionBlock)completionBlock;

- (NSDictionary*)hierarchical;

- (NSDictionary*)extras;

- (NSArray*)measurementSets;

- (PYEventType*) pyTypeForEvent:(PYEvent*)event;

- (PYEventType*) pyTypeForString:(NSString*)eventTypeStr;


@end
