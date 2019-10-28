//
//  FoodTrackViewController.m
//  BeFit iOS
//
//  Created by Satinder Singh on 2/21/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "FoodTrackViewController.h"
#import "BeFitTracker-Swift.h"

@implementation FoodTrackCell
@end
@interface FoodTrackViewController ()

@end

@implementation FoodTrackViewController
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)loadView
{
    [super loadView];
    
    
//    _values							= @[@30, @45, @44, @60, @95, @2, @8, @9];
//    _newvalues = [NSMutableArray arrayWithObjects:@"Sunday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",@"Monday",nil];
    _barColors						= @[[UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0], [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0], [UIColor colorWithRed:0.61 green:0.35 blue:0.71 alpha:1.0], [UIColor colorWithRed:0.90 green:0.49 blue:0.13 alpha:1.0]];
    _currentBarColor				= 0;
    
//    CGRect chartFrame				= CGRectMake(0.0,
//                                                 0.0,
//                                                 300.0,
//                                                 300.0);
    
    
    _chart							= [[SimpleBarChart alloc] initWithFrame:_simplechart.frame];
   
    _chart.delegate					= self;
    _chart.dataSource				= self;
    _chart.barShadowOffset			= CGSizeMake(2.0, 1.0);
    _chart.animationDuration		= 0.0;
    _chart.barShadowColor			= [UIColor grayColor];
    _chart.barShadowAlpha			= 0.1;
    _chart.barShadowRadius			= 1.0;
    _chart.barWidth					= 28.0;
    _chart.chartBorderColor         = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    _chart.xLabelType				= SimpleBarChartXLabelTypeAngled;
    _chart.incrementValue			= 400;
    _chart.barTextType				= SimpleBarChartBarTextTypeRoof;
    _chart.barTextColor				= [UIColor blackColor];
    _chart.gridColor				= [UIColor grayColor];
    _chart.yLabelColor              = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    _chart.xLabelColor              = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    _chart.barTextColor             = [UIColor colorWithRed:0.50 green:0.55 blue:0.55 alpha:1.0];
    
     [self.view addSubview:_chart];
    
}
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIBarPosition)barPosition {
    return UIBarPositionTopAttached;
}

- (void)changeClicked
{
    NSMutableArray *valuesCopy = _values.mutableCopy;
//    [valuesCopy shuffle];
    
    _values = valuesCopy;
    
    if (_chart.xLabelType == SimpleBarChartXLabelTypeVerticle)
        _chart.xLabelType = SimpleBarChartXLabelTypeHorizontal;
    else
        _chart.xLabelType = SimpleBarChartXLabelTypeVerticle;
    
    _currentBarColor = ++_currentBarColor % _barColors.count;
    
    [_chart reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationbar.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Food Tracker";
    //self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"whitey.png"]];
    [AppDelegate setCornerRadiusofUIButton:_btn1Wk];
    [AppDelegate setCornerRadiusofUIButton:_btn1M];
    [AppDelegate setCornerRadiusofUIButton:_btn3M];
    [AppDelegate setCornerRadiusofUIButton:_btn6M];
    [AppDelegate setCornerRadiusofUIButton:_btn1Yr];
    
    
    
//    [_btn1Wk sendActionsForControlEvents:UIControlEventTouchUpInside];

    [_btn1Wk setBackgroundColor:[UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:0.5]];
    timeFrames = 7 ;
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    [_btn1Wk setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btn1M setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btn3M setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btn6M setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btn1Yr setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    
    // Set Background Color of UIStatusBar
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat statusBarHeight = app.statusBarFrame.size.height;
    
    UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, statusBarHeight)];
    statusBarView.backgroundColor  =  [UIColor colorWithRed:0.32 green:0.66 blue:0.82 alpha:1.0];
    [self.view addSubview:statusBarView];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets insets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
        if (insets.top > 0) {
            // We're running on an iPhone with a notch.

            // Set Background Color of UIStatusBar
            UIApplication *app = [UIApplication sharedApplication];
            CGFloat statusBarHeight = app.statusBarFrame.size.height;
            
            UIView *statusBarView =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, statusBarHeight)];
            statusBarView.backgroundColor  = [UIColor colorWithRed:0.32 green:0.66 blue:0.82 alpha:1.0];
            [self.view addSubview:statusBarView];
            
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self BuildView];
}

