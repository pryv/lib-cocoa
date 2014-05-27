//
//  PYLocalStorage.m
//  Pods
//
//  Created by Perki on 26.05.14.
//
//

#import "PYLocalStorage.h"
#import "PYEvent.h"

@implementation PYLocalStorage


// http://www.cocoanetics.com/2012/07/multi-context-coredata
// http://stackoverflow.com/questions/17613510/parent-moc-get-changes-with-empty-data-from-child-moc
// 

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;


+ (PYEvent*) createTempEvent {
    NSManagedObjectContext* tempManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [tempManagedObjectContext setPersistentStoreCoordinator:[[PYLocalStorage sharedInstance] managedObjectContext].persistentStoreCoordinator];
    return  [NSEntityDescription insertNewObjectForEntityForName:@"PYEvent"
                                          inManagedObjectContext:tempManagedObjectContext];
}

+ (void) save:(NSManagedObject*)object {
    [PYLocalStorage save:object withSuccessCallBack:nil];
}
+ (void) save:(NSManagedObject*)object withSuccessCallBack:(void (^) (BOOL succeded, NSError* error))success {
    NSManagedObjectContext* objectMOC = [object managedObjectContext];
    NSManagedObjectContext* mainMOC = [[PYLocalStorage sharedInstance] managedObjectContext];
    
    // different strategy for temp object
    if (objectMOC != mainMOC) {
       
        [objectMOC performBlock:^{
            // do something that takes some time asynchronously using the temp context
            
            // push to parent
            NSError *error;
            if (![objectMOC save:&error])
            {
                NSLog(@"<ERROR> PYLocalStorage while saving temp object %@", error);
                if (success) { success(NO, error); }
                return;
            }
            
            // save parent to disk asynchronously
            [mainMOC performBlock:^{
                NSError *error;
                if (![mainMOC save:&error])
                {
                    NSLog(@"<ERROR> PYLocalStorage while saving main MOC after temp save %@", error);
                    if (success) { success(NO, error); }
                    return;
                }
                
                if (success) { success(YES, nil); }
                
            }];
        }];
        
    } else { // object is on the main context
        
        [mainMOC performBlock:^{
            NSError *error;
            if (![mainMOC save:&error])
            {
                NSLog(@"<ERROR> PYLocalStorage while saving main MOC %@", error);
                if (success) { success(NO, error); }
                return;
            }
            
            if (success) { success(YES, nil); }
            
        }];
    }
}


#pragma mark - pure core data

static PYLocalStorage* _sharedPYLocalStorage;

+ (PYLocalStorage *) sharedInstance
{
    if (! _sharedPYLocalStorage) {
        _sharedPYLocalStorage = [[PYLocalStorage alloc] init];
    }
    return _sharedPYLocalStorage;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}



// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PYCache" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;

}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PYKit.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        //-- reset store as it's caching only
        
        
        
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    // subscribe to change notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    return _persistentStoreCoordinator;
}

- (void)_mocDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *savedContext = [notification object];
    
    // ignore change notifications for the main MOC
    if (_managedObjectContext == savedContext)
    {
        return;
    }
    
    if (_managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator)
    {
        // that's another database
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}


// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
