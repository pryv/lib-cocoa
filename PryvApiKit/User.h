//
//  User.h
//  AT PrYv
//
//  Created by Nicolas Manzini on 29.12.12.
//  Copyright (c) 2012 PrYv. All rights reserved.
//

/**
 @discussion 
 This Class contain the user infos and the user's preferences for the application

 WARNING saving the userToken and all locations(events) in the database unencrypted
         is not advisable in the production, be responsible in protecting user's data
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userToken;
@property (nonatomic, retain) NSNumber * locationDistanceInterval;
@property (nonatomic, retain) NSNumber * locationTimeInterval;
@property (nonatomic, retain) NSString * folderId;
@property (nonatomic, retain) NSString * folderName;

@end
