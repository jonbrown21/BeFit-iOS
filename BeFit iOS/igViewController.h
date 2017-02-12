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

@end
