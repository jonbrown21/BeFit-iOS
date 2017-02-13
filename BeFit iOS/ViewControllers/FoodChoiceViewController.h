//
//  FoodChoiceViewController.h
//  BeFit iOS
//
//  Created by Jon on 2/11/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "igViewController.h"
#import "AddFoodViewController.h"

@interface FoodChoiceViewController : UIViewController <igViewControllerDelegate>

- (IBAction)OpenFoodPanel:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *labelView;
@property (strong, nonatomic) IBOutlet UIView *manualButt;
@property (weak, nonatomic) IBOutlet UITextField *FoodName;
@property (weak, nonatomic) IBOutlet UITextField *Barcode;
@property (weak, nonatomic) IBOutlet UITextField *Calories;
@property (weak, nonatomic) IBOutlet UITextField *TotalFat;
@property (weak, nonatomic) IBOutlet UITextField *SatFat;
@property (weak, nonatomic) IBOutlet UITextField *PolyFat;
@property (weak, nonatomic) IBOutlet UITextField *MonoFat;
@property (weak, nonatomic) IBOutlet UITextField *calfromfat;
@property (weak, nonatomic) IBOutlet UITextField *Cholesterol;
@property (weak, nonatomic) IBOutlet UITextField *Sodium;
@property (weak, nonatomic) IBOutlet UITextField *Fiber;
@property (weak, nonatomic) IBOutlet UITextField *Sugars;
@property (weak, nonatomic) IBOutlet UITextField *Protien;
@property (weak, nonatomic) IBOutlet UITextField *Carbs;
@property (weak, nonatomic) IBOutlet UITextField *Calcium;
@property (weak, nonatomic) IBOutlet UITextField *Iron;
@property (weak, nonatomic) IBOutlet UITextField *VitA;
@property (weak, nonatomic) IBOutlet UITextField *VitC;
@property (weak, nonatomic) IBOutlet UITextField *VitE;
@property (weak, nonatomic) IBOutlet UITextField *TransFat;

@end
