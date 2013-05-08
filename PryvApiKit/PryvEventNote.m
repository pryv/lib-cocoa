//
//  PYEventNote.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/2/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEventNote.h"
#import "PryvEventType.h"
#import "PryvEventValueWebclip.h"

@implementation PryvEventNote

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

- (id)initWithType:(PryvEventType *)eventType
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
        self.eventDescription = description;
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

//- (id)initWithModifiedType:(PYEventType *)eventType
//                 noteValue:(id)noteValue
//                  folderId:(NSString *)folderId
//                      tags:(NSArray *)tags
//               description:(NSString *)description
//                clientData:(NSDictionary *)clientData
//{
//    self = [self initWithType:eventType
//                    noteValue:noteValue
//                     folderId:folderId
//                         tags:tags
//                  description:description
//                   clientData:clientData];
//    
//    if (self) {
//        
//    }
//    
//    return self;
//    
//}

- (NSDictionary *)dictionary {
    
    NSMutableDictionary *dic = (NSMutableDictionary *)[super dictionary];
    if (_htmlValue && _htmlValue.length > 0) {
        [dic setObject:_htmlValue forKey:@"value"];
    }
    if (_txtValue && _txtValue > 0) {
        [dic setObject:_txtValue forKey:@"value"];
    }
    
    return dic;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    
    [description appendFormat:@", self.htmlValue=%@", self.htmlValue];
    [description appendFormat:@", self.txtValue=%@", self.txtValue];
    [description appendFormat:@", self.webclipValue=%@", self.webclipValue];
    [description appendString:@">"];
    
    return description;
}



@end