-(void)BuildView
{
    [AppDelegate ShowLoader];
    
    [self SetData];
    
    [_chart reloadData];
    [self.tableView reloadData];
    [AppDelegate HideLoader];
}
-(NSInteger)GetNumberOfDays:(NSInteger)frame
{
    
//    NSDate *today = [[NSDate alloc] init];
//    NSLog(@"%@", today);
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
//    
//    [offsetComponents setMonth:-frame]; // note that I'm setting it to -1
//    NSDate *endOfWorldWar3 = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
//    NSLog(@"%@", endOfWorldWar3);
//    
//    
//    
//    
//    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
//                                                        fromDate:[NSDate date]
//                                                          toDate:endOfWorldWar3
//                                                         options:0];
//    
//    NSLog(@"Total Number Of Days : %ld", [components day]);
//    
//    return labs([components day]) ;
    
   NSInteger totalDays = [self GetDaysInCurrentMonth]  ;
   for (int iCount = 1; iCount < frame ; iCount ++)
    {
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *comps = [NSDateComponents new];
//        comps.month = -1;
//        comps.day   = -1;
//        NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
//        NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components
//        NSLog(@"Previous month: %d",[components month]);
//        NSLog(@"Previous day  : %d",[components day]);
        
//        NSDate *today = [NSDate date];
//        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        
//        NSDateComponents *components = [gregorian components:(NSCalendarUnitEra | NSCalendarUnitYear| NSCalendarUnitMonth) fromDate:today];
//        components.day = 1;
//        components.month = -1 * iCount ;
//        
//        NSDate *dayOneInCurrentMonth = [gregorian dateFromComponents:components];
        
        
        
        
        NSDate *today = [[NSDate alloc] init];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setMonth:-iCount];
        NSDate *dateStr = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
        
        NSRange range = [gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:dateStr];
        NSUInteger numberOfDaysInMonth = range.length;
        NSLog(@"%lu", (unsigned long)numberOfDaysInMonth);
        
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *components = [[NSDateComponents alloc] init];
//        
//        // Set your year and month here
//        [components setMonth:-1 * iCount];
//        
//        NSDate *date = [calendar dateFromComponents:components];
//        NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
        
        NSLog(@"%d", (int)range.length);
        totalDays = totalDays + range.length ;
    }
    
    return totalDays ;
    
}
-(NSInteger)GetDaysInCurrentMonth
{
    NSDateFormatter *date_Format = [[NSDateFormatter alloc] init];
    [date_Format setDateFormat:@"dd"];
    NSString* strng = [date_Format stringFromDate:[NSDate new]];
    return strng.integerValue ;
}

-(NSInteger)GetDaysInPreviousMonth:(NSInteger)month
{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    
//    // Set your year and month here
//    [components setMonth:-month ];
//    
//    NSDate *date = [calendar dateFromComponents:components];
//    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
//    
//    NSLog(@"%d", (int)range.length);
    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *comps = [NSDateComponents new];
//    comps.month = -month;
//
//    NSDate *_date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
//    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_date]; // Get necessary date components
//    NSLog(@"Previous month: %ld",(long)[components month]);
//    NSLog(@"Previous day  : %ld",(long)[components day]);
//    
//
//    components = [[NSDateComponents alloc] init] ;
//    
//
//    NSDate *date = [NSDate dateWithNaturalLanguageString:@"January"];
//    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
//    
//    NSLog(@"%d", (int)range.length);
//    
//    return range.length ;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f*31* month)]];
    NSInteger numberOfDaysInMonth = range.length;
    return numberOfDaysInMonth ;
}

