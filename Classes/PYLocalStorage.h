//
//  PYLocalStorage.h
//  Pods
//
//  Created by Perki on 26.05.14.
//
//

#import <CoreData/CoreData.h>

@class PYEvent;

@interface PYLocalStorage : NSObject

#pragma mark - core data



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *tempManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

+ (PYEvent*) createTempEvent;

+ (void) save:(NSManagedObject*)object;
+ (void) save:(NSManagedObject*)object withSuccessCallBack:(void (^) (BOOL succeded, NSError* error))success;

+ (PYLocalStorage*) sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
