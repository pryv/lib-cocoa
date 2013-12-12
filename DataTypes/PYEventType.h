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
@property (nonatomic, strong) NSString *formatKey;
@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic, strong) NSDictionary *extras;

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *symbol;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL isNumerical;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSString *classKey;



@end
