//
//  PYEventNote+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventNote+JSON.h"
#import "PYEvent+JSON.h"
#import "PYEventType.h"

@implementation PYEventNote (JSON)

+ (id)noteEventFromDictionary:(NSDictionary *)JSON
{
    PYEventNote *event = (PYEventNote *)[self eventFromDictionary:JSON];
    
    id noteValue = [JSON objectForKey:@"value"];
    
    switch (event.type.eventFormat) {
        case PYEventFormatWebClip:
            event.webclipValue = noteValue;
            break;
        case PYEventFormatTxt:
            event.txtValue = noteValue;
            break;
        case PYEventFormatHTML:
            event.htmlValue = noteValue;
            break;
        default:
            break;
    }
    
    
    return event;
    
}

@end
