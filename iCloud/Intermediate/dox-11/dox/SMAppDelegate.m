//
//  SMAppDelegate.m
//  dox
//
//  Created by Cesare Rocchi on 9/30/12.
//  Copyright (c) 2012 Cesare Rocchi. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMMasterViewController.h"

@implementation SMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        SMMasterViewController *controller = (SMMasterViewController *)masterNavigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
    } else {
    
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        SMMasterViewController *controller = (SMMasterViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;

        
    }
    
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (currentToken) {
        
        NSLog(@"iCloud access on with id %@", currentToken);
        
    } else {
        
        NSLog(@"No iCloud access");
        
    }
    
    return YES;
    
}



//
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"doxModel"
                                              withExtension:@"momd"];
    
    _managedObjectModel = [[NSManagedObjectModel alloc]
                            initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

//
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                    initWithManagedObjectModel: [self managedObjectModel]];
    
    NSPersistentStoreCoordinator* psc = _persistentStoreCoordinator;
	NSString *storePath = [[self applicationDocumentsDirectory]
                           stringByAppendingPathComponent:@"dox.sqlite"];
    
    // done asynchronously since it may take a while
	// to download preexisting iCloud content
    dispatch_async(dispatch_get_global_queue(
                                             DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        
        
        // building the path to store transaction logs
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *transactionLogsURL = [fileManager
                                     URLForUbiquityContainerIdentifier:nil];
        NSString* coreDataCloudContent = [[transactionLogsURL path]
                                          stringByAppendingPathComponent:@"dox_data"];
        transactionLogsURL = [NSURL fileURLWithPath:coreDataCloudContent];
        
        //  Building the options array for the coordinator
        NSDictionary* options = [NSDictionary
                                 dictionaryWithObjectsAndKeys:
                                 @"com.studiomagnolia.coredata.notes",
                                 NSPersistentStoreUbiquitousContentNameKey,
                                 transactionLogsURL,
                                 NSPersistentStoreUbiquitousContentURLKey,
                                 [NSNumber numberWithBool:YES],
                                 NSMigratePersistentStoresAutomaticallyOption,
                                 nil];
        
        
        NSError *error = nil;
        
        [psc lock];
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeUrl
                                     options:options
                                       error:&error]) {
            
            NSLog(@"Core data error %@, %@", error, [error userInfo]);

	    }
        
        [psc unlock];
        
        // post a notification to tell the main thread
	    // to refresh the user interface
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"persistent store added correctly");
            [[NSNotificationCenter defaultCenter] 
             postNotificationName:@"com.studiomagnolia.refetchNotes" 
             object:self 
             userInfo:nil];
        });
    });
    
    return _persistentStoreCoordinator;

}

//
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        
        return _managedObjectContext;
        
    }
    
    NSPersistentStoreCoordinator *coordinator =
    [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        // choose a concurrency type for the context
        NSManagedObjectContext* moc =
        [[NSManagedObjectContext alloc]
         initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            // configure context properties
            [moc setPersistentStoreCoordinator: coordinator];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(mergeChangesFrom_iCloud:)
             name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
             object:coordinator];
            
        }];
        _managedObjectContext = moc;
    }
    
    return _managedObjectContext;
    
}

//
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    [moc performBlock:^{
        [self mergeiCloudChanges:notification
                      forContext:moc];
    }];
    
}

//
- (void)mergeiCloudChanges:(NSNotification*)note
                forContext:(NSManagedObjectContext*)moc {
    
    [moc mergeChangesFromContextDidSaveNotification:note];
    //Refresh view with no fetch controller if any
    
} 

//
- (void)saveContext {
    
    NSError *error = nil;
    
    if ([self.managedObjectContext hasChanges] &&
        ![self.managedObjectContext save:&error])
    {
        NSLog(@"Core Data error %@, %@", error, [error userInfo]);

    }
}

//
- (NSString *)applicationDocumentsDirectory {
    
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                NSUserDomainMask, YES) lastObject];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

//
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self saveContext];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

@end
