//
//  FirstViewController.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerTableView.h"
#import "LifestyleTableView.h"
#import "GoalTableView.h"
#import "ProgressHUD.h"

@interface FirstViewController : UIViewController <GenderPickerControllerDelegate, LifePickerControllerDelegate, GoalPickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIBarPositioningDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *Age;
@property (weak, nonatomic) IBOutlet UITextField *Weight;
@property (weak, nonatomic) IBOutlet UITextField *Hfeet;
@property (weak, nonatomic) IBOutlet UITextField *Hinches;
@property (weak, nonatomic) IBOutlet UILabel *Total;
@property (weak, nonatomic) IBOutlet UITextField *Gender;
@property(nonatomic, strong) IBOutlet UISwitch *MetricSwitch;
@property (weak, nonatomic) IBOutlet UILabel *inLab;
@property (weak, nonatomic) IBOutlet UILabel *ftLab;
@property (weak, nonatomic) IBOutlet UITextField *HCM;
@property (weak, nonatomic) IBOutlet UILabel *cmLab;
@property (weak, nonatomic) IBOutlet UILabel *switchLab;
@property (weak, nonatomic) IBOutlet UILabel *lbs;
@property (weak, nonatomic) IBOutlet UITextField *weightMet;
@property (weak, nonatomic) IBOutlet UIButton *CalcButt;
@property (weak, nonatomic) IBOutlet UIButton *ResetButt;
@property (weak, nonatomic) IBOutlet UIButton *GenderButt;
@property (weak, nonatomic) IBOutlet UIButton *LifeButt;
@property (weak, nonatomic) IBOutlet UIButton *GoalButt;
@property (weak, nonatomic) IBOutlet UILabel *Recommended;
@property (weak, nonatomic) IBOutlet UILabel *SliderLab;
@property (weak, nonatomic) IBOutlet UISlider *Slider;
@property (weak, nonatomic) IBOutlet UISwitch *GoalSiwtch;
@property (weak, nonatomic) IBOutlet UILabel *use;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationbar;

@property(nonatomic, strong) UITableViewController *LifeTableVC;
@property(nonatomic, strong) UITableViewController *SimpleTableVC;

- (IBAction)Calculate:(id)sender;
- (IBAction)Reset:(id)sender;

@end

