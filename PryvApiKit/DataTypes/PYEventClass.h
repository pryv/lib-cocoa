//
//  PYEventClass.h
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventClass : NSObject
{
    NSString *_classKey;
    NSString *_description;
    NSDictionary *_extrasName;
}

@property (nonatomic, copy) NSString *classKey;
@property (nonatomic, strong) NSDictionary *extrasName;

- (id)initWithClassKey:(NSString*)classKey andDefinitionDictionary:(NSDictionary*)dict;

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras;

- (NSString *)localizedName;

- (NSString *)description;

@end
