//
//  PYEventNote.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYEventNote.h"
#import "PYEventType.h"
#import "PYEventValueWebclip.h"

@implementation PYEventNote

@synthesize htmlValue = _htmlValue;
@synthesize txtValue = _txtValue;
@synthesize webclipValue = _webclipValue;

- (void)dealloc
{
    [_htmlValue release];
    [_txtValue release];
    [_webclipValue release];
    [super dealloc];
}

- (id)initWithType:(PYEventType *)eventType
         noteValue:(id)noteValue
          folderId:(NSString *)folderId
              tags:(NSArray *)tags
       description:(NSString *)description
        clientData:(NSDictionary *)clientData;

{
    self = [super init];
    if (self) {
        
        self.type = eventType;
        self.folderId = folderId;
        self.tags = tags;
        self.description = description;
        self.clientData = clientData;
        
        switch (eventType.eventFormat) {
            case PYEventFormatWebClip:
                self.webclipValue = noteValue;
                break;
            case PYEventFormatTxt:
                self.txtValue = noteValue;
                break;
            case PYEventFormatHTML:
                self.htmlValue = noteValue;
                break;
            default:
                break;
        }
                
    }
    
    return self;
    
}

- (NSDictionary *)dictionary {
    
    NSMutableDictionary *dic = [[super dictionary] mutableCopy];
    if (_htmlValue) {
        [dic setObject:_htmlValue forKey:@"value"];
    }
    if (_txtValue) {
        [dic setObject:_txtValue forKey:@"value"];
    }
    
    return dic;
}


@end
