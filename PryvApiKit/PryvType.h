//
//  PryvType.h
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/5/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PryvType : NSObject{
    NSString *_class;
    NSString *_format;
}

@property(nonatomic,retain) NSString *clazz;
@property(nonatomic,retain) NSString *format;

@end
