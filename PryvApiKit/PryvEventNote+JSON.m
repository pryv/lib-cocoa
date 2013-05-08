//
//  PYEventNote+JSON.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/6/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEventNote+JSON.h"
#import "PryvEvent+JSON.h"
#import "PryvEventType.h"

@implementation PryvEventNote (JSON)

+ (id)noteEventFromDictionary:(NSDictionary *)JSON
{
    PryvEventNote *event = (PryvEventNote *)[self eventFromDictionary:JSON];
    
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
