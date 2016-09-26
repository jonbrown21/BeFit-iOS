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

@interface BFMasterTableViewController ()
{
    NSString *selectedlabel;
}
@end

@implementation BFMasterTableViewController
@synthesize managedObjectContext;
@synthesize FoodArray;
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
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections] count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [FoodArray count];
    } else {
        return [sectionInfo numberOfObjects];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Food *info = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        info = [FoodArray objectAtIndex:indexPath.row];
        
    } else {
        
        info = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    }
    
    cell.textLabel.text = info.name;
    
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    Food *info = [FoodArray objectAtIndex:indexPath.item];
    
    selectedlabel = info.name;
    
    [self performSegueWithIdentifier:@"detailNews" sender:self];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"detailNews"]) {
        DetailViewController *detailNews = [segue destinationViewController];
        detailNews.selectedlabel = selectedlabel;
    }
    
    [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
}

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSArray *fetchedData = [self.fetchedResultsController fetchedObjects];
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.FoodArray removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
    FoodArray = [NSMutableArray arrayWithArray:[fetchedData filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
