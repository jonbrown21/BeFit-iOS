//
//  AddFoodViewController.m
//  BeFit iOS
//
//  Created by Jon on 2/12/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "AddFoodViewController.h"

@interface AddFoodViewController ()

@end

@implementation AddFoodViewController
@synthesize upclabelView, lblTitle;

NSTimer *progressTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationbar.delegate = self;
    [upclabelView setText:lblTitle];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [progressTimer fire];
    
    
                            
    // Do any additional setup after loading the view.
}

- (void)updateProgressBar {
    
    
    float newProgress = [self.ProgView progress] + 0.01666; // 1/60
    [self.ProgView setProgress:newProgress animated:YES];
    NSLog(@"%f", newProgress);
    
    if (newProgress > 1.0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [progressTimer invalidate];
    }
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

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
