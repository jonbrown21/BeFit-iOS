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
@property (strong, nonatomic) NSArray *lifestyleArray;
@property (strong, nonatomic) NSArray *goalArray;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.Age becomeFirstResponder];
    self.navigationbar.delegate = self;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString*  gendervalue = [defaults objectForKey:@"gender-name"];
    NSString*  agevalue = [defaults objectForKey:@"age-name"];
    NSString*  weightvalue = [defaults objectForKey:@"weight-name"];
    NSString*  heightfeet = [defaults objectForKey:@"heightfeet-name"];
    NSString*  inchfeet = [defaults objectForKey:@"inchfeet-name"];
    NSString*  lifeValue = [defaults objectForKey:@"lifestyle-name"];
    NSString*  goalValue = [defaults objectForKey:@"goal-name"];
    NSString*  cmValue = [defaults objectForKey:@"cmheightvalue-name"];
    NSString*  kgValue = [defaults objectForKey:@"kgheightvalue-name"];
    NSString*  thegoal = [defaults objectForKey:@"thegoal"];
    NSString*  imUsing = [defaults objectForKey:@"using"];
    NSString*  recomendation = [defaults objectForKey:@"recommended-name"];
    
    float rec = [recomendation floatValue];
    float age = [agevalue floatValue];
    float weight = [weightvalue floatValue];
    float gender = [gendervalue floatValue];
    float inches = [inchfeet floatValue];
    float feet = [heightfeet floatValue];
    float goal = [goalValue floatValue];
    float life = [lifeValue floatValue];
    float cm = [cmValue floatValue];
    float kg = [kgValue floatValue];
    float theGoal = [thegoal floatValue];
    
    if ([imUsing  isEqual: @"yes"]) {
        _Slider.value = rec;
        _SliderLab.text = [NSString stringWithFormat:@"%@", recomendation];
        [_GoalSiwtch setOn:YES animated:YES];
        _Slider.userInteractionEnabled = NO;
        self.use.text = @"Using";
        
    } else {
        _Slider.value = theGoal;
        _SliderLab.text = [NSString stringWithFormat:@"%@", thegoal];
        [_GoalSiwtch setOn:NO animated:YES];
        _Slider.userInteractionEnabled = YES;
        self.use.text = @"Not Using";
    }
    
    // Automatically Set Lifestyle
    
    if (life == 0) {
        [_LifeButt setTitle:@"Sedentary" forState:UIControlStateNormal];
    }   else if(life == 1){
        [_LifeButt setTitle:@"Lightly Active" forState:UIControlStateNormal];
    } else if(life == 2) {
        [_LifeButt setTitle:@"Moderately Active" forState:UIControlStateNormal];
    } else if(life == 3) {
        [_LifeButt setTitle:@"Very Active" forState:UIControlStateNormal];
    } else if(life == 4) {
        [_LifeButt setTitle:@"Extra Active" forState:UIControlStateNormal];
    } else {
        [_LifeButt setTitle:@"Select" forState:UIControlStateNormal];
    }
    
    
    // Automatically Set Goal
    
    if (goal == 0) {
        [_GoalButt setTitle:@"Loose Weight" forState:UIControlStateNormal];
    }   else if(goal == 1){
        [_GoalButt setTitle:@"Gain Weight" forState:UIControlStateNormal];
    } else if(goal ==2) {
        [_GoalButt setTitle:@"Maintain Weight" forState:UIControlStateNormal];
    } else {
        [_GoalButt setTitle:@"Select" forState:UIControlStateNormal];
    }
    
    // Automatically Call Age Value
    
    if (age > 0) {
        _Age.text = agevalue;
    } else {
        _Age.text = @"";
    }
    
    // Automatically Call Weight Value
    
    if (weight > 0) {
        _Weight.text = weightvalue;
    } else {
        _Weight.text = @"";
    }
    
    // Automatically Call Feet Value
    
    if (feet > 0) {
        _Hfeet.text = heightfeet;
    } else {
        _Hfeet.text = @"";
    }
    
    // Automatically Call Inch Value
    
    if (inches > 0) {
        _Hinches.text = inchfeet;
    } else {
        _Hinches.text = @"";
    }
    
    // Automatically Call CM Value
    
    if (cm > 0) {
        _HCM.text = cmValue;
    } else {
        _HCM.text = @"";
    }
    
    // Automatically Call KG Value
    
    if (kg > 0) {
        _weightMet.text = kgValue;
    } else {
        _weightMet.text = @"";
    }
    
    
    // Automatically Call Gender Value
    
    if (gender == 0) {
        [_GenderButt setTitle:@"Male" forState:UIControlStateNormal];
    } else if (gender == 1) {
        [_GenderButt setTitle:@"Female" forState:UIControlStateNormal];
    } else {
        [_GenderButt setTitle:@"Select" forState:UIControlStateNormal];
    }
    
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]];
    
    self.genderArray = @[ @"Male", @"Female"];
    self.goalArray = @[ @"Loose Weight", @"Gain Weight", @"Maintain Weight"];
    self.lifestyleArray = @[ @"Sedentary", @"Lightly Active", @"Moderately Active", @"Very Active", @"Extra Active"];
    
    UIColor *buttColor = [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
    UIColor *greyColor = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    UIColor *redcolor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
    
    [[UITextField appearance] setTintColor:greyColor];
    
    [ self makeButton:_ResetButt color:redcolor ];
    [ self makeButton:_GoalButt color:greyColor ];
    [ self makeButton:_LifeButt color:greyColor ];
    [ self makeButton:_CalcButt color:buttColor ];
    [ self makeButton:_GenderButt color:greyColor ];
    
#pragma mark - Set Done Button on Number Pad
    

    
    _HCM.hidden = YES;
    _cmLab.hidden = YES;
    _weightMet.hidden = YES;
    
    [[UISwitch appearance] setTintColor:[UIColor colorWithRed:0.66 green:0.70 blue:0.73 alpha:1.0]];
    [_MetricSwitch addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
    [_MetricSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    [_GoalSiwtch addTarget:self action:@selector(didGoalSwitch:) forControlEvents:UIControlEventValueChanged];
    
    [self Calculate:self];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)Reset:(id)sender {
    
    self.HCM.text = @"";
    self.weightMet.text = @"";
    self.Hinches.text = @"";
    self.Hfeet.text = @"";
    self.Weight.text = @"";
    self.Age.text = @"";
    self.Recommended.text = @"";
    self.Total.text = @"";
    _Slider.value = 500;
    _SliderLab.text = @"500";
    
    [_LifeButt setTitle:@"Select" forState:UIControlStateNormal];
    [_GoalButt setTitle:@"Select" forState:UIControlStateNormal];
    [_GenderButt setTitle:@"Select" forState:UIControlStateNormal];
    
    NSString *resetValue = @"";
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resetValue forKey:@"age-name"];
    [defaults setObject:resetValue forKey:@"weight-name"];
    [defaults setObject:resetValue forKey:@"heightfeet-name"];
    [defaults setObject:resetValue forKey:@"inchfeet-name"];
    [defaults setObject:resetValue forKey:@"cmheightvalue-name"];
    [defaults setObject:resetValue forKey:@"kgheightvalue-name"];
    [defaults setObject:resetValue forKey:@"goal-name"];
    [defaults setObject:resetValue forKey:@"lifestyle-name"];
    [defaults setObject:resetValue forKey:@"gender-name"];
    [defaults setObject:resetValue forKey:@"recommended-name"];
    [defaults setObject:resetValue forKey:@"thegoal"];
    [defaults setObject:@"no" forKey:@"using"];
    
    [_GoalSiwtch setOn:NO animated:NO];
    [_MetricSwitch setOn:NO animated:NO];
}

-(IBAction)sliderValueChanged:(id)sender
{
    if (sender == _Slider) {
        _SliderLab.text = [NSString stringWithFormat:@"%0.0f", _Slider.value];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%0.0f", _Slider.value] forKey:@"thegoal"];
        
    }
    
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

-(void)cancelNumberPad{
    [_Age resignFirstResponder];
    [_Weight resignFirstResponder];
    [_Hfeet resignFirstResponder];
    [_Hinches resignFirstResponder];
    [_weightMet resignFirstResponder];
    [_HCM resignFirstResponder];
}
-(void)didGoalSwitch:(UISwitch *)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString*  recomendation = [defaults objectForKey:@"recommended-name"];
    
    float rec = [recomendation floatValue];
    
    
    if (_GoalSiwtch.on) {
        self.use.text = @"Using";
        _Slider.value = rec;
        _Slider.userInteractionEnabled = NO;
        _SliderLab.text = recomendation;
        
        [defaults setObject:@"yes" forKey:@"using"];
        
        
    } else {
        self.use.text = @"Not Using";
        _Slider.userInteractionEnabled = YES;
        
        [defaults setObject:@"no" forKey:@"using"];
        
        _Slider.value = 500;
        _SliderLab.text = @"500";
    }
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)didChangeSwitch:(UISwitch *)sender
{
    self.Hfeet.hidden = _MetricSwitch.on;
    self.Hinches.hidden = _MetricSwitch.on;
    self.inLab.hidden = _MetricSwitch.on;
    self.ftLab.hidden = _MetricSwitch.on;
    self.Weight.hidden = _MetricSwitch.on;
    self.HCM.hidden = !_MetricSwitch.on;
    self.cmLab.hidden = !_MetricSwitch.on;
    self.weightMet.hidden = !_MetricSwitch.on;
    if (_MetricSwitch.on) {
        self.switchLab.text = @"Metric";
        self.lbs.text = @"kg";
    } else {
        self.switchLab.text = @"Imperial";
        self.lbs.text = @"lbs";
    }
}

- (void)setState:(id)sender
{
    BOOL state = [sender isOn];
    NSString *rez = state == YES ? @"YES" : @"NO";
    NSLog(@"%@", rez);
    [self Calculate:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Calculate:(id)sender {
    
    [ProgressHUD show:@"Saving..."];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString*  gendervalue = [defaults objectForKey:@"gender-name"];
    NSString*  lifeValue = [defaults objectForKey:@"lifestyle-name"];
    NSString*  goalValue = [defaults objectForKey:@"goal-name"];
    
    float height;
    float weight;
    float lbs;
    float in;
    float bmi;
    float bmr;
    float gender;
    float age;
    float lifestyles;
    float BMRLIFESTYLE = 0.0;
    float goals;
    float BMRGOALS;
    float h_feet;
    float i_feet;
    float m_cm;
    float m_kg;
    
    // Automatically Set Age Value
    
    age = [_Age.text doubleValue];
    NSString *ageValue = [NSString stringWithFormat:@"%lu", (unsigned long)age];
    [defaults setObject:ageValue forKey:@"age-name"];
    
    // Automatically Set Weight Value
    
    weight = [_Weight.text doubleValue];
    NSString *weightValue = [NSString stringWithFormat:@"%lu", (unsigned long)weight];
    [defaults setObject:weightValue forKey:@"weight-name"];
    
    // Automatically Set Gender Value
    
    gender = [gendervalue floatValue];
    lifestyles = [lifeValue floatValue];
    goals = [goalValue floatValue];
    
    // Automatically Set Height Feet Value
    
    h_feet = [_Hfeet.text floatValue];
    NSString *heightfeetValue = [NSString stringWithFormat:@"%lu", (unsigned long)h_feet];
    [defaults setObject:heightfeetValue forKey:@"heightfeet-name"];
    
    // Automatically Set Height Inches Value
    
    i_feet = [_Hinches.text floatValue];
    NSString *inchfeetValue = [NSString stringWithFormat:@"%lu", (unsigned long)i_feet];
    [defaults setObject:inchfeetValue forKey:@"inchfeet-name"];
    
    // Automatically Set Height CM Value
    
    m_cm = [_HCM.text floatValue];
    NSString *cmheightvalue = [NSString stringWithFormat:@"%lu", (unsigned long)m_cm];
    [defaults setObject:cmheightvalue forKey:@"cmheightvalue-name"];
    
    // Automatically Set Height KG Value
    
    m_kg = [_weightMet.text floatValue];
    NSString *kgheightvalue = [NSString stringWithFormat:@"%lu", (unsigned long)m_kg];
    [defaults setObject:kgheightvalue forKey:@"kgheightvalue-name"];
    
    if (_MetricSwitch.on) {
        //Convert IN Input Values to Metric
        
        if (_Weight.text.length > 0) {
            float lbs;
            float kg;
            lbs = [_Weight.text doubleValue];
            kg = lbs * 0.453592;
            
            self.weightMet.text = [NSString stringWithFormat:@"%.0f", kg];
        }
        
        
        if (_Hfeet.text.length > 0) {
            height = ([_Hfeet.text doubleValue] * 12) + [_Hinches.text doubleValue];
            float revHeight;
            
            revHeight = height * 2.54;
            
            self.HCM.text = [NSString stringWithFormat:@"%.0f", revHeight];
        }
        
        weight = [_weightMet.text doubleValue];
        lbs = weight / 0.453592;
        in = [_HCM.text doubleValue] * 0.393701;
        height = [_HCM.text doubleValue] / 100;
        age = [_Age.text doubleValue];
        bmi = weight / ( height * height );
        
        NSString* FinishedBMI = [NSString stringWithFormat:@"%.f", bmi];
        
        float bmiFloatValue;
        bmiFloatValue = [FinishedBMI floatValue];
        
        NSString* theRange;
        
        if(bmiFloatValue < 16.5){
            theRange = @"Underweight";
        }else if (bmiFloatValue<18.5) {
            theRange = @"Underweight";
        }else if (bmiFloatValue<27) {
            theRange = @"Normal";
        }else if (bmiFloatValue<30) {
            theRange = @"Overweight";
        }else if (bmiFloatValue<35) {
            theRange = @"Obese";
        }else {
            theRange = @"Obese";
        }
        
        NSString* finalBMIOutput = [NSString stringWithFormat:@"BMI: %.f | Rating: %@", bmi, theRange];
        
        if (gender == 1) {
            
            bmr = 655 + (4.35 * lbs) + (4.7 * in) - (4.7 * age);
            
            
            _Total.text = [NSString stringWithFormat:@"%@", finalBMIOutput];
            _Recommended.text = [NSString stringWithFormat:@"%.0f", bmr];
            
        } else {
            
            bmr = 66 + (6.23 * lbs) + (12.7 * in) - (6.8 * age);
            
            _Total.text = [NSString stringWithFormat:@"%@", finalBMIOutput];
            _Recommended.text = [NSString stringWithFormat:@"%.0f", bmr];
        }
        
        
        
        if (lifestyles == 0) {
            
            BMRLIFESTYLE = bmr * 1.2;
            
        } else if (lifestyles == 1) {
            
            BMRLIFESTYLE = bmr * 1.375;
            
        } else if (lifestyles == 2) {
            
            BMRLIFESTYLE = bmr * 1.55;
            
        } else if (lifestyles == 3) {
            
            BMRLIFESTYLE = bmr * 1.725;
            
        } else if (lifestyles == 4) {
            
            BMRLIFESTYLE = bmr * 1.9;
            
        }
        
        if (goals == 0) {
            
            BMRGOALS = BMRLIFESTYLE - 500;
            
        } else if (goals == 1) {
            
            BMRGOALS = BMRLIFESTYLE + 1000;
            
        } else if (goals == 2) {
            
            BMRGOALS = BMRLIFESTYLE;
            
        } else {
            
            BMRGOALS = BMRLIFESTYLE;
            
        }
        
        
        self.Recommended.text = [NSString stringWithFormat:@"%.0f Calories", BMRGOALS];
        [defaults setObject:[NSString stringWithFormat:@"%.0f", BMRGOALS] forKey:@"recommended-name"];
        
        NSString*  imUsing = [defaults objectForKey:@"using"];
        NSString*  recomendation = [defaults objectForKey:@"recommended-name"];
        
        float rec = [recomendation floatValue];
        
        if ([imUsing  isEqual: @"yes"]) {
            _Slider.value = rec;
            _SliderLab.text = [NSString stringWithFormat:@"%@", recomendation];
            [_GoalSiwtch setOn:YES animated:YES];
            _Slider.userInteractionEnabled = NO;
            self.use.text = @"Using";
            
        }
        
        
    } else {
        
        if (_weightMet.text.length > 0) {
            float lbs;
            float kg;
            kg = [_weightMet.text doubleValue];
            lbs = kg / 0.453592;
            
            self.Weight.text = [NSString stringWithFormat:@"%.0f", lbs];
        }
        
        
        if (_HCM.text.length > 0) {
            
            float cm;
            cm = [_HCM.text doubleValue];
            
            const float INCH_IN_CM = 2.54;
            
            NSInteger numInches = (NSInteger) roundf(cm / INCH_IN_CM);
            NSInteger feet = numInches / 12;
            NSInteger inches = numInches % 12;
            
            self.Hfeet.text = [NSString stringWithFormat:@"%@", @(feet)];
            self.Hinches.text = [NSString stringWithFormat:@"%@", @(inches)];
        }
        
        
        height = ([_Hfeet.text doubleValue] * 12) + [_Hinches.text doubleValue];
        weight = [_Weight.text doubleValue];
        age = [_Age.text doubleValue];
        bmi = weight / ( height * height ) * 703;
        
        NSString* FinishedBMI = [NSString stringWithFormat:@"%.f", bmi];
        
        float bmiFloatValue;
        bmiFloatValue = [FinishedBMI floatValue];
        
        NSString* theRange;
        
        if(bmiFloatValue < 16.5){
            theRange = @"Underweight";
        }else if (bmiFloatValue<18.5) {
            theRange = @"Underweight";
        }else if (bmiFloatValue<27) {
            theRange = @"Normal";
        }else if (bmiFloatValue<30) {
            theRange = @"Overweight";
        }else if (bmiFloatValue<35) {
            theRange = @"Obese";
        }else {
            theRange = @"Obese";
        }
        
        NSString* finalBMIOutput = [NSString stringWithFormat:@"BMI: %.f | Rating: %@", bmi, theRange];
        
        
        if (gender == 1) {
            
            bmr = 655 + ( 4.35 * weight ) + ( 4.7 * height ) - ( 4.7 * age );
            
            _Total.text = [NSString stringWithFormat:@"%@", finalBMIOutput];
            
        } else {
            
            bmr =  66 + ( 6.23 * weight ) + ( 12.7 * height ) - ( 6.8 * age );
            _Total.text = [NSString stringWithFormat:@"%@", finalBMIOutput];
            
        }
        
        if (lifestyles == 0) {
            
            BMRLIFESTYLE = bmr * 1.2;
            
        } else if (lifestyles == 1) {
            
            BMRLIFESTYLE = bmr * 1.375;
            
        } else if (lifestyles == 2) {
            
            BMRLIFESTYLE = bmr * 1.55;
            
        } else if (lifestyles == 3) {
            
            BMRLIFESTYLE = bmr * 1.725;
            
        } else if (lifestyles == 4) {
            
            BMRLIFESTYLE = bmr * 1.9;
            
        }
        
        if (goals == 0) {
            
            BMRGOALS = BMRLIFESTYLE - 500;
            
            
        } else if (goals == 1) {
            
            BMRGOALS = BMRLIFESTYLE + 1000;
            
        } else if (goals == 2) {
            
            BMRGOALS = BMRLIFESTYLE;
            
        } else {
            
            BMRGOALS = BMRLIFESTYLE;
            
        }
        
        self.Recommended.text = [NSString stringWithFormat:@"%.0f Calories", BMRGOALS];
        [defaults setObject:[NSString stringWithFormat:@"%.0f", BMRGOALS] forKey:@"recommended-name"];
        
        NSString*  imUsing = [defaults objectForKey:@"using"];
        NSString*  recomendation = [defaults objectForKey:@"recommended-name"];
        
        float rec = [recomendation floatValue];
        
        if ([imUsing  isEqual: @"yes"]) {
            _Slider.value = rec;
            _SliderLab.text = [NSString stringWithFormat:@"%@", recomendation];
            [_GoalSiwtch setOn:YES animated:YES];
            _Slider.userInteractionEnabled = NO;
            self.use.text = @"Using";
            
        }
    }
    [ProgressHUD dismiss];
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 3) ? NO : YES;
}

- (IBAction)selectLifestylePressed:(id)sender
{
    
    UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"LifeTableVC"];
    LifestyleTableView *tableViewController = (LifestyleTableView *)[[navigationController viewControllers] objectAtIndex:0];
    tableViewController.tableData = self.lifestyleArray;
    tableViewController.navigationItem.title = @"Lifestyle";
    tableViewController.delegate = self;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self presentViewController:navigationController animated:YES completion:nil];
    
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

- (IBAction)selectGoalPressed:(id)sender
{
    
    UINavigationController *navigationController = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GoalTableVC"];
    GoalTableView *tableViewController = (GoalTableView *)[[navigationController viewControllers] objectAtIndex:0];
    tableViewController.tableData = self.goalArray;
    tableViewController.navigationItem.title = @"Goals";
    tableViewController.delegate = self;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}





- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)itemSelectedLifestyleAtRow:(NSInteger)row
{
    
    [self->_LifeButt setTitle:[self.lifestyleArray objectAtIndex:row] forState:UIControlStateNormal];
    
}

- (void)itemSelectedGoalAtRow:(NSInteger)row
{
    
    [self->_GoalButt setTitle:[self.goalArray objectAtIndex:row] forState:UIControlStateNormal];
    
}

- (void)itemSelectedatRow:(NSInteger)row
{
    
    [self->_GenderButt setTitle:[self.genderArray objectAtIndex:row] forState:UIControlStateNormal];
    
}

@end
