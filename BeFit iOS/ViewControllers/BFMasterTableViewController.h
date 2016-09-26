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

@interface BFMasterTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSString *uppercaseFirstLetterOfName;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (strong,nonatomic) NSMutableArray *FoodArray;
@property IBOutlet UISearchBar *foodSearchBar;

@end
