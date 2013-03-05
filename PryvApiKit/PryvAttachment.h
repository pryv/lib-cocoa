//
//  PryvAttachment.h
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/4/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PryvAttachment : NSObject{
    NSString *_filename;
    NSNumber *_size;
    NSString *_type;
}

@property(nonatomic,retain)NSString *filename;
@property(nonatomic,retain)NSString *type;
@property(nonatomic,retain)NSNumber *size;



@end

