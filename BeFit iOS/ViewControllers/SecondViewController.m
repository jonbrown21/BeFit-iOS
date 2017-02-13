//
//  SecondViewController.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "SecondViewController.h"
#import "CW.h"

@interface SecondViewController ()

@property (weak, nonatomic) IBOutlet UIView *wview;
@property (strong, nonatomic) WKWebView *webview;
@property (strong) CWLineChart* lineChart;
@property (strong) CWBarChart* barChart;
@property (strong) CWPieChart* pieChart;

@end

@implementation SecondViewController

- (NSInteger) random:(NSInteger) max {
    return (NSInteger)arc4random_uniform((u_int32_t)max);
}

- (void)addLine {
    NSArray* labels = @[@"A",@"B",@"C",@"D"];
    NSMutableArray* datasets = [NSMutableArray array];
    for(NSInteger i = 1; i < 4; i++) {
        CWPointDataSet* ds = [[CWPointDataSet alloc] initWithData:@[@([self random:100]),@([self random:100]),@([self random:100]),@([self random:100])]];
        ds.label = [NSString stringWithFormat:@"Label %ld",i];
        CWColor* c1 = [[CWColors sharedColors] pickColor];
        CWColor* c2 = [c1 colorWithAlphaComponent:0.5f];
        ds.fillColor = c2;
        ds.strokeColor = c1;
        [datasets addObject:ds];
    }
    
    CWLineChartData* lcd = [[CWLineChartData alloc] initWithLabels:labels andDataSet:datasets];
    self.lineChart = [[CWLineChart alloc] initWithWebView:self.webview name:@"LineChart1" width:300 height:200 data:lcd options:nil];
    [self.lineChart addChart];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationbar.delegate = self;
    
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
    
    CGFloat time1 = 3.49;
    CGFloat time2 = 8.13;
    
    // Delay 2 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat newTime = time1 + time2;
        NSLog(@"New time: %f", newTime);
        [self addLine];
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

@end
