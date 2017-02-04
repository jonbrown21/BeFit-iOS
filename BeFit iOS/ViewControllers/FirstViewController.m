//
//  FirstViewController.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@property (strong, nonatomic) NSArray *genderArray;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.genderArray = @[ @"Male", @"Female"];
    
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, _Age.frame.size.height - borderWidth, _Age.frame.size.width, _Age.frame.size.height);
    border.borderWidth = borderWidth;
    [_Age.layer addSublayer:border];
    _Age.layer.masksToBounds = YES;
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Calculate:(id)sender {
    
    float height;
    float weight;
    float bmi;
    
    height = ([_Hfeet.text doubleValue] * 12) + [_Hinches.text doubleValue];
    weight = [_Weight.text doubleValue];
    bmi = round((weight / (height * height)) * 703);
    
    _Total.text = [NSString stringWithFormat:@"%.0f", bmi];
    
}

- (IBAction)selectAnimalPressed:(id)sender
{
    
    UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SimpleTableVC"];
    PickerTableView *tableViewController = (PickerTableView *)[[navigationController viewControllers] objectAtIndex:0];
    tableViewController.tableData = self.genderArray;
    tableViewController.navigationItem.title = @"Gender";
    tableViewController.delegate = self;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    
    
}

- (void)itemSelectedatRow:(NSInteger)row
{
    
    NSLog(@"row %lu selected", (unsigned long)row);
    [self->GenderButt setTitle:[self.genderArray objectAtIndex:row] forState:UIControlStateNormal];
}

@end
