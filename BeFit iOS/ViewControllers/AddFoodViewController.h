//
//  AddFoodViewController.h
//  BeFit iOS
//
//  Created by Jon on 2/12/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodChoiceViewController.h"

@interface AddFoodViewController : UIViewController <UIBarPositioningDelegate, UINavigationBarDelegate>
{
    NSString *lblTitle;
}
@property (strong, nonatomic) IBOutlet UIView *AddView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationbar;
@property (weak, nonatomic) IBOutlet UILabel *upclabelView;
@property (nonatomic, retain) NSString *lblTitle;
@property (weak, nonatomic) IBOutlet UIProgressView *ProgView;
@end
