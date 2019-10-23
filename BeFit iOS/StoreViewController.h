//
//  StoreViewController.h
//  BeFit iOS
//
//  Created by Satinder Singh on 2/17/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AvePurchaseButton.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"

@class Food;

#define productID1 @"com.befit.dev.food"
#define productID2 @"food_0171"
#define productIDLive @"com.befit.food.database"
@interface StoreViewController : UITableViewController <SKPaymentTransactionObserver, SKProductsRequestDelegate>

{
    SKProductsRequest* productsRequest;
    NSArray* validProducts ;
}

@property (strong, nonatomic) SKProduct *product;
@end
