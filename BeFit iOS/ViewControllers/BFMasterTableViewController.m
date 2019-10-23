//
//  BFMasterTableViewController.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "BFMasterTableViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "AvePurchaseButton.h"
#import "BeFitTracker-Swift.h"

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

-(NSArray*)GetAllFoodItems
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    NSEntityDescription* entity=[NSEntityDescription entityForName:@"FoodObject" inManagedObjectContext:context];
    NSFetchRequest* request=[[NSFetchRequest alloc]init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    [request setEntity:entity];
    NSError* error;
    NSArray* data=[ context executeFetchRequest:request error:&error];
    return data;
}

- (void)setupFetchedResultsController:(NSString*)searchedText

{
    //    NSManagedObjectContext *context = [self managedObjectContext];
    //
    //    Food* list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodObject" inManagedObjectContext:context];
    //    list.name = @"BA Test" ;
    //    list.userDefined = [NSNumber numberWithBool:YES] ;
    //    NSError *error;
    //    [context save:&error];
    //
    //    self.FoodArray = [NSMutableArray arrayWithArray:[self GetAllFoodItems]] ;
    
    
    
    
    // 1 - Decide what Entity you want
    NSString *entityName = @"FoodObject"; // Put your entity name here
    //NSLog(@"Setting up a Fetched Results Controller for the Entity named %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSPredicate *testForTrue = [NSPredicate predicateWithFormat:@"userDefined == %@",[NSNumber numberWithBool:isUserDefinedFoodDisplay]];
    
    NSPredicate *namePred = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@",searchedText];
    
    if (searchedText.length>0)
    {
        NSArray* arrayOfPred = [[NSArray alloc ] initWithObjects:testForTrue,namePred,nil ];
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayOfPred];
        [request setPredicate:compoundPredicate];
        
    }
    else
    {
        [request setPredicate:testForTrue];
    }
    
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
    
    //    self.FoodArray = [NSMutableArray arrayWithCapacity:[self.fetchedResultsController.fetchedObjects count]];
    
    NSLog(@"[self.fetchedResultsController.fetchedObjects count] : %lu",[self.fetchedResultsController.fetchedObjects count]);
    self.FoodArray = [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects] ;
    [self.tableView reloadData];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"Text change - %@",searchText);
    
    [self setupFetchedResultsController:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Cancel clicked");
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search Clicked");
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [AppDelegate ShowLoader];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self setupFetchedResultsController:foodSearchBar.text];
    
    [AppDelegate HideLoader];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + foodSearchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    //    foodSearchBar.showsCancelButton = YES;
    //    [foodSearchBar setShowsCancelButton:YES animated:YES];
    foodSearchBar.placeholder = @"Search Food";
    _busyIndexes = [NSMutableIndexSet new];
    isUserDefinedFoodDisplay = FALSE ;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsScopeBar = YES;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsScopeBar = NO;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    return YES;
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
    
    //    if (section == 0)
    //    {
    //        return @"BeFit Store";
    //    }
    //    if (section == 1)
    //    {
    //        return @"Food Library";
    //    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section ];
    return [sectionInfo name];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sectionCount = [[self.fetchedResultsController sections] count]  ;
    NSLog(@"sectionCount : %ld",(long)sectionCount);
    
    return sectionCount;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    //    if (section == 0)
    //    {
    //        return 2;
    //    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
    //    if (tableView.tag==2)
    //    {
    //        if (section == 0)
    //        {
    //            return 2;
    //        }
    //        if (section == 1)
    //        {
    ////            return [sectionInfo numberOfObjects];
    //            return  self.FoodArray.count ;
    //        }
    //    }
    //   return self.FoodArray.count;
    
    
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
    Food *foodData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([foodData.userDefined boolValue])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        selectedIndexPath = indexPath ;
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Befit"
                                      message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"No"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     NSManagedObjectContext *context = [self managedObjectContext];
                                     [context deleteObject: [self.fetchedResultsController objectAtIndexPath:selectedIndexPath]];
                                     
                                     NSError *error = nil;
                                     if (![context save:&error]) {
                                         NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                                         return;
                                     }
                                     
                                     // Remove device from table view
                                     
                                     //         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                     [self setupFetchedResultsController:foodSearchBar.text];
                                 }];
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
        //[[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]show];
        // Delete object from database
        
        
    }
}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//        
//        
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *NormalCellIdentifier = @"NormalCell";
    //    static NSString *TitleCellIdentifier = @"TitleCell";
    //    static NSString *RestoreCellIdentifier = @"RestoreButton";
    
    NSString *neededCellType;
    //    NSArray *CellTitles = [NSArray arrayWithObjects:@"25,000 Food Database", @"Restore Purchase", nil];
    //    NSArray *CellSubTitles = [NSArray arrayWithObjects:@"Larger Database of Food Items", @"", nil];
    //
    //    if(indexPath.section == 0 && indexPath.row == 0) {
    //        neededCellType = TitleCellIdentifier;
    //    } else if(indexPath.section == 0 && indexPath.row == 1) {
    //        neededCellType = RestoreCellIdentifier;
    //    }else {
    neededCellType = NormalCellIdentifier;
    //    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:neededCellType];
    
    if (cell == nil) {
        
        // create  a cell with some nice defaults
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:neededCellType];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        //        // add a buttons as an accessory and let it respond to touches
        //        AvePurchaseButton* button = [[AvePurchaseButton alloc] initWithFrame:CGRectZero];
        //        [button addTarget:self action:@selector(purchaseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //        cell.accessoryView = button;
        //
        //
        //        //Only add content to cell if it is new
        //        if([neededCellType isEqualToString: TitleCellIdentifier]) {
        //
        //            // configure the cell
        //            cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
        //            cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //
        //            // configure the purchase button in state normal
        //            AvePurchaseButton* button = (AvePurchaseButton*)cell.accessoryView;
        //            button.buttonState = AvePurchaseButtonStateNormal;
        //            button.normalTitle = @"$ 2.99";
        //            button.confirmationTitle = @"BUY";
        //            [button sizeToFit];
        //
        //            // if the item at this indexPath is being "busy" with purchasing, update the purchase
        //            // button's state to reflect so.
        //            if([_busyIndexes containsIndex:indexPath.row] == YES)
        //            {
        //                button.buttonState = AvePurchaseButtonStateProgress;
        //            }
        //
        //        }
        //
        //        //Only add content to cell if it is new
        //        if([neededCellType isEqualToString: RestoreCellIdentifier]) {
        //
        //            // configure the cell
        //            cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
        //            cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        }
        
    }
    
    if([neededCellType isEqualToString: NormalCellIdentifier]) {
        
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        //        Food *foodData = [self.FoodArray objectAtIndex:indexPath.row];
        //        NSLog(@"indexPath : %ld  ===== %ld",(long)indexPath.section,(long)indexPath.row);
        Food *foodData = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = foodData.name;
    }
    
    return cell;
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"detailNews" sender:self];
    
    
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

- (IBAction)SegmentControllerValueChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        isUserDefinedFoodDisplay = FALSE ;
    }
    else{
        //toggle the correct view to be visible
        isUserDefinedFoodDisplay = TRUE ;
    }
    [self setupFetchedResultsController:foodSearchBar.text];
}

- (IBAction)AddFoodButtonTapped:(id)sender
{
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AddFood"];
    [self presentViewController:controller animated:YES completion:nil];
}
- (IBAction)OpenStore:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"BefitStore"];
    [self presentViewController:controller animated:YES completion:nil];
}



@end