-(void)SetData
{
    _lblGoalCal.text = [NSString stringWithFormat:@"Goal\n%ld Cal", [[[NSUserDefaults standardUserDefaults] objectForKey:@"recommended-name"] integerValue]];
    _lblTotalCal.text = [NSString stringWithFormat:@"Today\n0 Cal"] ;
    x_values = [[NSMutableArray alloc] init];
    _values = [[NSMutableArray alloc] init];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy-EEEE"];
    
    
    NSInteger totalNumberOfDays = 0 ;
    
    switch (timeFrames)
    {
        case 7:
        {
            for (int iCount = 0; iCount< timeFrames; iCount ++)
            {
                NSString* dateStr = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f* iCount)]] ;
                NSArray* arr = [dateStr componentsSeparatedByString:@"-"];
                [x_values addObject:arr[1]];
            }
            
            totalNumberOfDays = 7 ;
        }
            break;
            
        case 4:
        {
            for (int iCount = 0; iCount< timeFrames; iCount ++)
            {
                [x_values addObject:[NSString stringWithFormat:@"Week %ld",(timeFrames - iCount)]];
            }
            totalNumberOfDays = 31;
//            totalNumberOfDays = [self GetDaysInCurrentMonth];
        }
            break;
            
        case 3:
        {
//            for (int iCount = 0; iCount< timeFrames; iCount ++)
//            {
//                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
//            }
            
            totalNumberOfDays = [self GetNumberOfDays:timeFrames];
        }
            break;
        case 6:
        {
//            for (int iCount = 0; iCount< timeFrames; iCount ++)
//            {
//                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
//            }
            
            totalNumberOfDays = [self GetNumberOfDays:timeFrames];
        }
            break;
        case 12:
        {
//            for (int iCount = 0; iCount< timeFrames; iCount ++)
//            {
//                [x_values addObject:[NSString stringWithFormat:@"Month %ld",(timeFrames - iCount)]];
//            }
            
            totalNumberOfDays = [self GetNumberOfDays:timeFrames];
        }
            break;
        default:
        {
            
        }
            break;
    }
    
    NSLog(@"xvalues : %@",x_values);
    finalFoodArray = [[NSMutableArray alloc] init];
    finalSectionNameArray = [[NSMutableArray alloc] init];
    finalServingsArray = [[NSMutableArray alloc] init];
    foodObjectArray = [[NSMutableArray alloc] init];
    servingsArray= [[NSMutableArray alloc] init];
    
    NSInteger grossCal = 0 ;
    NSInteger totalCal = 0 ;
    NSInteger frameWindow = totalNumberOfDays / timeFrames ;
    NSInteger valueStoredCounter = 0 ;
    NSString* matchMonth = @"" ;
    NSString *testMonth = @"";
    NSInteger daysInCurrentMonth = [self GetDaysInCurrentMonth];;
    NSLog(@"%ld", (long)daysInCurrentMonth);
    
    for (int iCount = 0; iCount < totalNumberOfDays; iCount++)
    {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy-EEEE-MMMM-dd"];
       
        NSString* dateStr = [format stringFromDate:[NSDate dateWithTimeIntervalSinceNow: -(60.0f*60.0f*24.0f* iCount)]] ;
        NSArray* arr = [dateStr componentsSeparatedByString:@"-"];
        if (testMonth.length == 0)
        {
            testMonth = arr[2];
        }
       
//        [x_values addObject:arr[1]];
        
        NSArray* food_record = [self GetFoodItem:arr[0]];
        NSMutableArray* todaysItems = [[NSMutableArray alloc] init];
        for (int zCount = 0; zCount< food_record.count; zCount++)
        {
            UserFoodRecords* record = food_record[zCount] ;
            NSSet* foodSet = record.foodIntake ;
            NSArray* items = [foodSet allObjects];
            
            for (int jCount = 0 ; jCount < items.count; jCount++)
            {
                Food* food = [items objectAtIndex:jCount];
                
                totalCal = totalCal + (food.calories.integerValue * record.servings.integerValue) ;
                
            }
            
            [servingsArray addObject:record];
            [todaysItems addObjectsFromArray:items];
        }
        if (iCount == 0)
        {
            _lblTotalCal.text = [NSString stringWithFormat:@"Today\n%ld Cal", (long)totalCal] ;
            
        }
         grossCal = grossCal + totalCal;
        
        [foodObjectArray addObjectsFromArray: todaysItems];
        if (timeFrames == 7 )
        {
            [finalSectionNameArray addObject:arr[0]];
            [finalFoodArray addObject:foodObjectArray];
            [finalServingsArray addObject:servingsArray];
            foodObjectArray = [[NSMutableArray alloc] init];
            servingsArray= [[NSMutableArray alloc] init];
            [_values addObject:[NSNumber numberWithInteger:totalCal]];
            totalCal = 0 ;
            
        }
        else if (timeFrames == 4)
        {
            [finalSectionNameArray addObject:arr[0]];
            [finalFoodArray addObject:foodObjectArray];
            [finalServingsArray addObject:servingsArray];
            foodObjectArray = [[NSMutableArray alloc] init];
            servingsArray= [[NSMutableArray alloc] init];
            
            if (((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays -1))
            {
                valueStoredCounter ++ ;
                [_values addObject:[NSNumber numberWithInteger:totalCal]];
                totalCal = 0 ;
            }
            
        }
        else
        {
//            if (![matchMonth isEqualToString:arr[2]] && finalSectionNameArray.count < timeFrames)
//            {
//                matchMonth = arr[2] ;
//                [finalSectionNameArray addObject:arr[2]];
//                if (timeFrames != 4 || timeFrames != 7)
//                {
//                    [x_values addObject:arr[2]];
//                }
//            }
            
//            if (iCount + 1 == daysInCurrentMonth)

            if ([arr[3] integerValue] == 1 && ![matchMonth isEqualToString:arr[2]])
            {
                matchMonth = arr[2] ;
                [finalSectionNameArray addObject:arr[2]];
                if (timeFrames != 4 || timeFrames != 7)
                {
                    [x_values addObject:arr[2]];
                }
                [finalFoodArray addObject:foodObjectArray];
                [finalServingsArray addObject:servingsArray];
                foodObjectArray = [[NSMutableArray alloc] init];
                servingsArray= [[NSMutableArray alloc] init];
                [_values addObject:[NSNumber numberWithInteger:totalCal]];
                totalCal = 0 ;
//                valueStoredCounter++ ;
//                daysInCurrentMonth = daysInCurrentMonth + [self GetDaysInPreviousMonth:valueStoredCounter];
            }
//            else if (![testMonth isEqualToString:arr[2]])
//            {
//                testMonth = arr[2];
//                [finalSectionNameArray addObject:testMonth];
//                if (timeFrames != 4 || timeFrames != 7)
//                {
//                    [x_values addObject:arr[2]];
//                }
//                [finalFoodArray addObject:foodObjectArray];
//                [finalServingsArray addObject:servingsArray];
//                foodObjectArray = [[NSMutableArray alloc] init];
//                servingsArray= [[NSMutableArray alloc] init];
//                [_values addObject:[NSNumber numberWithInteger:totalCal]];
//                totalCal = 0 ;
//            }
            
//            if (((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays -1))
//            {
////                [finalSectionNameArray addObject:arr[2]];
//                [finalFoodArray addObject:foodObjectArray];
//                [finalServingsArray addObject:servingsArray];
//                foodObjectArray = [[NSMutableArray alloc] init];
//                servingsArray= [[NSMutableArray alloc] init];
//            }
        }
       
        
//        if (((iCount+1) % frameWindow == 0 && valueStoredCounter < timeFrames - 1) || iCount == (totalNumberOfDays -1))
//        {
//            valueStoredCounter ++ ;
//            [_values addObject:[NSNumber numberWithInteger:totalCal]];
//            totalCal = 0 ;
//        }
        
    }
    
    _lblAverageCal.text = [NSString stringWithFormat:@"Average\n%ld Cal", grossCal/totalNumberOfDays ] ;
    
    x_values =[NSMutableArray arrayWithArray: [[x_values reverseObjectEnumerator] allObjects]];
    _values =[NSMutableArray arrayWithArray: [[_values reverseObjectEnumerator] allObjects]];
}





