//
//  PYLocalStorage.h
//  Pods
//
//  Created by Perki on 26.05.14.
//
//

#import <CoreData/CoreData.h>



@interface PYLocalStorage : NSObject

#pragma mark - core data



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *tempManagedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;



+ (PYLocalStorage*) sharedInstance;

- (NSManagedObject*) createTempEntityForName:(NSString*)entityName;

- (void) save:(NSManagedObject*)object;
- (void) save:(NSManagedObject*)object withSuccessCallBack:(void (^) (BOOL succeded, NSError* error))success;


- (void) saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
