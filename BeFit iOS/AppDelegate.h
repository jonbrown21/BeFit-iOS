//
//  AppDelegate.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//
//com.jonbrown.org.BeFit-iOS
//com.befitdev

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ProgressHUD.h"

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]
#define API_Key "46ed6b62ac0d3c08c949c6ef20a9cb93"
#define API_URL "https://api.nutritionix.com/v1_1/item?upc=%@&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93"
#define APP_ID "ac7e3b7b"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UITabBarController *tabBarController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

+(void)ShowLoader;
+(void)ShowLoaderForPurchase;
+(void)HideLoader;
+(NSArray*)CheckForDuplicateFoodItem:(NSString*)foodName;
+(NSArray*)CheckForDuplicateFoodList:(NSString*)foodlist;
+(NSArray*)GetUserFoodLibrary;
+(NSArray*)GetfoodListItems;
+(void)setCornerRadiusofUIButton:(UIView*)btn;
@end

