//
//  DetailViewController.m
//  BeFit iOS
//
//  Created by Jon on 9/25/16.
//  Copyright © 2016 Jon Brown. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
@synthesize lablView, selectedlabel;



- (void)viewDidLoad {
    [super viewDidLoad];
    

        [self.lablView setText:selectedlabel];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{

    self.lablView.text = self.selectedlabel;
    
    [lablView setText:selectedlabel];
    
    
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
