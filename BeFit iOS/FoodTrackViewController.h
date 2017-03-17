//
//  FoodTrackViewController.h
//  BeFit iOS
//
//  Created by Satinder Singh on 2/21/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleBarChart.h"
#import <CoreData/CoreData.h>
#import "UserFoodRecords+CoreDataProperties.h"
#import "AppDelegate.h"

@interface FoodTrackCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFoodName;
@property (weak, nonatomic) IBOutlet UILabel *lblCal;
@property (weak, nonatomic) IBOutlet UILabel *lblServings;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalCals;

@end
@interface FoodTrackViewController : UIViewController<SimpleBarChartDataSource, SimpleBarChartDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UINavigationBarDelegate>
{
    NSMutableArray *_values;
    NSMutableArray *x_values;
    
    NSArray *_barColors;
    NSInteger _currentBarColor;
    SimpleBarChart *_chart;
    BOOL thresholdValue ;
    NSMutableArray *foodObjectArray ;
    NSMutableArray* servingsArray ;
    NSInteger timeFrames;
    NSMutableArray* finalFoodArray ;
    NSMutableArray* finalServingsArray ;
    NSMutableArray* finalSectionNameArray ;
    NSIndexPath* selectedIndexpath ;
}
@property (weak, nonatomic) IBOutlet UILabel *lblTotalCal;
@property (weak, nonatomic) IBOutlet UILabel *lblGoalCal;
@property (weak, nonatomic) IBOutlet UILabel *lblAverageCal;
@property (weak, nonatomic) IBOutlet SimpleBarChart *simplechart;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationbar;
@property (weak, nonatomic) IBOutlet UIButton *btn1Wk;
@property (weak, nonatomic) IBOutlet UIButton *btn1M;
@property (weak, nonatomic) IBOutlet UIButton *btn3M;
@property (weak, nonatomic) IBOutlet UIButton *btn6M;
@property (weak, nonatomic) IBOutlet UIButton *btn1Yr;

- (IBAction)TimeFrameValueChanged:(id)sender;


@end
