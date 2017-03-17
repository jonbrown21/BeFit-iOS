  //
//  AddFoodViewController.m
//  BeFit iOS
//
//  Created by Satinder Singh on 2/15/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "AddFoodViewController.h"

@interface AddFoodViewController ()

@end

@implementation AddFoodViewController



- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIColor *buttColor = [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
    [ self makeButton:_btnAdd color:buttColor ];
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (_btnAdd.frame.origin.y - _btnAdd.frame.size.height))];
    selectedListArray = [[NSMutableArray alloc] init];
    
    if (_isForEditing && self.foodListObject)
    {
        _btnScan.enabled = FALSE ;
        [_btnScan setTintColor:[UIColor clearColor]];
        [_btnAdd setTitle:@"Update Food" forState:UIControlStateNormal];
        self.title = @"Update Food" ;
        [self SetData];
    }
    else
    {
        [_btnAdd setTitle:@"Add Food" forState:UIControlStateNormal];
        self.title = @"Add Food" ;
    }
   
    
    UIPickerView* picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    _txtChooseFoodList.inputView = picker ;
    
    foodListArray = [AppDelegate GetfoodListItems];
     selectedFoodList = foodListArray[0] ;
    self.scannedObject = [[NSMutableDictionary alloc] init];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
   
}
-(void)SetScannedDataInFields
{
    if (self.scannedObject.count > 0 )
    {
        [self ShowScannedFoodData:self.scannedObject];
    }
    
}
- (IBAction)cancel:(id)sender
{
    [self PopViewController:FALSE];
}

