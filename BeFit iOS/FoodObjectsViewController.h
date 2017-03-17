//
//  FoodObjectsViewController.h
//  BeFit iOS
//
//  Created by Satinder Singh on 2/17/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"
#import "FoodList.h"
#import "AddFoodViewController.h"

@interface FoodObjectsViewController : UITableViewController
{
    NSSet *items ;
    NSMutableArray *foodObjectArray;
    BOOL isForEditing ;
    NSIndexPath* selectedIndexPath ;
}
@property (nonatomic, strong) NSManagedObject *foodListObject;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAdd;
- (IBAction)AddNewFood:(id)sender;

@end
