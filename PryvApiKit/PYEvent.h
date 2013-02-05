//
//  Event
//  AT PrYv
//
//  Created by Konstantin Dorodov on 1/10/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PYEvent : NSObject {
@private
    NSString *_attachment;
    NSDate   *_date;
    NSString *_folderId;
    NSNumber *_latitude;
    NSNumber *_longitude;
    NSString *_message;
    NSNumber *_uploaded;
    NSArray  *_attachmentList;
}

@property (nonatomic, retain) NSString *attachment;
@property (nonatomic, retain) NSDate   *date;
@property (nonatomic, retain) NSString *folderId;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSNumber *uploaded;

@property (nonatomic, retain) NSArray  *attachmentList;

@end
