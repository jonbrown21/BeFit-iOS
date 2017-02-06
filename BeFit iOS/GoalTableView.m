//
//  PickerTableView.m
//  BeFit iOS
//
//  Created by Jon Brown on 2/17/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "GoalTableView.h"

@implementation GoalTableView

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(itemSelectedGoalAtRow:)]) {
        [self.delegate itemSelectedGoalAtRow:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *buttonTitle = [NSString stringWithFormat:@"%lu", (unsigned long)indexPath.row];
        
        [defaults setObject:buttonTitle forKey:@"goal-name"];
        
        NSLog(@"row %@ selected", buttonTitle);
        
    }
    
    
}

- (void)itemSelectedGoalAtRow:(NSInteger)row
{
    NSLog(@"row %lu selected", (unsigned long)row);
   

}

- (IBAction)cancelPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
