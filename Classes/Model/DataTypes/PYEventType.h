//
//  PYEventType.h
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

@class PYEventClass;

#import <Foundation/Foundation.h>

@interface PYEventType : NSObject
{
    PYEventClass *_klass;
    NSString *_formatKey;
    NSDictionary *_definition;
    NSDictionary *_extras;
}

- (id)initWithClass:(PYEventClass*)klass
          andFormatKey:(NSString*)formatKey
andDefinitionDictionary:(NSDictionary*)dictionary;

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras;

@property (nonatomic, strong) PYEventClass *klass;
@property (nonatomic, copy) NSString *formatKey;
@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic, strong) NSDictionary *extras;


- (NSString *)classKey;

- (NSString *)key;
- (NSString *)type;
- (BOOL)isNumerical;
- (NSString *)symbol;
- (NSString *)localizedName;

@end
