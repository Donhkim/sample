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
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory]
                       URLByAppendingPathComponent:@"dox.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                    initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:
          NSSQLiteStoreType configuration:nil URL:storeURL options:nil
                                                            error:&error])
    {
        
        NSLog(@"Core Data error %@, %@", error, [error userInfo]);

    }
    
    return _persistentStoreCoordinator;
}

//
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self
                                                 persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:
         coordinator];
    }
    
    return _managedObjectContext;
    
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
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:
             NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
