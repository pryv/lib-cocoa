//
//  PYEventValueLocation.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 4/1/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PryvEventValueLocation.h"

@implementation PryvEventValueLocation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize altitude = _altitude;
@synthesize horizontalAccuracy = _horizontalAccuracy;
@synthesize verticalAccuracy = _verticalAccuracy;
@synthesize speed = _speed;
@synthesize bearing = _bearing;

+ (PryvEventValueLocation *)locatinFromDictionary:(NSDictionary *)JSON
{
    PryvEventValueLocation *location = [[PryvEventValueLocation alloc] init];
    location.latitude = [[JSON objectForKey:@"latitude"] floatValue];
    location.longitude = [[JSON objectForKey:@"longitude"] floatValue];
    location.altitude = [[JSON objectForKey:@"altitude"] floatValue];
    location.horizontalAccuracy = [[JSON objectForKey:@"horizontalAccuracy"] intValue];
    location.verticalAccuracy = [[JSON objectForKey:@"verticalAccuracy"] intValue];
    location.speed = [[JSON objectForKey:@"speed"] intValue];
    location.bearing = [[JSON objectForKey:@"bearing"] intValue];
    
    return [location autorelease];
}

@end
