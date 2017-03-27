//
//  AppDelegate.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "AppDelegate.h"
#import "Food.h"
#import "FoodList.h"
#import "StoreViewController.h"
#import "iRate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    
    [iRate sharedInstance].remindPeriod = 0;
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    [iRate sharedInstance].promptAtLaunch = YES;
    [iRate sharedInstance].previewMode = NO;
}


// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}


- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
    NSLog(@"Push notification accepted");
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // set custom delegate for push handling, in our case AppDelegate
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    
    // set default Pushwoosh delegate for iOS10 foreground push handling
    [UNUserNotificationCenter currentNotificationCenter].delegate = [PushNotificationManager pushManager].notificationCenterDelegate;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // track application open statistics
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    
    
    // Override point for customization after application launch.
    UINavigationController *moreController = _tabBarController.moreNavigationController;
    moreController.navigationBar.barTintColor = [UIColor orangeColor];
    moreController.navigationBar.translucent = NO;
    moreController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.jonbrown.org.BeFit_iOS" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BeFit_DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BeFit_iOS.sqlite"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BeFit_iOS" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
           // NSLog(@"Oops, could copy preloaded data");
        }
    }
    
    
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
       // NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


//- (void) copyDatabaseIfNeeded {
//    
//    //Using NSFileManager we can perform many file system operations.
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error;
//    
//    NSString *dbPath = [self getDBPath];
//    BOOL success = [fileManager fileExistsAtPath:dbPath];
//    
////    if(!success) {
//    
//        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BeFit2.sqlite"];
//        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
//        
//        if (!success)
//            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
////    }
//}
//
//- (NSString *) getDBPath
//{
//    //Search for standard documents using NSSearchPathForDirectoriesInDomains
//    //First Param = Searching the documents directory
//    //Second Param = Searching the Users directory and not the System
//    //Expand any tildes and identify home directories.
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
//    NSString *documentsDir = [paths objectAtIndex:0];
//    //NSLog(@"dbpath : %@",documentsDir);
//    return [documentsDir stringByAppendingPathComponent:@"BeFit_iOS.sqlite"];
//}

+(void)ShowLoader
{
    [ProgressHUD show:@"Loading..."];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
}
+(void)ShowLoaderForPurchase
{
    
    [ProgressHUD show:@"Updating database..."];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
}
+(void)HideLoader
{
    
    [ProgressHUD dismiss];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}


+(NSArray*)CheckForDuplicateFoodItem:(NSString*)foodName
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"FoodObject" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@",foodName];
    [request setPredicate:predicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}
+(NSArray*)GetfoodListItems
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"FoodListObject" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != 'Food Library'"];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name != 'User Food Library'"];
    NSArray* arrayOfPred = [[NSArray alloc ] initWithObjects:predicate,predicate1,nil ];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayOfPred];
    
    
    [request setPredicate:compoundPredicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}

+(NSArray*)CheckForDuplicateFoodList:(NSString*)foodlist
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"FoodListObject" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@",foodlist];
    [request setPredicate:predicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}



+(NSArray*)GetUserFoodLibrary
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"FoodListObject" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] 'User Food Library'"];
    
    [request setPredicate:predicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}

+(void)setCornerRadiusofUIButton:(UIView*)btn
{
    CALayer *layer = [btn layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:8.0];
    [btn setTintColor:[ UIColor blackColor]];
    
}


@end
