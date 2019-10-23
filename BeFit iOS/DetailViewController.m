//
//  DetailViewController.m
//  BeFit iOS
//
//  Created by Jon on 9/25/16.
//  Copyright © 2016 Jon Brown. All rights reserved.
//

#import "DetailViewController.h"
#import "CW.h"
#import "CBAutoScrollLabel.h"
#import "BeFitTracker-Swift.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *wview;
@property (strong, nonatomic) WKWebView *webview;
@property (strong) CWLineChart* lineChart;
@property (strong) CWBarChart* barChart;
@property (strong) CWPieChart* pieChart;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *navigationBarScrollLabel;

@end

@implementation DetailViewController
@synthesize lablView, selectedlabel, foodData, calView, servingSize, fatView, satfatView, polyfatView, monofatView, fatCals, cholView, sodView, fiberView, calProg, calProgTxt, progColor, sugarView, protView, carbsView, calcView, ironView, transView, vitaView, vitcView, viteView, tfatProg, tfatPerc, calPerc, sfatPerc, sfatProg, calffatProg, pfatPerc, mfatPerc, sodPerc;


- (NSInteger) random:(NSInteger) max {
    return (NSInteger)arc4random_uniform((u_int32_t)max);
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
/* Progress Bars */
- (void) prog:(UIProgressView*) val1 data:(double) val2
{
    
    val1.progress = val2;
    NSLog(@"array: %f", val2);
    
    val1.trackTintColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.1];
    
    if (val2 < 0.40) {
        val1.progressTintColor = [UIColor colorWithRed:0.15 green:0.68 blue:0.38 alpha:1.0];
    } else if (val2 < 0.75) {
        val1.progressTintColor = [UIColor colorWithRed:0.41 green:0.64 blue:0.80 alpha:1.0];
    } else if (val2 <= 1) {
        val1.progressTintColor = [UIColor colorWithRed:0.75 green:0.22 blue:0.17 alpha:1.0];;
    }
    
    
}

- (IBAction)AddFoodButtonTapped:(id)sender
{
    [_txtPicker becomeFirstResponder];
    
}


- (void)addDoughnut {
    
    float cfromfat = [foodData.caloriesStringValue floatValue];
    float cfromfatgr = cfromfat / 100;
    
    float tfat = [foodData.totalFatValue floatValue];
    float tfatgr = tfat / 100;
    
    float sfat = [foodData.saturatedFatValue floatValue];
    float sfatgr = sfat / 100;
    
    float chol = [foodData.cholesterolValue floatValue];
    float cholgr = chol / 100;
    
    NSArray *realValues = [NSArray arrayWithObjects:foodData.caloriesStringValue, foodData.totalFatValue, foodData.saturatedFatValue, foodData.cholesterolValue,  nil];
    
    NSArray *recipePhotos = [NSArray arrayWithObjects:@"Calories", @"Total Fat", @"Saturated Fat", @"Cholesterol",  nil];
    
    NSArray *recipieData = [NSArray arrayWithObjects:@(cfromfatgr).stringValue, @(tfatgr).stringValue, @(sfatgr).stringValue, @(cholgr).stringValue, nil];
    
    NSArray *colorData = [NSArray arrayWithObjects:[CWColors sharedColors].colors[CWCAsbestos], [CWColors sharedColors].colors[CWCEmerald], [CWColors sharedColors].colors[CWCSunFlower], [CWColors sharedColors].colors[CWCPomegrante], [CWColors sharedColors].colors[CWCOrange], [CWColors sharedColors].colors[CWCAmethyst], [CWColors sharedColors].colors[CWCConcrete], nil];
    
    NSMutableArray* data = [NSMutableArray array];
    for( int i = 0; i < [recipieData count]; ++i )
    {
        id object1 = [recipieData objectAtIndex:i];
        id object2 = [recipePhotos objectAtIndex:i];
        id object3 = [colorData objectAtIndex:i];
        id object4 = [realValues objectAtIndex:i];
        
        CWSegmentData* segment = [[CWSegmentData alloc] init];
        segment.value = object1;
        segment.label = [NSString stringWithFormat:@"%@ : %@", object2, object4];
        CWColor* c1 = object3;
        CWColor* c2 = [c1 colorWithAlphaComponent:0.8f];
        segment.color = c2;
        segment.highlight = c1;
        [data addObject:segment];
        
    }
    
    //	id win = [self.webview windowScriptObject];
    CWDoughnutChart* pc = [[CWDoughnutChart alloc] initWithWebView:self.webview name:@"Doughnut1" width:200 height:200 data:data options:nil];
    
    
    [pc addChart];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebView* webview = [[WKWebView alloc] initWithFrame:self.wview.bounds];
    [webview setTranslatesAutoresizingMaskIntoConstraints:NO];
    webview.center = self.wview.center ;
    [self.wview addSubview:webview];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(webview);
    [self.wview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]|" options:0 metrics:nil views:viewsDictionary]];
    [self.wview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:nil views:viewsDictionary]];
