//
//  DeviceDetailViewControllerUIViewController.m
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "AppDelegate.h"

@interface DeviceDetailViewController ()

@end

@implementation DeviceDetailViewController
@synthesize device;


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.device) {
        // Update existing device
        [self.device setValue:self.nameTextField.text forKey:@"name"];
        
    } else {
        // Create a new managed object
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"FoodListObject" inManagedObjectContext:context];
        [newDevice setValue:self.nameTextField.text forKey:@"name"];

    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationbar.delegate = self;
    
    if (self.device) {
        [self.nameTextField setText:[self.device valueForKey:@"name"]];
    }
    
    // Do any additional setup after loading the view.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
