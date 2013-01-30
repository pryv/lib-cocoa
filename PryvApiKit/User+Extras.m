//
//  Created by Konstantin Dorodov on 1/4/13.
//  Copyright (c) 2013 PrYv. All rights reserved.
//


#import "User+Extras.h"
#import "PPrYvOpenUDID.h"

@implementation User (Extras)

+ (User *)createUserWithId:(NSString *)userIdentifier token:(NSString *)token inContext:(NSManagedObjectContext *)context {

    User * newUser = [User currentUserInContext:context];

    if (newUser == nil) {
        newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    }

    newUser.userId = userIdentifier;
    newUser.userToken = token;
    newUser.locationDistanceInterval = [NSNumber numberWithDouble:30];
    newUser.locationTimeInterval = [NSNumber numberWithDouble:30];
    newUser.folderId = [PPrYvOpenUDID value];
    newUser.folderName = @"userMainFolder";

    return newUser;
}

+ (User *)currentUserInContext:(NSManagedObjectContext *)context {

    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];

    return [[context executeFetchRequest:request error:nil] lastObject];
}


@end