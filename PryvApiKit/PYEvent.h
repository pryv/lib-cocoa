//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PryvLocation.h"


@interface PYEvent : NSObject

@property (nonatomic, retain) NSString *attachment;
@property (nonatomic, retain) NSDate   *date;
@property (nonatomic, retain) NSString *folderId;

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSNumber *uploaded;

@property (nonatomic, retain) NSMutableArray  *attachmentList;
@property (nonatomic, retain) PryvLocation  *location;
@property (nonatomic, retain) NSString  *duration;
@property (nonatomic, retain) NSString  *eventId;
@property (nonatomic, retain) NSString  *description;
@property (nonatomic, retain) NSString  *modified;


@end
