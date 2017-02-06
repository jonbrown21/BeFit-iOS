//
//  PickerTableView.h
//  BeFit iOS
//
//  Created by Jon Brown on 2/17/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoalPickerControllerDelegate <NSObject>

@required
- (void)itemSelectedGoalAtRow:(NSInteger)row;

@end

@interface GoalTableView : UITableViewController


@property (strong, nonatomic) NSArray *tableData;
@property (assign, nonatomic) id <GoalPickerControllerDelegate> delegate;

@end