-(void)PopViewController:(BOOL)isFoodAdded
{
    if (!_isForEditing && self.foodListObject)
    {
        if (isFoodAdded)
        {
            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
            
            // [navigationArray removeAllObjects];    // This is just for remove all view controller from navigation stack.
            NSInteger index = 0 ;
            for (int iCount = 0; iCount < navigationArray.count; iCount++)
            {
                UIViewController* controller = [navigationArray objectAtIndex:iCount];
                if ([controller isKindOfClass: [FoodObjectsViewController class]])
                {
                    index = iCount ;
                }
            }
            [navigationArray removeObjectAtIndex:index];
            // You can pass your index here
            self.navigationController.viewControllers = navigationArray;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if (self.foodListObject)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)SetData
{
    _txtName.text = self.foodListObject.name ;
    _txtSugar.text = [NSString stringWithFormat:@"%@",self.foodListObject.sugars]  ;
    _txtSodium.text = [NSString stringWithFormat:@"%@",self.foodListObject.sodium]  ;
    _txtSaturatedFat.text = [NSString stringWithFormat:@"%@",self.foodListObject.saturatedFat]  ;
    _txtDietaryFiber.text = [NSString stringWithFormat:@"%@",self.foodListObject.dietaryFiber]  ;
    _txtMonoSaturatedFat.text = [NSString stringWithFormat:@"%@",self.foodListObject.monosaturatedFat]  ;
    _txtVitaminA.text = [NSString stringWithFormat:@"%@",self.foodListObject.vitaminA]  ;
    _txtCalories.text = [NSString stringWithFormat:@"%@",self.foodListObject.calories]  ;
    _txtServWeight2.text = [NSString stringWithFormat:@"%@",self.foodListObject.servingWeight2]  ;
    _txtVitaminE.text = [NSString stringWithFormat:@"%@",self.foodListObject.vitaminE]  ;
    _txtSelectedServing.text = [NSString stringWithFormat:@"%@",self.foodListObject.selectedServing]  ;
    _txtServingDescription2.text = [NSString stringWithFormat:@"%@",self.foodListObject.servingDescription2]  ;
    _txtCalcium.text = [NSString stringWithFormat:@"%@",self.foodListObject.calcium]  ;
    _txtQuantity.text = [NSString stringWithFormat:@"%@",self.foodListObject.quantity]  ;
    _txtPolyFat.text = [NSString stringWithFormat:@"%@",self.foodListObject.polyFat]  ;
    _txtServWeight1.text = [NSString stringWithFormat:@"%@",self.foodListObject.servingWeight1]  ;
    _txtProteins.text = [NSString stringWithFormat:@"%@",self.foodListObject.protein]  ;
    _txtCholesterol.text = [NSString stringWithFormat:@"%@",self.foodListObject.cholesteral]  ;
    _txtServingDescription1.text = [NSString stringWithFormat:@"%@",self.foodListObject.servingDescription1]  ;
    _txtVitaminC.text = [NSString stringWithFormat:@"%@",self.foodListObject.vitaminC]  ;
    _txtIron.text = [NSString stringWithFormat:@"%@",self.foodListObject.iron]  ;
    _txtCarbohydrates.text = [NSString stringWithFormat:@"%@",self.foodListObject.carbs]  ;
    
//    NSMutableArray* foodArray = [NSMutableArray arrayWithArray:[self.foodListObject.foodListsBelongTo allObjects]];
    
    selectedListArray = [NSMutableArray arrayWithArray:[self.foodListObject.foodListsBelongTo allObjects]];
    
//    if (foodArray.count > 0)
//    {
//        selectedFoodList = foodArray[0];
//        _txtChooseFoodList.text = [NSString stringWithFormat:@"%@",selectedFoodList.name];
//    }
   
    
}


- (void)ShowScannedFoodData:(NSDictionary*)foodData
{
    
    _txtName.text = foodData[@"item_name"] ;
    _txtSugar.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_sugars"] isEqual: [NSNull null]]? [NSNumber numberWithInt:[foodData[@"nf_sugars"] intValue]]: [NSNumber numberWithInteger:0 ]];
     _txtSodium.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_sodium"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_sodium"] intValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtSaturatedFat.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_saturated_fat"] isEqual: [NSNull null]]?[NSNumber numberWithDouble:[foodData[@"nf_saturated_fat"] doubleValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtSelectedServing.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_serving_size_qty"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_size_qty"] intValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtDietaryFiber.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_dietary_fiber"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_dietary_fiber"] intValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtMonoSaturatedFat.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_monounsaturated_fat"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_monounsaturated_fat"] doubleValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtVitaminA.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_vitamin_a_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_a_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtCalories.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_calories"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_calories"] intValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtServWeight2.text = [NSString stringWithFormat:@"%@",![foodData[@""] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@""] intValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtVitaminE.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_vitamin_e_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_e_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtServingDescription2.text = @"" ;// foodData[@""];
    _txtCalcium.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_calcium_dv"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_calcium_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtQuantity.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:0]]  ; // ![foodData[@"nf_serving_size_qty"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_size_qty"] intValue]]:[NSNumber numberWithInteger:0 ];
     _txtPolyFat.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_polyunsaturated_fat"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_polyunsaturated_fat"] doubleValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtServWeight1.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_serving_weight_grams"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_weight_grams"] intValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtProteins.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_protein"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_protein"] intValue]]:[NSNumber numberWithInteger:0 ]] ;
     _txtCholesterol.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_cholesterol"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_cholesterol"] intValue]]:[NSNumber numberWithInteger:0 ]] ;
    _txtServingDescription1.text = [NSString stringWithFormat:@"%@",![foodData[@"item_description"] isEqual: [NSNull null]]?foodData[@"item_description"]:@""];
    _txtVitaminC.text = [NSString stringWithFormat:@"%@", ![foodData[@"nf_vitamin_c_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_c_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ]];
     _txtIron.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_iron_dv"] isEqual: [NSNull null]]?[NSNumber numberWithDouble:[foodData[@"nf_iron_dv"] doubleValue]]: [NSNumber numberWithInteger:0 ]] ;
     _txtCarbohydrates.text = [NSString stringWithFormat:@"%@",![foodData[@"nf_total_carbohydrate"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_total_carbohydrate"] intValue]]:[NSNumber numberWithInteger:0 ]] ;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)ScanButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:@"segue_scan" sender:self];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL)CheckForEmptyTextfield
{
    if (_txtName.text.length == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter food name" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter food name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
//        [alert show];
        return false ;
    }
    else if (_txtSelectedServing.text.intValue == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please fill selected servings" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill selected servings." delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles: nil]show];
        return false ;
    }
    else if (selectedListArray.count == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please choose a food list" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose any food list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//        [alert show];
        return false ;
    }
    return true ;
}



- (IBAction)AddButtonTapped:(id)sender
{
    if (![self CheckForEmptyTextfield])
    {
        return ;
    }
   
    if ([[AppDelegate CheckForDuplicateFoodItem:_txtName.text] count] == 0 || _foodListObject)
    {
        if (_txtSelectedServing.text.intValue > 12)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Selected servings can not be more than 12" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Selected servings can not be more than 12" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            return;
        }
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSString *msg = @"Food added Successfully" ;
        Food* list ;
        if (self.foodListObject && _isForEditing)
        {
            list = _foodListObject ;
            msg = @"Food updated Successfully" ;
        }
        else
        {
            list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodObject" inManagedObjectContext:context];
        }
        
       
        list.name = _txtName.text ;
        list.sugars = [NSNumber numberWithInt:[_txtSugar.text intValue]];
        list.sodium = [NSNumber numberWithInt:[_txtSodium.text intValue]];
        list.saturatedFat = [NSNumber numberWithDouble:[_txtSaturatedFat.text doubleValue]];
        list.selectedServing = [NSNumber numberWithInt:[_txtSelectedServing.text intValue]];
        list.dietaryFiber = [NSNumber numberWithInt:[_txtDietaryFiber.text intValue]];
        list.monosaturatedFat = [NSNumber numberWithDouble:[_txtMonoSaturatedFat.text doubleValue]];
        list.vitaminA = [NSNumber numberWithDouble:[_txtVitaminA.text doubleValue]];
        list.calories = [NSNumber numberWithInt:[_txtCalories.text intValue]];
        list.servingWeight2 = [NSNumber numberWithInt:[_txtServWeight2.text intValue]];
        list.vitaminE = [NSNumber numberWithDouble:[_txtVitaminE.text doubleValue]];
        list.servingDescription2 = _txtServingDescription2.text;
        list.calcium = [NSNumber numberWithDouble:[_txtCalcium.text doubleValue]];
        list.quantity = [NSNumber numberWithInt:[_txtQuantity.text intValue]];
        list.polyFat = [NSNumber numberWithDouble:[_txtPolyFat.text doubleValue]];
        list.servingWeight1 = [NSNumber numberWithInt:[_txtServWeight1.text intValue]];
        list.protein = [NSNumber numberWithInt:[_txtProteins.text intValue]];
        list.cholesteral = [NSNumber numberWithInt:[_txtCholesterol.text intValue]];
        list.servingDescription1 = _txtServingDescription1.text;
        list.vitaminC = [NSNumber numberWithDouble:[_txtVitaminC.text doubleValue]];
        list.iron = [NSNumber numberWithDouble:[_txtIron.text doubleValue]];
        list.carbs = [NSNumber numberWithInt:[_txtCarbohydrates.text intValue]];
        
        FoodList* listObj = [AppDelegate GetUserFoodLibrary][0];
        if (![selectedListArray containsObject:listObj])
        {
            [selectedListArray addObject:listObj];
        }
        NSSet *distinctSet = [NSSet setWithArray:selectedListArray];
        
        list.foodListsBelongTo = distinctSet ;
        
        
        list.userDefined = [NSNumber numberWithBool:YES] ;
        NSError *error;
        if (![context save:&error])
        {
            NSLog(@"errror while saving : %@",error.description);
        }
        else
        {
            [self PopViewController:TRUE];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:msg preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
           // [[[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Food item already exists" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
       // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
    }
    
    
    
   
}

- (IBAction)AddFoodList:(id)sender
{
    [self performSegueWithIdentifier:@"segue_foodList" sender:self];
    
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return foodListArray.count ;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  
    FoodList* list = [foodListArray objectAtIndex:row];
    
    return list.name;
}
- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   selectedFoodList = [foodListArray objectAtIndex:row];
    _txtChooseFoodList.text = selectedFoodList.name ;
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    if ([[segue identifier] isEqualToString:@"segue_foodList"])
    {
        DeviceViewController *destViewController = segue.destinationViewController;
        destViewController.selectedFoodLists = selectedListArray;
        destViewController.isFromAddFoodScreen = TRUE ;
    }
    else if ([[segue identifier] isEqualToString:@"segue_scan"])
    {
        ScannerViewController *destViewController = segue.destinationViewController;
        destViewController.scannedObject = self.scannedObject;
        destViewController.delegate = self ;

    }
    
}

@end
