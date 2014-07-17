//
//  PYEventType.m
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventType.h"
#import "PYEventClass.h"
#import "PYUtilsLocalization.h"


@interface PYEventType ()

@end


@implementation PYEventType

@synthesize klass = _klass;
@synthesize formatKey = _formatKey;
@synthesize definition = _definition;
@synthesize extras = _extras;

- (id)initWithClass:(PYEventClass *)klass andFormatKey:(NSString*)formatKey
                               andDefinitionDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.klass = klass;
        self.formatKey = formatKey;
        self.definition = dictionary;
        
    }
    return self;
}

- (void)dealloc
{
    [_formatKey release];
    [super dealloc];
}

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras
{
    self.extras = extras;
}

-(NSString*) classKey {
    return self.klass.classKey;
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


- (NSString *)description {
    return self.key;
}




@end
