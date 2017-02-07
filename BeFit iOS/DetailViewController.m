//
//  DetailViewController.m
//  BeFit iOS
//
//  Created by Jon on 9/25/16.
//  Copyright © 2016 Jon Brown. All rights reserved.
//

#import "DetailViewController.h"
#import "CW.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *wview;
@property (strong, nonatomic) WKWebView *webview;
@property (strong) CWLineChart* lineChart;
@property (strong) CWBarChart* barChart;
@property (strong) CWPieChart* pieChart;
@end

@implementation DetailViewController
@synthesize lablView, selectedlabel, foodData, calView, servingSize, fatView, satfatView, polyfatView, monofatView, fatCals, cholView, sodView, fiberView, calProg, calProgTxt, progColor, sugarView, protView, carbsView, calcView, ironView, transView, vitaView, vitcView, viteView, tfatProg, tfatPerc, calPerc, sfatPerc, sfatProg, calffatProg, pfatPerc;

- (NSInteger) random:(NSInteger) max {
    return (NSInteger)arc4random_uniform((u_int32_t)max);
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


- (void)addDoughnut {
    
    NSArray *recipePhotos = [NSArray arrayWithObjects:@"Calories", @"Total Fat", nil];
    
    NSArray *recipieData = [NSArray arrayWithObjects:@(foodData.caloriesFloatValuePerc).stringValue, @(foodData.totalFatPercentfloat).stringValue, nil];
    
    NSArray *colorData = [NSArray arrayWithObjects:[CWColors sharedColors].colors[CWCAsbestos], [CWColors sharedColors].colors[CWCPeterRiver], [CWColors sharedColors].colors[CWCMidnightBlue], [CWColors sharedColors].colors[CWCSunFlower], [CWColors sharedColors].colors[CWCOrange], [CWColors sharedColors].colors[CWCAmethyst], [CWColors sharedColors].colors[CWCConcrete], nil];
    
    NSMutableArray* data = [NSMutableArray array];
    for( int i = 0; i < [recipieData count]; ++i )
    {
        id object1 = [recipieData objectAtIndex:i];
        id object2 = [recipePhotos objectAtIndex:i];
        id object3 = [colorData objectAtIndex:i];
        
        CWSegmentData* segment = [[CWSegmentData alloc] init];
        segment.value = object1;
        segment.label = [NSString stringWithFormat:@"%@", object2];
        CWColor* c1 = object3;
        CWColor* c2 = [c1 colorWithAlphaComponent:0.8f];
        segment.color = c2;
        segment.highlight = c1;
        segment.label = [NSString stringWithFormat:@"%@",segment.label];
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
    [self.wview addSubview:webview];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(webview);
    [self.wview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]|" options:0 metrics:nil views:viewsDictionary]];
    [self.wview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webview]|" options:0 metrics:nil views:viewsDictionary]];
    
    
    self.webview = webview;
    NSString *resourcesPath = [[NSBundle mainBundle] resourcePath];
    NSString *htmlPath = [resourcesPath stringByAppendingString:@"/cw.html"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:htmlPath]]];
    
    [webview setOpaque:NO];
    webview.backgroundColor = [UIColor clearColor];
    webview.scrollView.scrollEnabled = false;
    webview.multipleTouchEnabled = NO;
    
    self.title = foodData.name;
    
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
    sfatPerc.text = foodData.saturatedFatPercent;
    pfatPerc.text = foodData.polyFatValuePerc;
    
    // Progress Bar Code
    
    [self prog:calProg data:foodData.caloriesFloatValuePerc];
    [self prog:tfatProg data:foodData.totalFatPercentfloat];
    [self prog:sfatProg data:foodData.saturatedFatPercentFloat];
    [self prog:calffatProg data:foodData.calfromFatValuePercFloat];
    
    //UIColor *redcolor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
    UIColor *buttColor = [UIColor colorWithRed:0.18 green:0.80 blue:0.44 alpha:1.0];
    //UIColor *greyColor = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
    
    [ self makeButton:_Add color:buttColor ];
    
    CGFloat time1 = 3.49;
    CGFloat time2 = 8.13;
    
    // Delay 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat newTime = time1 + time2;
        NSLog(@"New time: %f", newTime);
        [self addDoughnut];
    });
    
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
