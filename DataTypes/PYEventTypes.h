//
//  EventTypes.h
//  PryvApiKit
//
//  Created by Perki on 28.11.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEvent.h"

typedef void (^PYEventTypesCompletionBlock)(id object, NSError *error);

@interface PYEventTypes : NSObject

+ (PYEventTypes*)sharedInstance;

- (void)reloadWithCompletionBlock:(PYEventTypesCompletionBlock)completionBlock;

- (NSDictionary*)hierarchical;

- (NSDictionary*)extras;

- (NSDictionary*) definitionForPYEvent:(PYEvent*)event;

- (BOOL)isNumerical:(PYEvent*)event;


@end
