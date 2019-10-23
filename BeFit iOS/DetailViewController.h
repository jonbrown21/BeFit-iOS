//
//  DetailViewController.h
//  BeFit iOS
//
//  Created by Jon on 9/25/16.
//  Copyright © 2016 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQUIView+IQKeyboardToolbar.h"
#import "AppDelegate.h"
#import "AddFoodViewController.h"

@class Food;
@class FoodList;
@class UserFoodRecords;

@interface DetailViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSDateFormatter* format ;
    NSArray* foodListArray;
    FoodList* selectedFoodList ;
   
}
@property (nonatomic, retain) NSString *selectedlabel;
@property(nonatomic,retain) IBOutlet UILabel *lablView;
@property(nonatomic,retain) IBOutlet UILabel *calView;
@property(nonatomic,retain) IBOutlet UILabel *fatView;
@property(nonatomic,retain) IBOutlet UILabel *satfatView;
@property(nonatomic,retain) IBOutlet UILabel *polyfatView;
@property(nonatomic,retain) IBOutlet UILabel *monofatView;
@property(nonatomic,retain) IBOutlet UILabel *fatCals;
@property(nonatomic,retain) IBOutlet UILabel *servingSize;
@property(nonatomic,retain) IBOutlet UILabel *cholView;
@property(nonatomic,retain) IBOutlet UILabel *sodView;
@property(nonatomic,retain) IBOutlet UILabel *fiberView;
@property(nonatomic,retain) IBOutlet UILabel *sugarView;
@property(nonatomic,retain) IBOutlet UILabel *protView;
@property(nonatomic,retain) IBOutlet UILabel *carbsView;
@property(nonatomic,retain) IBOutlet UILabel *calcView;
@property(nonatomic,retain) IBOutlet UILabel *ironView;
@property(nonatomic,retain) IBOutlet UILabel *vitaView;
@property(nonatomic,retain) IBOutlet UILabel *viteView;
@property(nonatomic,retain) IBOutlet UILabel *vitcView;
@property(nonatomic,retain) IBOutlet UILabel *transView;
@property (weak, nonatomic) IBOutlet UIButton *Add;

@property(nonatomic,retain) IBOutlet UILabel *calPerc;
@property(nonatomic,retain) IBOutlet UILabel *calPercGr;
@property(nonatomic,retain) IBOutlet UILabel *tfatPerc;
@property(nonatomic,retain) IBOutlet UILabel *sfatPerc;
@property(nonatomic,retain) IBOutlet UILabel *pfatPerc;
@property(nonatomic,retain) IBOutlet UILabel *mfatPerc;
@property(nonatomic,retain) IBOutlet UILabel *cholPerc;
@property(nonatomic,retain) IBOutlet UILabel *ffPerc;
@property(nonatomic,retain) IBOutlet UILabel *sodPerc;
@property(nonatomic,retain) IBOutlet UILabel *fibPerc;
@property(nonatomic,retain) IBOutlet UILabel *sugPerc;
@property(nonatomic,retain) IBOutlet UILabel *protPerc;
@property(nonatomic,retain) IBOutlet UILabel *carbPerc;
@property(nonatomic,retain) IBOutlet UILabel *calcPerc;
@property(nonatomic,retain) IBOutlet UILabel *ironPerc;
@property(nonatomic,retain) IBOutlet UILabel *vitaPerc;
@property(nonatomic,retain) IBOutlet UILabel *vitePerc;
@property(nonatomic,retain) IBOutlet UILabel *vitcPerc;

@property(nonatomic,retain) IBOutlet UILabel *calProgTxt;
@property(nonatomic,retain) IBOutlet UIProgressView *calProg;
@property(nonatomic,retain) IBOutlet UIProgressView *tfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *sfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *calffatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *mfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *cholProg;

@property (nonatomic, weak) UIColor *progColor;
@property (nonatomic, strong) NSData *myData;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) Food *foodData;
@property (weak, nonatomic) IBOutlet UITextField *txtPicker;

@property (weak, nonatomic) IBOutlet UIButton *btnTodayIntake;



- (void)prog:(UIProgressView*) val1 data:(double) val2;
- (IBAction)AddFoodButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
- (IBAction)EditFood:(id)sender;
- (IBAction)TodaysFoodIntake:(id)sender;

@end
