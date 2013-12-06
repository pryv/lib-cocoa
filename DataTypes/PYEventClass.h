//
//  PYEventClass.h
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventClass : NSObject

- (id)initWithClassKey:(NSString*)classKey;


@property (nonatomic, readonly) NSArray *eventTypes;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *localizedDescription;

@end
