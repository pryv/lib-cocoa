//
//  PYEventType.m
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventType.h"
#import "PYUtilsLocalization.h"


@interface PYEventType ()

@property (nonatomic, copy) NSDictionary *names;
@property (nonatomic, copy) NSDictionary *descriptions;

@end


@implementation PYEventType


- (id)initWithClassKey:(NSString *)classKey andFormatKey:(NSString*)formatKey
                                 andDefinitionDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.classKey = classKey;
        self.formatKey = formatKey;
        self.definition = dictionary;
        
    }
    return self;
}

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras
{
    self.extras = extras;
}

-(NSString*) key {
    return [NSString stringWithFormat:@"%@/%@",self.classKey,self.formatKey];
}

-(NSString*) type {
    return [self.definition objectForKey:@"type"];
}


-(BOOL) isNumerical {
    return [@"number" isEqualToString:self.type];
}

-(NSString*) symbol {
    if (self.extras) {
        return [self.extras objectForKey:@"symbol"];
    }
    return nil;
}

-(NSString*) localizedName {
    if (self.extras) {
        return [PYUtilsLocalization fromDictionary:[self.extras objectForKey:@"name"] defaultValue:self.formatKey];
    }
    return self.formatKey;
}



@end
