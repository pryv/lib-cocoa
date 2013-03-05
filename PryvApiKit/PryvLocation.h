//
//  PryvLocation.h
//  PryvApiKit
//
//  Created by Dalibor Stanojevic on 3/4/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PryvLocation : NSObject
{
    NSNumber *_longitude;
    
    NSNumber *_latitude;
}


@property(nonatomic,retain) NSNumber *longitude;

@property(nonatomic,retain) NSNumber *latitude;


@end


