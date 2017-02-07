//
//  DeviceViewController.h
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceDetailViewController.h"

@interface DeviceViewController : UITableViewController
- (IBAction)OpenModal:(id)sender;
@property (strong) NSMutableArray *devices;
@end
