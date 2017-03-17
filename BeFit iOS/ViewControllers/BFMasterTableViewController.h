//
//  BFMasterTableViewController.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Food.h"
#import "FoodList.h"

@interface BFMasterTableViewController : UIViewController <NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
{
    BOOL isUserDefinedFoodDisplay;
    NSIndexPath* selectedIndexPath;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSMutableArray *FoodArray;
@property (strong,nonatomic) NSArray *searchResults;
@property IBOutlet UISearchBar *foodSearchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)SegmentControllerValueChanged:(id)sender;

- (IBAction)AddFoodButtonTapped:(id)sender;
@end
