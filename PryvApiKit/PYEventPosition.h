//
//  PYEventPosition.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
@class PYEventValueLocation;
#import <PryvApiKit/PryvApiKit.h>

@interface PYEventPosition : PYEvent

@property (nonatomic, retain) PYEventValueLocation *positionValue;

@end
