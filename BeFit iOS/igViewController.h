//
//  igViewController.h
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//


#import <UIKit/UIKit.h>

@class igViewController;

@protocol igViewControllerDelegate <NSObject>

- (void)secondViewController:(igViewController *)secondViewController didEnterText:(NSString *)text;

@end


@interface igViewController : UIViewController
{
    __unsafe_unretained id<igViewControllerDelegate> delegate;
}
@property(nonatomic,assign)id<igViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *highlightView;
@property (weak, nonatomic) IBOutlet UILabel *barcode_view;
@property (weak, nonatomic) IBOutlet UILabel *back;

@end
