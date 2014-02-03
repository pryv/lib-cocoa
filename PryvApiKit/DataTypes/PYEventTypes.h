//
//  EventTypes.h
//  PryvApiKit
//
//  Created by Perki on 28.11.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEvent;
@class PYEventType;
@class PYEventClass;

typedef void (^PYEventTypesCompletionBlock)(id object, NSError *error);

@interface PYEventTypes : NSObject
{
    // RAW
    NSDictionary* _hierarchical;
    NSDictionary* _extras;
    
    // Computed
    NSMutableDictionary* _flat;
    NSMutableDictionary* _klasses;
    NSMutableArray* _measurementSets;
}


@property (nonatomic, strong) NSDictionary *hierarchical;
@property (nonatomic, strong) NSDictionary *extras;

@property (nonatomic, strong) NSMutableDictionary *flat;
@property (nonatomic, strong) NSMutableDictionary *klasses;
@property (nonatomic, strong) NSMutableArray *measurementSets;

+ (PYEventTypes *)sharedInstance;

- (void)reloadWithCompletionBlock:(PYEventTypesCompletionBlock)completionBlock;

- (PYEventType *)pyTypeForEvent:(PYEvent*)event;

- (PYEventType *)pyTypeForString:(NSString*)typeKey;

- (PYEventClass *)pyClassForString:(NSString*)classKey;


@end
