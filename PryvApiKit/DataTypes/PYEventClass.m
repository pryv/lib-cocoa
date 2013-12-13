//
//  PYEventClass.m
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventClass.h"
#import "PYUtilsLocalization.h"

@implementation PYEventClass

@synthesize classKey = _classKey;
@synthesize extrasName = _extrasName;
@synthesize description = _description;

- (id)initWithClassKey:(NSString*)classKey andDefinitionDictionary:(NSDictionary*)dict {
     self = [super init];
     if(self)
     {
         self.classKey = classKey;
         self.description = [dict objectForKey:@"description"];
         
     }
     return self;
}

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras
{
    self.extrasName = [extras objectForKey:@"name"];
}

-(NSString*) localizedName {
    if (self.extrasName) {
        return [PYUtilsLocalization fromDictionary:self.extrasName defaultValue:self.classKey];
    }
    return self.classKey;
}

@end