//    [_wview setBackgroundColor:[UIColor redColor]];
    
    self.webview = webview;
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/cw.html"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    
    [webview setOpaque:NO];
    webview.backgroundColor = [UIColor clearColor];
    webview.scrollView.scrollEnabled = false;
    webview.multipleTouchEnabled = NO;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (self.wview.frame.origin.y + self.wview.frame.size.height))];

    
    format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
   
    // navigation bar auto scroll label
    self.navigationBarScrollLabel.text = foodData.name;
    self.navigationBarScrollLabel.pauseInterval = 3.f;
    self.navigationBarScrollLabel.font = [UIFont boldSystemFontOfSize:20];
    self.navigationBarScrollLabel.textColor = [UIColor whiteColor];
    [self.navigationBarScrollLabel observeApplicationNotifications];
    
    
   // self.title = foodData.name;
    
    // Set Data and Titles
    
    lablView.text = foodData.name;
    calView.text = foodData.caloriesStringValue;
    servingSize.text = foodData.servingDescription1;
    fatView.text = foodData.totalFatValue;
    satfatView.text = foodData.saturatedFatValue;
    polyfatView.text = foodData.polyunsaturatedFatValue;
    monofatView.text = foodData.monounsaturatedFatValue;
    fatCals.text = foodData.caloriesFromFatValue;
    cholView.text = foodData.cholesterolValue;
    sodView.text = foodData.sodiumValue;
    fiberView.text = foodData.dietaryFiberValue;
    sugarView.text = foodData.sugarsValue;
    protView.text = foodData.proteinValue;
    carbsView.text = foodData.carbsValue;
    calcView.text = foodData.calciumValue;
    ironView.text = foodData.ironValue;
    vitaView.text = foodData.vitaminAValue;
    viteView.text = foodData.viteValue;
    vitcView.text = foodData.vitaminCValue;
    transView.text = foodData.transFatValue;
    tfatPerc.text = foodData.totalFatPercent;
    calPerc.text = foodData.calfromFatValuePerc;
    _calPercGr.text = foodData.calfromFatValuePerc;
    sfatPerc.text = foodData.saturatedFatPercent;
    pfatPerc.text = foodData.polyFatValuePerc;
    mfatPerc.text = foodData.monoFatValuePerc;
    _cholPerc.text = foodData.cholesterolPercent;
    _ffPerc.text = foodData.totalValuePerc;
    sodPerc.text = foodData.sodiumPercent;
    _fibPerc.text = foodData.dietaryFiberPercent;
    _sugPerc.text = foodData.sugarsValuePerc;
    _protPerc.text = foodData.proteinValuePerc;
    _carbPerc.text = foodData.carbsPercent;
    _calcPerc.text = foodData.calciumValuePerc;
    _ironPerc.text = foodData.ironValuePerc;
    _vitaPerc.text = foodData.vitaminAValuePerc;
    _vitcPerc.text = foodData.vitaminCValuePerc;
    _vitePerc.text = foodData.vitaminEValuePerc;
    
    // Progress Bar Code
    
    [self prog:calProg data:foodData.caloriesFloatValuePerc];
    [self prog:tfatProg data:foodData.totalFatPercentfloat];
    [self prog:sfatProg data:foodData.saturatedFatPercentFloat];
    [self prog:calffatProg data:foodData.calfromFatValuePercFloat];
    [self prog:_mfatProg data:foodData.monoSaturatedFatPercentFloat];
    [self prog:_cholProg data:foodData.cholPercentFloat];
    
    //UIColor *redcolor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
    UIColor *buttColor = [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
    //UIColor *greyColor = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    
    [ self makeButton:_Add color:buttColor ];
    [ self makeButton:_btnTodayIntake color:buttColor ];
    
    CGFloat time1 = 3.49;
    CGFloat time2 = 8.13;
    
    // Delay 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat newTime = time1 + time2;
        NSLog(@"New time: %f", newTime);
        [self addDoughnut];
    });
    
    
    foodListArray = [AppDelegate GetfoodListItems];
    selectedFoodList = foodListArray[0] ;
    
    UIPickerView* picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    _txtPicker.inputView = picker ;
    
    [_txtPicker addDoneOnKeyboardWithTarget:self action:@selector(doneAction)];
    
    if (!self.foodData.userDefined.boolValue)
    {
        [self.btnEdit setEnabled:NO];
        [self.btnEdit setTintColor:[UIColor clearColor]];
    }
    
    // Do any additional setup after loading the view.
}
-(void)doneAction
{
    [_txtPicker resignFirstResponder];
    
    [self performSelector:@selector(CallAfterDelay) withObject:nil afterDelay:0.7];
    
    
}
-(void)CallAfterDelay
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSMutableSet* foodSet = self.foodData.foodListsBelongTo.mutableCopy;
    if (![foodSet containsObject:selectedFoodList])
    {
        FoodList* list = [AppDelegate GetUserFoodLibrary][0] ;
        if (![foodSet containsObject:list] && self.foodData.userDefined.boolValue)
        {
            [foodSet addObject: list] ;
        }
        [foodSet addObject: selectedFoodList];
        self.foodData.foodListsBelongTo = foodSet ;
        NSError *error;
        if (![context save:&error])
        {
            NSLog(@"errror while saving : %@",error.description);
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food Item added successfully" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
           // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food Item added successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Food Item already exists" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food Item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(NSArray*)CheckForDuplicateFoodItem
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"UserFoodRecords" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    
   NSString* dateStr = [format stringFromDate:[NSDate new]] ;
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date LIKE[c] %@",dateStr];
    [request setPredicate:predicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
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
//    _txtPicker.text = selectedFoodList.name ;
    
}

- (IBAction)EditFood:(id)sender
{
    [self performSegueWithIdentifier:@"segue_edit" sender:self];
}

- (IBAction)TodaysFoodIntake:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Befit"
                                          message:@"Please enter servings"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Qty", @"Qty");
     }];
    
    UITextField *txtServings = alertController.textFields.firstObject;
    txtServings.keyboardType = UIKeyboardTypePhonePad ;
    alertController.view.tag = 100;
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Cancel"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Done"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 UITextField *txtServings = alertController.textFields.firstObject;
                                 
                                 if (txtServings.text.length == 0)
                                 {
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter servings" preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                     [alertController addAction:ok];
                                     
                                     [self presentViewController:alertController animated:YES completion:nil];
                                     
                                     
                                     //            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
                                     //            [alert show];
                                     return ;
                                 }
                                 NSManagedObjectContext *context = [self managedObjectContext];
                                 UserFoodRecords* record = [NSEntityDescription insertNewObjectForEntityForName:@"UserFoodRecords" inManagedObjectContext:context];
                                 NSString* dateStr = [format stringFromDate:[NSDate new]] ;
                                 NSInteger servings = txtServings.text.integerValue ;
                                 NSMutableSet* newfood = [NSMutableSet setWithObject:foodData];
                                 NSArray* recordArray = [self CheckForDuplicateFoodItem] ;
                                 
                                 for (int iCount = 0; iCount < recordArray.count; iCount++)
                                 {
                                     UserFoodRecords* newRecord = [recordArray objectAtIndex:iCount];
                                     NSMutableArray* foodArray = [[NSMutableArray alloc] initWithArray:[newRecord.foodIntake allObjects]];
                                     if ([foodArray containsObject:foodData])
                                     {
                                         servings = servings + newRecord.servings.integerValue ;
                                         record = newRecord ;
                                     }
                                 }
                                 
                                 
                                 
                                 
                                 //        if ([recordArray count] > 0)
                                 //        {
                                 //            record = recordArray[0] ;
                                 //            newfood = record.foodIntake.mutableCopy ;
                                 //            [newfood addObject:foodData];
                                 //        }
                                 record.date = dateStr ;
                                 record.servings = [NSNumber numberWithInteger:servings] ;
                                 record.foodIntake = newfood ;
                                 
                                 
                                 NSError *error;
                                 if (![context save:&error])
                                 {
                                     NSLog(@"errror while saving : %@",error.description);
                                 }
                                 else
                                 {
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food successfully added to Today's Intake list" preferredStyle:UIAlertControllerStyleAlert];
                                     
                                     UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                     [alertController addAction:ok];
                                     
                                     [self presentViewController:alertController animated:YES completion:nil];
                                     
                                     // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food successfully added to Today's Intake list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                                 }

                    
                             }];
    [alertController addAction:ok];
    [alertController addAction:cancel];
    
    
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Befit" message:@"Please enter servings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    //[alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    //UITextField *txtServings = [alertController textFieldAtIndex:0];
    

    //alert.tag = 100;
    //[alert show];
    
    
    
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Befit" message:@"Please enter servings" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"Servings";
//    }];
//    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//        UITextField *txtServings = [alertController textFields][0];
//        if (txtServings.text.length == 0)
//        {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
//            [alert show];
//            return ;
//        }
//        NSManagedObjectContext *context = [self managedObjectContext];
//        UserFoodRecords* record = [NSEntityDescription insertNewObjectForEntityForName:@"UserFoodRecords" inManagedObjectContext:context];
//        NSString* dateStr = [format stringFromDate:[NSDate new]] ;
//        NSInteger servings = txtServings.text.integerValue ;
//        NSMutableSet* newfood = [NSMutableSet setWithObject:foodData];
//        NSArray* recordArray = [self CheckForDuplicateFoodItem] ;
//        
//        for (int iCount = 0; iCount < recordArray.count; iCount++)
//        {
//            UserFoodRecords* newRecord = [recordArray objectAtIndex:iCount];
//            NSMutableArray* foodArray = [[NSMutableArray alloc] initWithArray:[newRecord.foodIntake allObjects]];
//            if ([foodArray containsObject:foodData])
//            {
//                servings = servings + newRecord.servings.integerValue ;
//                record = newRecord ;
//            }
//        }
//        
//        
//        
//        
//        //        if ([recordArray count] > 0)
//        //        {
//        //            record = recordArray[0] ;
//        //            newfood = record.foodIntake.mutableCopy ;
//        //            [newfood addObject:foodData];
//        //        }
//        record.date = dateStr ;
//        record.servings = [NSNumber numberWithInteger:servings] ;
//        record.foodIntake = newfood ;
//        
//        
//        NSError *error;
//        if (![context save:&error])
//        {
//            NSLog(@"errror while saving : %@",error.description);
//        }
//        else
//        {
//            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food successfully added to Today's Intake list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
//        }
//    }];
//    [alertController addAction:confirmAction];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [alertController addAction:cancelAction];
//    [self presentViewController:alertController animated:YES completion:nil];
    
}



//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//    }
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
    AddFoodViewController *destViewController = segue.destinationViewController;
    destViewController.foodListObject = self.foodData ;
    destViewController.isForEditing = TRUE ;
}



@end
