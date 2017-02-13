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
    
    [self ParseDatafromBarcode:text];
    
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
