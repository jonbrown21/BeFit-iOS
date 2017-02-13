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
    
    igViewController *notifyingInstance = [[igViewController alloc] init];
    [notifyingInstance setDelegate:self];
    
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
    
    [self performSegueWithIdentifier:@"foodScan" sender:self];
    
//    
//    igViewController *vcNotes =  [self.storyboard instantiateViewControllerWithIdentifier:@"foodScan"];
//    vcNotes.delegate = self;
//    [self presentViewController:vcNotes animated:YES completion:nil];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"foodScan"]) {
        
        igViewController *destinationVC = segue.destinationViewController;
        destinationVC.delegate = self;

    }
    if ([segue.identifier isEqualToString:@"addfood"]) {
        
        AddFoodViewController *destinationVC = segue.destinationViewController;
        destinationVC.lblTitle = self.labelView.text;

    }
    
}

- (void)secondViewController:(igViewController *)secondViewController didEnterText:(NSString *)text
{
    _labelView.text = text;
    
}



- (IBAction)OpenFoodPanel:(id)sender {
    
    
    [self performSegueWithIdentifier:@"addfood" sender:self];
    
    
}
@end
