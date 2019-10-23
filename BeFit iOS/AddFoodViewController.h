//
//  AddFoodViewController.h
//  BeFit iOS
//
//  Created by Satinder Singh on 2/15/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DeviceViewController.h"
#import "ScannerViewController.h"
#import "FoodObjectsViewController.h"

@class Food;
@class FoodList;

@interface AddFoodViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource,ScannedDataDelegate>
{
    NSArray* foodListArray ;
    FoodList* selectedFoodList ;
    NSMutableArray* selectedListArray ;

}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtServingDescription1;
@property (weak, nonatomic) IBOutlet UITextField *txtServingDescription2;
@property (weak, nonatomic) IBOutlet UITextField *txtServWeight1;
@property (weak, nonatomic) IBOutlet UITextField *txtServWeight2;
@property (weak, nonatomic) IBOutlet UITextField *txtQuantity;
@property (weak, nonatomic) IBOutlet UITextField *txtCalories;
@property (weak, nonatomic) IBOutlet UITextField *txtProteins;
@property (weak, nonatomic) IBOutlet UITextField *txtCalcium;
@property (weak, nonatomic) IBOutlet UITextField *txtIron;
@property (weak, nonatomic) IBOutlet UITextField *txtPolyFat;
@property (weak, nonatomic) IBOutlet UITextField *txtSaturatedFat;
@property (weak, nonatomic) IBOutlet UITextField *txtCholesterol;
@property (weak, nonatomic) IBOutlet UITextField *txtSelectedServing;
@property (weak, nonatomic) IBOutlet UITextField *txtVitaminA;
@property (weak, nonatomic) IBOutlet UITextField *txtVitaminC;
@property (weak, nonatomic) IBOutlet UITextField *txtVitaminE;
@property (weak, nonatomic) IBOutlet UITextField *txtDietaryFiber;
@property (weak, nonatomic) IBOutlet UITextField *txtSugar;
@property (weak, nonatomic) IBOutlet UITextField *txtSodium;
@property (weak, nonatomic) IBOutlet UITextField *txtMonoSaturatedFat;
@property (weak, nonatomic) IBOutlet UITextField *txtChooseFoodList;
@property (weak, nonatomic) IBOutlet UITextField *txtCarbohydrates;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnAddFoodList;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnScan;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (nonatomic, strong) Food *foodListObject;
@property (nonatomic,strong) NSMutableDictionary* scannedObject ;
@property ( nonatomic) BOOL isForEditing;

- (IBAction)AddButtonTapped:(id)sender;
- (IBAction)AddFoodList:(id)sender;
@end
