//
//  DeviceViewController.m
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "DeviceViewController.h"
#import "AppDelegate.h"
#import "BeFitTracker-Swift.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Fetch the devices from persistent data store
    
    if (self.isFromAddFoodScreen)
    {
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FoodListObject"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != 'Food Library'"];
        [fetchRequest setPredicate:predicate];
        self.devices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        self.devices = [[NSMutableArray alloc] initWithArray:[AppDelegate GetfoodListItems ]];
        [_btnCancel setTitle:@"Back"];
        
        [self.tableView reloadData];
    }
    else
    {
        finalDisplayArray = [[NSMutableArray alloc] initWithObjects:[AppDelegate GetUserFoodLibrary], nil];
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"FoodListObject"];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name != 'Food Library'"];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"name != 'User Food Library'"];
        
        NSArray* arrayOfPred = [[NSArray alloc ] initWithObjects:predicate1,predicate2,nil ];
        NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:arrayOfPred];
        
        [fetchRequest setPredicate:compoundPredicate];
        self.devices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        [finalDisplayArray addObject:self.devices];
        
        
        [self.tableView reloadData];
    }
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (!self.isFromAddFoodScreen)
    {
        sectionNameArray = [NSArray arrayWithObjects:@"User Food Library",@"Custom Food Library", nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.isFromAddFoodScreen)
    {
        return 1;
    }
    else
    {
        return sectionNameArray.count;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFromAddFoodScreen)
    {
        return self.devices.count;
    }
    else
    {
        NSArray* arr = [finalDisplayArray objectAtIndex:section];
        return arr.count;
    }
   
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (self.isFromAddFoodScreen)
    {
        // Configure the cell...
        FoodList *device =(FoodList*) [self.devices objectAtIndex:indexPath.row];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", device.name]];
        
        
        if ([self.selectedFoodLists containsObject:device])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    else
    {
        NSArray* arr = [finalDisplayArray objectAtIndex:indexPath.section] ;
        
        FoodList *device =(FoodList*) [arr objectAtIndex:indexPath.row];
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", device.name]];
        
        return cell;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodList *device =(FoodList*) [self.devices objectAtIndex:indexPath.row];
    if ([device.name isEqualToString:@"User Food Library"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"User Food Library cannot be deleted" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User Food Library cannot be deleted" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//        [alert show];
        return ;
    }
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:device];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.devices removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isFromAddFoodScreen)
    {
        FoodList *device =(FoodList*) [self.devices objectAtIndex:indexPath.row];
        if ([_selectedFoodLists containsObject:device])
        {
            [_selectedFoodLists removeObject:device];
        }
        else
        {
            [_selectedFoodLists addObject:device];
        }
        [self.tableView reloadData];
        
    }
    else
    {
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Food List" message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"View Food Items" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            [self performSegueWithIdentifier:@"segue_foodObjects" sender:self];
            
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Edit food list" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            // OK button tapped.
            
            [self performSegueWithIdentifier:@"UpdateDevice" sender:self];
            
        }]];
        // Present action sheet.
        actionSheet.view.tag = 1;
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
        
       // UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Food List" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"View Food Objects" otherButtonTitles:@"Edit", nil];
       // popup.tag = 1;
       // [popup showInView:self.view];
    }
   
    
    
    
}
//- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    
//    switch (buttonIndex)
//    {
//        case 0:
//        {
//            
//        }
//            break;
//        case 1:
//        {
//            
//        }
//            break;
//        default:
//            break;
//    }
//}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [sectionNameArray objectAtIndex:section];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath* index = [self.tableView indexPathForSelectedRow] ;
    NSArray* arr = [finalDisplayArray objectAtIndex:index.section] ;
    NSManagedObject *selectedDevice = [arr objectAtIndex:[index row]];
    
    if ([[segue identifier] isEqualToString:@"UpdateDevice"])
    {
        DeviceDetailViewController *destViewController = segue.destinationViewController;
        destViewController.device = selectedDevice;

    }
    else if ([[segue identifier] isEqualToString:@"segue_foodObjects"])
    {
        FoodObjectsViewController *destViewController = segue.destinationViewController;
        destViewController.foodListObject = selectedDevice;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    
    if (self.isFromAddFoodScreen)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)OpenModal:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ListView"];
    [self presentViewController:controller animated:YES completion:nil];
}
@end
