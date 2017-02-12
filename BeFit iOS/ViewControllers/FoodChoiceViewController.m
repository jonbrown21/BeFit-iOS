//
//  FoodChoiceViewController.m
//  BeFit iOS
//
//  Created by Jon on 2/11/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "FoodChoiceViewController.h"

@interface FoodChoiceViewController ()

@end

@implementation FoodChoiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)cancelPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)OpenScanner:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FoodScanner"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
