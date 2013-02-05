//
//  Channel.h
//  AT PrYv
//
//  Created by Manuel Spuhler on 11/01/2013.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PYChannel : NSObject {
@private
    NSString *_channelId;
    NSNumber *_enforceNoEventsOverlap;
    NSNumber *_trashed;
    NSString *_name;
}


@property (nonatomic, retain) NSString *channelId;
@property (nonatomic, retain) NSNumber *enforceNoEventsOverlap;
@property (nonatomic, retain) NSNumber *trashed;
@property (nonatomic, retain) NSString *name;

+ (id)channelWithDictionary:(NSDictionary *)dictionary;

@end
