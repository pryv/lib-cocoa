//
//  PryvType.m
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/5/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


#import "PYEventType.h"

@implementation PYEventType

@synthesize eventClass = _eventClass;
@synthesize eventFormat = _eventFormat;
@synthesize eventClassName = _eventClassName;
@synthesize eventFormatName = _eventFormatName;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithClass:(PYEventClass)theEventClass andFormat:(PYEventFormat)theEventFormat
{
    self = [super init];
    if (self) {
        
        self.eventClass = theEventClass;
        self.eventFormat = theEventFormat;
        
        switch (theEventClass) {
            case PYEventClassNote:
                _eventClassName = @"note";
                break;
            case PYEventClassPosition:
                _eventClassName = @"position";
                break;
                
            default:
                break;
        }
        
        switch (theEventFormat) {
            case PYEventFormatHTML:
                _eventFormatName = @"html";
                break;
            case PYEventFormatTxt:
                _eventFormatName = @"txt";
                break;
            case PYEventFormatWebClip:
                _eventFormatName = @"webclip";
                break;
            case PYEventFormatLocation:
                _eventFormatName = @"wgs84";
                break;
                
            default:
                break;
        }

    }
    
    return self;
}

+ (PYEventType *)eventTypeFromDictionary:(NSDictionary *)JSON
{
    PYEventType *pet = [[PYEventType alloc] init];
    pet.eventClassName = [JSON objectForKey:@"class"];
    pet.eventFormatName = [JSON objectForKey:@"format"];
    return [pet autorelease];
}
@end
