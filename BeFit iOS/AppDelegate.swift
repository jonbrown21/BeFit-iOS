//
//  AppDelegate.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import CoreData
import Pushwoosh
import UserNotifications
import StoreKit
import JGProgressHUD

private let API_Key = "46ed6b62ac0d3c08c949c6ef20a9cb93"
private let API_URL = "https://api.nutritionix.com/v1_1/item?upc=%@&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93"
private let APP_ID = "ac7e3b7b"

@UIApplicationMain
class AppDelegate: UIResponder,
UIApplicationDelegate,
PushNotificationDelegate {
    //MARK: - Properties
    
    private let firstStartDateKey = "firstStartDate"
    private let numberOfLaunchesKey = "numberOfLaunches"
    private let secondsUntilRatingPrompt = Constants.secondsPerDay * 5
    private let launchesUntilRatingPrompt = 5
    
    var window: UIWindow?
    
    private var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "BeFit_DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
        
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let storeURL = applicationDocumentsDirectory.appendingPathComponent("BeFit_iOS.sqlite", isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                guard let resource = Bundle.main.path(forResource: "BeFit_iOS", ofType: "sqlite") else {
                    throw CustomError.fileNotFound
                }
                
                let preloadURL = URL(fileURLWithPath: resource, isDirectory: false)
                try FileManager.default.copyItem(at: preloadURL, to: storeURL)
            } catch let error {
                fatalError("Could not copy preloaded data:\n\(error)")
            }
        }
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch let error {
            print("There was an error creating or loading the application's saved data:\n\(error)")
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        return context
    }()
    
    //MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // set custom delegate for push handling, in our case AppDelegate
        PushNotificationManager.push().delegate = self
        
        // set default Pushwoosh delegate for iOS10 foreground push handling
        UNUserNotificationCenter.current().delegate = PushNotificationManager.push().notificationCenterDelegate
        
        // handling push on app start
        PushNotificationManager.push().handlePushReceived(launchOptions)
        
        // track application open statistics
        PushNotificationManager.push().sendAppOpen()
        
        // register for push notifications!
        PushNotificationManager.push().registerForPushNotifications()
        
        // Number of application launches since install
        let numOfLaunches = UserDefaults.standard.integer(forKey: numberOfLaunchesKey) + 1
        UserDefaults.standard.set(numOfLaunches, forKey: numberOfLaunchesKey)
        
        if let firstStartDate = UserDefaults.standard.value(forKey: firstStartDateKey) as? Date {
            if Date().timeIntervalSince(firstStartDate) > secondsUntilRatingPrompt &&
                numOfLaunches >= launchesUntilRatingPrompt {
                // Not guaranteed to show the rating popup, refer to the documentation for details
                // https://developer.apple.com/documentation/storekit/skstorereviewcontroller/2851536-requestreview
                SKStoreReviewController.requestReview()
            }
        } else {
            UserDefaults.standard.set(Date(), forKey: firstStartDateKey)
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        saveContext()
    }
    
    // system push notification registration success callback, delegate to pushManager
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.push().handlePushRegistration(deviceToken)
    }
    
    // system push notification registration error callback, delegate to pushManager
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
    
    // system push notifications callback, delegate to pushManager
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationManager.push().handlePushReceived(userInfo)
        completionHandler(.noData)
    }
    
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!, onStart: Bool) {
        print("Push notification accepted")
    }
    
    //MARK: - Core Data Saving support
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch let error {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            print("Failed saving context:\n\(error)")
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
    
    //MARK: - Static Methods
    
    private static var activeProgressHUD: JGProgressHUD?
    
    static func showLoader(text: String) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard text != activeProgressHUD?.textLabel.text else {
            return
        }
        
        activeProgressHUD?.dismiss(animated: true)
        
        let hud = JGProgressHUD(style: .extraLight)
        hud.textLabel.text = text
        activeProgressHUD = hud
        
        hud.show(in: window)
    }
    
    static func showLoader() {
        showLoader(text: "Loading...")
    }
    
    static func showLoaderForPurchase() {
        showLoader(text: "Updating database...")
    }
    
    static func hideLoader() {
        activeProgressHUD?.dismiss(animated: true)
        activeProgressHUD = nil
        
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    static func check(forDuplicateFoodItem foodName: String) -> [Food] {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext else {
            return []
        }
        
        let request = Food.fetchRequest() as NSFetchRequest<Food>
        request.predicate = NSPredicate(format: "name LIKE[c] %@", foodName)
        
        return (try? context.fetch(request)) ?? []
    }
    
    static func getfoodListItems() -> [FoodList] {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext else {
            return []
        }
        
        let request = FoodList.fetchRequest() as NSFetchRequest<FoodList>
        let predicate = NSPredicate(format: "name != 'Food Library'")
        let predicate1 = NSPredicate(format: "name != 'User Food Library'")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate1])
        
        return (try? context.fetch(request)) ?? []
    }
    
    static func check(forDuplicateFoodList foodlist: String) -> [FoodList] {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext else {
            return []
        }
        
        let request = FoodList.fetchRequest() as NSFetchRequest<FoodList>
        request.predicate = NSPredicate(format: "name LIKE[c] %@", foodlist)
        
        return (try? context.fetch(request)) ?? []
    }
    
    static func getUserFoodLibrary() -> [FoodList] {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext else {
            return []
        }
        
        let request = FoodList.fetchRequest() as NSFetchRequest<FoodList>
        request.predicate = NSPredicate(format: "name LIKE[c] 'User Food Library'")
        
        return (try? context.fetch(request)) ?? []
    }
    
    static func setCornerRadiusofUIButton(_ btn: UIView) {
        let layer = btn.layer
        layer.masksToBounds = true
        layer.cornerRadius = 8
        btn.tintColor = UIColor.black
    }
}
