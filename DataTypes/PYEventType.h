//
//  PYEventType.h
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventType : NSObject
{
    NSString *_classKey;
    NSString *_formatKey;
    NSDictionary *_definition;
    NSDictionary *_extras;
    
    NSString *_key;
    NSString *_symbol;
    NSString *_type;
    BOOL _isNumerical;
    NSString *_localizedName;
    NSString *_localizedDescription;
}

- (id)initWithClassKey:(NSString*)classKey
          andFormatKey:(NSString*)formatKey
andDefinitionDictionary:(NSDictionary*)dictionary;

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras;

@property (nonatomic, strong) NSString *classKey;
@property (nonatomic, strong) NSString *formatKey;
@property (nonatomic, strong) NSDictionary *definition;
@property (nonatomic, strong) NSDictionary *extras;

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *symbol;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL isNumerical;
@property (nonatomic, readonly) NSString *localizedName;



@end
