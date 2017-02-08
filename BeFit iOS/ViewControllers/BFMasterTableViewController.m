//
//  BFMasterTableViewController.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "BFMasterTableViewController.h"
#import "Food.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "AvePurchaseButton.h"

@interface BFMasterTableViewController ()
{
    NSString *selectedlabel;
    NSMutableIndexSet* _busyIndexes;
}
@end

@implementation BFMasterTableViewController
@synthesize managedObjectContext;
@synthesize FoodArray;
@synthesize searchResults;
@synthesize foodSearchBar;
@synthesize fetchedResultsController = __fetchedResultsController;

- (NSManagedObjectContext *)managedObjectContext
{
    if (!managedObjectContext)
    {
        managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    }
    return managedObjectContext;
    
}

-(void)purchaseButtonTapped:(AvePurchaseButton*)button
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)button.superview];
    NSInteger index = indexPath.row;
    
    // handle taps on the purchase button by
    switch(button.buttonState)
    {
        case AvePurchaseButtonStateNormal:
            // progress -> confirmation
            [button setButtonState:AvePurchaseButtonStateConfirmation animated:YES];
            break;
            
        case AvePurchaseButtonStateConfirmation:
            // confirmation -> "purchase" progress
            [_busyIndexes addIndex:index];
            [button setButtonState:AvePurchaseButtonStateProgress animated:YES];
            break;
            
        case AvePurchaseButtonStateProgress:
            // progress -> back to normal
            [_busyIndexes removeIndex:index];
            [button setButtonState:AvePurchaseButtonStateNormal animated:YES];
            break;
    }
}



- (void)setupFetchedResultsController

{
    
    // 1 - Decide what Entity you want
    NSString *entityName = @"FoodObject"; // Put your entity name here
    //NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    
    //    NSString *theFrameThatWasTouchedwithTheUsersFinger = [[NSString alloc]init];
    //    theFrameThatWasTouchedwithTheUsersFinger = note;
    
    
    // 3 - Filter it if you want
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", @"Burger"];
    
    //[request setPredicate:predicate];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // 5 - Fetch it
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"uppercaseFirstLetterOfName"
                                                                                   cacheName:nil];
    
    
    
    [self.fetchedResultsController performFetch:nil];
    
    self.FoodArray = [NSMutableArray arrayWithCapacity:[self.fetchedResultsController.fetchedObjects count]];
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
    
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + foodSearchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    _busyIndexes = [NSMutableIndexSet new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (tableView.tag==2)
    {
        if (section == 0)
        {
            return @"BeFit Store";
        }
        if (section == 1)
        {
            return @"Food Library";
        }
    }
    return @"";
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    if (tableView.tag==2)
    {
        if (section == 0)
        {
            return 2;
        }
        if (section == 1)
        {
            return [sectionInfo numberOfObjects];
        }
    }
    return 0;

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section==0){
        return 50.0f;
    }
    else if(section==1){
        return 50.0f;
    }
    else{
        return 50.0f;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        return YES;

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.FoodArray objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.FoodArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    static NSString *NormalCellIdentifier = @"NormalCell";
    static NSString *TitleCellIdentifier = @"TitleCell";
    static NSString *RestoreCellIdentifier = @"RestoreButton";
    
    NSString *neededCellType;
    NSArray *CellTitles = [NSArray arrayWithObjects:@"25,000 Food Database", @"Restore Purchase", nil];
    NSArray *CellSubTitles = [NSArray arrayWithObjects:@"Larger Database of Food Items", @"", nil];
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        neededCellType = TitleCellIdentifier;
    } else if(indexPath.section == 0 && indexPath.row == 1) {
        neededCellType = RestoreCellIdentifier;
    }else {
        neededCellType = NormalCellIdentifier;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:neededCellType];
    
    if (cell == nil) {
        
        // create  a cell with some nice defaults
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:neededCellType];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        // add a buttons as an accessory and let it respond to touches
        AvePurchaseButton* button = [[AvePurchaseButton alloc] initWithFrame:CGRectZero];
        [button addTarget:self action:@selector(purchaseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        
        
        //Only add content to cell if it is new
        if([neededCellType isEqualToString: TitleCellIdentifier]) {
            
            // configure the cell
            cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
            
            // configure the purchase button in state normal
            AvePurchaseButton* button = (AvePurchaseButton*)cell.accessoryView;
            button.buttonState = AvePurchaseButtonStateNormal;
            button.normalTitle = @"$ 2.99";
            button.confirmationTitle = @"BUY";
            [button sizeToFit];
            
            // if the item at this indexPath is being "busy" with purchasing, update the purchase
            // button's state to reflect so.
            if([_busyIndexes containsIndex:indexPath.row] == YES)
            {
                button.buttonState = AvePurchaseButtonStateProgress;
            }
            
        }

        //Only add content to cell if it is new
        if([neededCellType isEqualToString: RestoreCellIdentifier]) {
            
            // configure the cell
            cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
            
        }
        
    }
    
    if([neededCellType isEqualToString: NormalCellIdentifier]) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        Food *foodData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = foodData.name;
    }
    
    return cell;
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag==2)
    {
        if (indexPath.section == 0)
        {
            NSString *selectedValue = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            NSLog(@"%@", selectedValue);

        }
        if (indexPath.section == 1)
        {
            [self performSegueWithIdentifier:@"detailNews" sender:self];
        }
    }

   
}
#pragma mark prepareForSegue Functions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailNews"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *destViewController = segue.destinationViewController;
        destViewController.foodData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    }
    
}

- (IBAction)OpenModal:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FoodList"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
