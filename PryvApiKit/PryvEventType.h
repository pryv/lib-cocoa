//
//  PryvType.h
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/5/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//
typedef enum {
    PYEventFormatLocation = 1,
    PYEventFormatHTML,
    PYEventFormatTxt,
    PYEventFormatWebClip
} PYEventFormat;

typedef enum {
    PYEventClassNote = 1,
    PYEventClassPosition
} PYEventClass;



#import <Foundation/Foundation.h>

@interface PryvEventType : NSObject
{
    PYEventClass _eventClass;
    PYEventFormat _eventFormat;
    NSString *_eventClassName;
    NSString *_eventFormatName;
    
}

@property (nonatomic) PYEventClass eventClass;
@property (nonatomic) PYEventFormat eventFormat;
@property (nonatomic, retain) NSString *eventClassName;
@property (nonatomic, retain) NSString *eventFormatName;

- (id)initWithClass:(PYEventClass)theEventClass andFormat:(PYEventFormat)theEventFormat;
+ (PryvEventType *)eventTypeFromDictionary:(NSDictionary *)JSON;

@end
