//
//  PYEventClass.m
//  PryvApiKit
//
//  Created by Perki on 05.12.13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventClass.h"
#import "PYUtilsLocalization.h"

@interface PYEventClass ()
@property (nonatomic, copy) NSString *classDescription;
@end

@implementation PYEventClass

@synthesize classKey = _classKey;
@synthesize extrasName = _extrasName;
@synthesize classDescription = _classDescription;

- (id)initWithClassKey:(NSString*)classKey andDefinitionDictionary:(NSDictionary*)dict {
     self = [super init];
     if(self)
     {
         self.classKey = classKey;
         self.classDescription = [dict objectForKey:@"description"];
         
     }
     return self;
}

- (void)dealloc
{
    [_classKey release];
    [_classDescription release];
    [super dealloc];
}

- (void)addExtrasDefinitionsFromDictionary:(NSDictionary*)extras
{
    self.extrasName = [extras objectForKey:@"name"];
}

- (NSString *)description
{
    return self.classDescription;
}

-(NSString *)localizedName {
    if (self.extrasName) {
        return [PYUtilsLocalization fromDictionary:self.extrasName defaultValue:self.classKey];
    }
    return self.classKey;
}

@end
