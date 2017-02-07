//
//  DeviceDetailViewControllerUIViewController.h
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface DeviceDetailViewController : UIViewController <UIBarPositioningDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationbar;
@property (strong) NSManagedObject *device;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
