//
//  DetailViewController.h
//  BeFit iOS
//
//  Created by Jon on 9/25/16.
//  Copyright © 2016 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"

@interface DetailViewController : UIViewController
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

@property(nonatomic,retain) IBOutlet UILabel *calProgTxt;
@property(nonatomic,retain) IBOutlet UIProgressView *calProg;
@property(nonatomic,retain) IBOutlet UIProgressView *tfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *sfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *calffatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *mfatProg;
@property(nonatomic,retain) IBOutlet UIProgressView *cholProg;

@property (nonatomic, weak) UIColor *progColor;
@property (nonatomic, strong) NSData *myData;

@property (nonatomic, strong) Food *foodData;

- (void)prog:(UIProgressView*) val1 data:(double) val2;

@end
