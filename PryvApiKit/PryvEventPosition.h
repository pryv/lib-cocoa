//
//  PYEventPosition.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
@class PryvEventValueLocation;
#import <PryvApiKit/PryvApiKit.h>

@interface PryvEventPosition : PryvEvent
{
    PryvEventValueLocation *_positionValue;
}

@property (nonatomic, retain) PryvEventValueLocation *positionValue;

@end
