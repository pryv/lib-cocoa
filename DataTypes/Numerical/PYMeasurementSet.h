//
//  PYMeasurementSet.h
//  NotesApp
//
//  Created by Mladen Djordjevic on 5/25/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PYMeasurementGroup.h"

@interface PYMeasurementSet : NSObject
{
    NSString *_key;
    NSString *_localizedName;
    NSString *_localizedDescription;
    NSMutableArray *_measurementGroups;
    
    @private
    NSDictionary *_names;
    NSDictionary *_descriptions;
}

- (id)initWithKey:(NSString*)key andDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *localizedDescription;
@property (nonatomic, strong) NSMutableArray *measurementGroups;
//Private variables
@property (nonatomic, copy) NSDictionary *names;
@property (nonatomic, copy) NSDictionary *descriptions;

@end
