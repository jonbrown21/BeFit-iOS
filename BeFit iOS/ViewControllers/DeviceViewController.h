//
//  DeviceViewController.h
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceDetailViewController.h"
#import "FoodObjectsViewController.h"

@interface DeviceViewController : UITableViewController
{
    NSMutableArray* finalDisplayArray ;
    NSArray* sectionNameArray ;
}
- (IBAction)OpenModal:(id)sender;
@property (strong) NSMutableArray *devices;
@property(nonatomic) BOOL isFromAddFoodScreen ;
@property(nonatomic,strong) NSMutableArray* selectedFoodLists ;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@end
