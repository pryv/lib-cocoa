//
//  Channel.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Channel : NSManagedObject

@property (nonatomic, retain) NSString * channelId;
@property (nonatomic, retain) NSNumber * enforceNoEventsOverlap;
@property (nonatomic, retain) NSNumber * trashed;
@property (nonatomic, retain) NSString * name;

@end
