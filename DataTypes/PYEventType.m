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

@end


@implementation PYEventType

@synthesize classKey = _classKey;
@synthesize formatKey = _formatKey;
@synthesize definition = _definition;
@synthesize extras = _extras;
@synthesize key = _key;
@synthesize symbol = _symbol;
@synthesize type = _type;
@synthesize isNumerical = _isNumerical;
@synthesize localizedName = _localizedName;
@synthesize localizedDescription = _localizedDescription;
@synthesize names = _names;
@synthesize descriptions = _descriptions;


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
