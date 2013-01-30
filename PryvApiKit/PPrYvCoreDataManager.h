//
//  Created by Konstantin Dorodov on 1/7/13.
//  Copyright (c) 2012 PrYv. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PPrYvCoreDataManager : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (PPrYvCoreDataManager *)sharedInstance;
- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;

- (NSManagedObjectContext *)scratchManagedObjectContext;

@end