//NSArray* reversedArray = [[startArray reverseObjectEnumerator] allObjects];
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SimpleBarChartDataSource

- (NSUInteger)numberOfBarsInBarChart:(SimpleBarChart *)barChart
{
    return _values.count;
}

- (CGFloat)barChart:(SimpleBarChart *)barChart valueForBarAtIndex:(NSUInteger)index
{
    
    return [[_values objectAtIndex:index] floatValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart textForBarAtIndex:(NSUInteger)index
{
    return [[_values objectAtIndex:index] stringValue];
}

- (NSString *)barChart:(SimpleBarChart *)barChart xLabelForBarAtIndex:(NSUInteger)index
{
    
    return [x_values objectAtIndex:index] ;
}

- (UIColor *)barChart:(SimpleBarChart *)barChart colorForBarAtIndex:(NSUInteger)index
{
    if (timeFrames == 7)
    {
        if ([[_values objectAtIndex:index] integerValue] < [[[NSUserDefaults standardUserDefaults] objectForKey:@"recommended-name"] integerValue])
        {
            _currentBarColor = 1;
        }
        else
        {
            _currentBarColor = 0;
        }
    }
   else
   {
       if (_lblAverageCal.text.integerValue < [[[NSUserDefaults standardUserDefaults] objectForKey:@"recommended-name"] integerValue])
       {
           _currentBarColor = 1;
       }
       else
       {
           _currentBarColor = 0;
       }
   }
    return [_barColors objectAtIndex:_currentBarColor];
}


-(NSArray*)GetFoodItem:(NSString*)dateStr
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"UserFoodRecords" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date LIKE[c] %@",dateStr];
    [request setPredicate:predicate];
    
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return finalSectionNameArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[finalFoodArray objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    static NSString *cellIdentifier = @"Cell";

    FoodTrackCell *cell =(FoodTrackCell*) [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier ];
    
    cell.accessoryView = nil;
    
    NSArray* foodArr = [finalFoodArray objectAtIndex:indexPath.section] ;
    NSArray* ServingsArr = [finalServingsArray objectAtIndex:indexPath.section] ;
    Food* food = [foodArr objectAtIndex:indexPath.row];
    cell.lblFoodName.text = food.name ;
    UserFoodRecords* rec = ServingsArr[indexPath.row];
    NSInteger totalCals = [rec.servings integerValue];
    cell.lblCal.text = [NSString stringWithFormat:@"%ld Cal", (long)(food.calories.integerValue) ] ;
    cell.lblTotalCals.text = [NSString stringWithFormat:@"Total Calories: %ld Cals", (food.calories.integerValue * totalCals) ] ;
    cell.lblServings.text = [NSString stringWithFormat:@"Total Servings: %ld",[rec.servings integerValue]] ;
    return cell;
}



-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    
    selectedIndexpath = [self.tableView indexPathForRowAtPoint:p];
    
    
    
    if (selectedIndexpath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Befit" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit Servings" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Befit"
                                          message:@"Please enter servings"
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField)
             {
                 textField.placeholder = NSLocalizedString(@"Qty", @"Qty");
             }];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Done"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         UITextField *txtServings = alert.textFields.firstObject;
                                         txtServings.keyboardType = UIKeyboardTypeNumberPad ;
                                         
                                         if (txtServings.text.length == 0)
                                         {
                                             
                                             
                                             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter servings" preferredStyle:UIAlertControllerStyleAlert];
                                             
                                             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                             [alertController addAction:ok];
                                             
                                             [self presentViewController:alertController animated:YES completion:nil];
                                             
                                             
                                             //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
                                             //[alert show];
                                             return ;
                                         }
                                         
                                         NSManagedObjectContext *context = [self managedObjectContext];
                                         
                                         NSArray* foodArr = [finalServingsArray objectAtIndex:selectedIndexpath.section];
                                         UserFoodRecords* record = [foodArr objectAtIndex:selectedIndexpath.row] ;
                                         record.servings = [NSNumber numberWithInteger:txtServings.text.integerValue];
                                         NSError *error;
                                         if (![context save:&error])
                                         {
                                             NSLog(@"errror while saving : %@",error.description);
                                         }
                                         else
                                         {
                                             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food edited successfully." preferredStyle:UIAlertControllerStyleAlert];
                                             
                                             UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                             [alertController addAction:ok];
                                             
                                             [self presentViewController:alertController animated:YES completion:nil];
                                             
                                             //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food edited successfully." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                                             [self BuildView];
                                         }
                                         
                                         
                                     }];
            [alert addAction:ok];
            [alert addAction:cancel];
            alert.view.tag = 100;
            [self presentViewController:alert animated:YES completion:nil];
            
            
            
            //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Befit" message:@"Please enter servings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
            // [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            //alert.tag = 100;
            //[alert show];
            
            
            
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Food" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSManagedObjectContext *context = [self managedObjectContext];
            
            NSArray* foodArr = [finalServingsArray objectAtIndex:selectedIndexpath.section];
            UserFoodRecords* record = [foodArr objectAtIndex:selectedIndexpath.row] ;
            [context deleteObject:record];
            NSError *error;
            if (![context save:&error])
            {
                NSLog(@"errror while saving : %@",error.description);
            }
            else
            {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food deleted successfully." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
                
                //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food deleted successfully." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                
                [self BuildView];
            }
            
            
        }]];
        // Present action sheet.
        
        actionSheet.view.tag = 1;
        [self presentViewController:actionSheet animated:YES completion:nil];
        
        
        
        
       // UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Befit" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: @"Edit Servings"otherButtonTitles:@"Delete Food", nil];
       // popup.tag = 1;
       // [popup showInView:self.view];
        
    }
    else
    {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
}


//- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//   
//    switch (buttonIndex)
//    {
//        case 0:
//        {
//            
//            
//        }
//            break;
//        case 1:
//        {
//            
//            }
//        
//        }
//            break;
//        default:
//            break;
//    }
//}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//        
//    }
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [finalSectionNameArray objectAtIndex:section]; ;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)TimeFrameValueChanged:(id)sender
{
    [_btn1Wk setBackgroundColor:[UIColor clearColor]];
    [_btn1M setBackgroundColor:[UIColor clearColor]];
    [_btn3M setBackgroundColor:[UIColor clearColor]];
    [_btn6M setBackgroundColor:[UIColor clearColor]];
    [_btn1Yr setBackgroundColor:[UIColor clearColor]];
    
    
    UIButton* btn = (UIButton*)sender ;
    [btn setBackgroundColor:[UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:0.5]];
    
    
    switch (btn.tag)
    {
        case 1:
            timeFrames = 7 ;
            break;
        case 2:
            timeFrames = 4 ;
            break;
        case 3:
            timeFrames = 3 ;
            break;
        case 4:
            timeFrames = 6 ;
            break;
        case 5:
            timeFrames = 12 ;
            break;
            
        default:
            break;
    }
    [self BuildView];
}




@end
