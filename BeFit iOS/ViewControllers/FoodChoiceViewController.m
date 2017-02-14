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
    
    UIColor *buttColor = [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
    UIColor *greyColor = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    UIColor *redcolor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
    
    [[UITextField appearance] setTintColor:greyColor];
    
    [ self makeButton:_ScanButt color:redcolor ];
    [ self makeButton:_AddFood color:buttColor ];
    
    [ self showKeyboard:_FoodName ];
    [ self showKeyboard:_Barcode ];
    [ self showKeyboard:_Calcium ];
    [ self showKeyboard:_Calories ];
    [ self showKeyboard:_TotalFat ];
    [ self showKeyboard:_SatFat ];
    [ self showKeyboard:_MonoFat ];
    [ self showKeyboard:_PolyFat ];
    [ self showKeyboard:_calfromfat ];
    [ self showKeyboard:_Cholesterol ];
    [ self showKeyboard:_Sodium ];
    [ self showKeyboard:_Fiber ];
    [ self showKeyboard:_Sugars ];
    [ self showKeyboard:_Protien ];
    [ self showKeyboard:_Carbs ];
    [ self showKeyboard:_Iron ];
    [ self showKeyboard:_VitC ];
    [ self showKeyboard:_VitA ];
    [ self showKeyboard:_VitE ];
    [ self showKeyboard:_TransFat ];
    
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

-(void)doneWithNumberPad{
    // NSString *numberFromTheKeyboard = HumanAge.text;
    [_FoodName resignFirstResponder];
    [_Barcode resignFirstResponder];
    [_Calcium resignFirstResponder];
    [_Calories resignFirstResponder];
    [_TotalFat resignFirstResponder];
    [_SatFat resignFirstResponder];
    [_MonoFat resignFirstResponder];
    [_PolyFat resignFirstResponder];
    [_calfromfat resignFirstResponder];
    [_Cholesterol resignFirstResponder];
    [_Sodium resignFirstResponder];
    [_Fiber resignFirstResponder];
    [_Sugars resignFirstResponder];
    [_Protien resignFirstResponder];
    [_Carbs resignFirstResponder];
    [_Iron resignFirstResponder];
    [_VitC resignFirstResponder];
    [_VitA resignFirstResponder];
    [_VitE resignFirstResponder];
    [_TransFat resignFirstResponder];
    
}

-(void)showKeyboard: (UITextField*)key
{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    
    
    
    key.inputAccessoryView = numberToolbar;
    
    
}

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
        destinationVC.lblTitle = self.Barcode.text;

    }
    
}

- (void)secondViewController:(igViewController *)secondViewController didEnterText:(NSString *)text
{
    [self ParseDatafromBarcode:text];
    
}

-(void)makeButton: (UIButton*)butz color: (UIColor*)colortouse
{
    CALayer * layer = [butz layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:4.0]; //when radius is 0, the border is a rectangle
    [layer setBorderWidth:1.0];
    [layer setBorderColor:[colortouse CGColor]];
    butz.backgroundColor = colortouse;
}

- (void)ParseDatafromBarcode:(NSString *)barcode
{
    
    NSString *url_string = [[NSString alloc ]initWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=%@&appId=052b363f&appKey=510bfa9d1624d4264cb7fadf42bed4e8",barcode];

    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSDictionary *Calories = [json objectForKey:@"nf_calories"];
    NSDictionary *FoodName = [json objectForKey:@"item_name"];
    NSDictionary *TotalFat = [json objectForKey:@"nf_total_fat"];
    NSDictionary *SatFat = [json objectForKey:@"nf_saturated_fat"];
    NSDictionary *CalsfromFat = [json objectForKey:@"nf_calories_from_fat"];
    NSDictionary *Chols = [json objectForKey:@"nf_cholesterol"];
    NSDictionary *Sod = [json objectForKey:@"nf_sodium"];
    NSDictionary *Fib = [json objectForKey:@"nf_dietary_fiber"];
    NSDictionary *Sug = [json objectForKey:@"nf_sugars"];
    NSDictionary *Prot = [json objectForKey:@"nf_protein"];
    NSDictionary *Carb = [json objectForKey:@"nf_total_carbohydrate"];
    NSDictionary *Calc = [json objectForKey:@"nf_calcium_dv"];
    NSDictionary *Iorn = [json objectForKey:@"nf_iron_dv"];
    NSDictionary *A = [json objectForKey:@"nf_vitamin_a_dv"];
    NSDictionary *C = [json objectForKey:@"nf_vitamin_c_dv"];
    
    _FoodName.text = [NSString stringWithFormat:@"%@", FoodName];
    _Calories.text = [NSString stringWithFormat:@"%@", Calories];
    _Barcode.text = barcode;
    _TotalFat.text = [NSString stringWithFormat:@"%@", TotalFat];
    _SatFat.text = [NSString stringWithFormat:@"%@", SatFat];
    _calfromfat.text = [NSString stringWithFormat:@"%@", CalsfromFat];
    _Cholesterol.text = [NSString stringWithFormat:@"%@", Chols];
    _Sodium.text = [NSString stringWithFormat:@"%@", Sod];
    _Fiber.text = [NSString stringWithFormat:@"%@", Fib];
    _Sugars.text = [NSString stringWithFormat:@"%@", Sug];
    _Protien.text = [NSString stringWithFormat:@"%@", Prot];
    _Carbs.text = [NSString stringWithFormat:@"%@", Carb];
    _Calcium.text = [NSString stringWithFormat:@"%@", Calc];
    _Iron.text = [NSString stringWithFormat:@"%@", Iorn];
    _VitA.text = [NSString stringWithFormat:@"%@", A];
    _VitC.text = [NSString stringWithFormat:@"%@", C];
}

- (IBAction)OpenFoodPanel:(id)sender {
    
    
    [self performSegueWithIdentifier:@"addfood" sender:self];
    
    
}
@end
