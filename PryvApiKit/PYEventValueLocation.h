//
//  PYEventValueLocation.h
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/1/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PYEventValueLocation : NSObject
{
    float _latitude;
    float _longitude;
    float _altitude;
    int _horizontalAccuracy;
    int _verticalAccuracy;
    int _speed;
    int _bearing;
    
}

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic) float altitude;
@property (nonatomic) int horizontalAccuracy;
@property (nonatomic) int verticalAccuracy;
@property (nonatomic) int speed;
@property (nonatomic) int bearing;

+ (PYEventValueLocation *)locatinFromDictionary:(NSDictionary *)JSON;

@end
