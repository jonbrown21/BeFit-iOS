//
//  PickerTableView.h
//  BeFit iOS
//
//  Created by Jon Brown on 2/17/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LifePickerControllerDelegate <NSObject>

@required
- (void)itemSelectedLifestyleAtRow:(NSInteger)row;

@end

@interface LifestyleTableView : UITableViewController


@property (strong, nonatomic) NSArray *tableData;
@property (assign, nonatomic) id <LifePickerControllerDelegate> delegate;

@end
