//
//  FirstViewController.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerTableView.h"

@interface FirstViewController : UIViewController <GenderPickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>
{
    IBOutlet UIButton *GenderButt;
}
@property (weak, nonatomic) IBOutlet UITextField *Age;
@property (weak, nonatomic) IBOutlet UITextField *Weight;
@property (weak, nonatomic) IBOutlet UITextField *Hfeet;
@property (weak, nonatomic) IBOutlet UITextField *Hinches;
@property (weak, nonatomic) IBOutlet UILabel *Total;
@property (weak, nonatomic) IBOutlet UITextField *Gender;
@property(nonatomic, strong) UITableViewController *SimpleTableVC;


- (IBAction)Calculate:(id)sender;

@end

