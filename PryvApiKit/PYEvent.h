//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

@class PryvLocation;
@class PryvEventType;
@class PryvAttachment;

#import <Foundation/Foundation.h>

@interface PryvEvent : NSObject
{
    NSString  *_eventId;
    NSString  *_channelId;
    
    NSTimeInterval _time;
    NSTimeInterval _duration;
    PryvEventType *_type;
    
    NSString *_folderId;
    NSArray *_tags;
    NSString  *_eventDescription;
    NSMutableArray *_attachments;
    NSDictionary *_clientData;
    BOOL _trashed;
    NSDate *_modified;

}


@property (nonatomic, retain) NSString  *eventId;
@property (nonatomic, retain) NSString  *channelId;

@property (nonatomic) NSTimeInterval time;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, retain) PryvEventType *type;

@property (nonatomic, retain) NSString *folderId;
@property (nonatomic, retain) NSArray *tags;
@property (nonatomic, retain) NSString  *eventDescription;

//array of PYEventAttachment objects
@property (nonatomic, retain) NSMutableArray *attachments;
@property (nonatomic, retain) NSDictionary *clientData;
@property (nonatomic) BOOL trashed;
@property (nonatomic, retain) NSDate *modified;

- (void)addAttachment:(PryvAttachment *)attachment;
- (void)removeAttachment:(PryvAttachment *)attachmentToRemove;

+ (id)getEventFromDictionary:(NSDictionary *)JSON;
- (NSDictionary *)dictionary;

@end
