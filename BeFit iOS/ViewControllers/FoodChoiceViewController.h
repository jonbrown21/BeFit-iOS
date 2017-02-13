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

@end
