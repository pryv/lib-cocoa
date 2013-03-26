//
//  Channel.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PYChannel : NSObject

@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDictionary *clientData;
@property (nonatomic, assign, getter = isEnforceNoEventsOverlap) BOOL enforceNoEventsOverlap;
@property (nonatomic, assign, getter = isTrashed) BOOL trashed;

@end
