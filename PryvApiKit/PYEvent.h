//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

@class PryvLocation;
@class PYEventType;

#import <Foundation/Foundation.h>

@interface PYEvent : NSObject
{
    NSString  *_eventId;
    NSString  *_channelId;
    
    NSTimeInterval _time;
    NSTimeInterval _duration;
    PYEventType *_type;
    
    NSString *_folderId;
    NSArray *_tags;
    NSString  *_description;
    NSDictionary *_attachments;
    NSDictionary *_clientData;
    BOOL _trashed;
    NSDate *_modified;

}


@property (nonatomic, retain) NSString  *eventId;
@property (nonatomic, retain) NSString  *channelId;

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, retain) PYEventType *type;

/*(any type): Optional. The value associated with the event, if any. Depending on the type, this may be a mathematical value (e.g. mass, money, length, position, etc.), a link to a page, location coordinates, etc
 */
@property (nonatomic, retain) NSString *folderId;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSString  *description;

//dictionary of PYEventAttachment objects
@property (nonatomic, retain) NSDictionary *attachments;
@property (nonatomic, retain) NSDictionary *clientData;
@property (nonatomic) BOOL trashed;
@property (nonatomic, retain) NSDate *modified;

+ (id)eventFromDictionary:(NSDictionary *)JSON;
- (NSDictionary *)dictionary;

@end
