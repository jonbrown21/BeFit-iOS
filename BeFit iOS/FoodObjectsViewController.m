//
//  FoodObjectsViewController.m
//  BeFit iOS
//
//  Created by Satinder Singh on 2/17/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "FoodObjectsViewController.h"

@interface FoodObjectsViewController ()

@end

@implementation FoodObjectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title =  [self.foodListObject valueForKey:@"name"] ;
   
    
    if ([[self.foodListObject valueForKey:@"name"] isEqualToString:@"User Food Library"])
    {
        _btnAdd.enabled = FALSE ;
        [_btnAdd setTintColor:[UIColor clearColor ]] ;
    }
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    isForEditing = FALSE ;
    items = [self.foodListObject valueForKey:@"foods"] ;
    foodObjectArray = [NSMutableArray arrayWithArray:[items allObjects]];
    [self.tableView reloadData];
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return foodObjectArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Configure the cell...
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Food* food = [foodObjectArray objectAtIndex:indexPath.row];
    cell.textLabel.text = food.name ;
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)closeAlertview
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        
        if ([[self.foodListObject valueForKey:@"name"] isEqualToString:@"User Food Library"])
        {
            selectedIndexPath = indexPath ;
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                NSManagedObjectContext *context = [self managedObjectContext];
                Food* foodObject = [foodObjectArray objectAtIndex:selectedIndexPath.row] ;
                NSString* foodName = foodObject.name ;
                foodObject = [AppDelegate CheckForDuplicateFoodItem:foodName][0];
                
                if (foodObject.userDefined.boolValue == TRUE)
                {
                    [foodObjectArray removeObjectAtIndex:selectedIndexPath.row];
                    
                    NSSet *distinctSet = [NSSet setWithArray:foodObjectArray];
                    
                    [self.foodListObject setValue:distinctSet forKey:@"foods"];
                    
                    [context deleteObject:foodObject];
                }
                else
                {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Befit" message:@"Default food item cannot be deleted directly from this library" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                    //            [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Default food item cannot be deleted directly from this library" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                    return ;
                }
                NSError *error = nil;
                if (![context save:&error]) {
                    NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                    return;
                }
                
                // Remove device from table view
                
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self closeAlertview];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self presentViewController:alertController animated:YES completion:nil];
            });

            
            
           // [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]show];
           
            
        }
        else
        {
            [foodObjectArray removeObjectAtIndex:indexPath.row];
            
            NSSet *distinctSet = [NSSet setWithArray:foodObjectArray];
            
            [self.foodListObject setValue:distinctSet forKey:@"foods"];
            //        [context deleteObject: [foodObjectArray objectAtIndex:indexPath.row]];
            
            NSError *error = nil;
            if (![context save:&error]) {
                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
                return;
            }
            
            // Remove device from table view
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
//            Food* foodObject = [foodObjectArray objectAtIndex:indexPath.row] ;
//            
//            NSString* foodName = foodObject.name ;
//            
//            [foodObjectArray removeObjectAtIndex:indexPath.row];
//            
//            NSSet *distinctSet = [NSSet setWithArray:foodObjectArray];
//            
//            [self.foodListObject setValue:distinctSet forKey:@"foods"];
//            //        [context deleteObject: [foodObjectArray objectAtIndex:indexPath.row]];
//            
//            foodObject = [AppDelegate CheckForDuplicateFoodItem:foodName][0];
//            
//            NSSet* newFoodSet = foodObject.foodListsBelongTo ;
//            
//            NSArray* newFoodListArray = [NSArray arrayWithArray:[newFoodSet allObjects]];
//            
//            BOOL isItemFound = FALSE ;
//            FoodList* defaultLibrary ;
//            
//            for (int iCount = 0 ; iCount < newFoodListArray.count; iCount++)
//            {
//                FoodList* new_list = [newFoodListArray objectAtIndex:iCount] ;
//                if ([new_list.name isEqualToString:@"User Food Library"])
//                {
//                    isItemFound = true ;
//                }
//                else if ([new_list.name isEqualToString:@"Food Library"])
//                {
//                    isItemFound = true ;
//                    defaultLibrary = new_list ;
//                }
//            }
//            if (newFoodListArray.count == 1 && isItemFound == TRUE)
//            {
//                foodObject.foodListsBelongTo = [NSSet new] ;
//            }
//            else if ((defaultLibrary && isItemFound == TRUE) && newFoodListArray.count == 2)
//            {
//                foodObject.foodListsBelongTo = [NSSet setWithObject:defaultLibrary] ;
//            }
//            
//            NSError *error = nil;
//            if (![context save:&error]) {
//                NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
//                return;
//            }
//            
//            // Remove device from table view
//            
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
       
       
        
        
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Food* food = [foodObjectArray objectAtIndex:indexPath.row];
    
    if (food.userDefined.boolValue)
    {
        isForEditing = TRUE ;
        [self performSegueWithIdentifier:@"segue_edit" sender:self];
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Befit" message:@"Default food item cannot be edited" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Default food item cannot be edited" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
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

- (IBAction)AddNewFood:(id)sender
{
    [self performSegueWithIdentifier:@"segue_edit" sender:self];
}
#pragma mark prepareForSegue Functions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_edit"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AddFoodViewController *destViewController = segue.destinationViewController;
        if (foodObjectArray.count > 0)
        {
            destViewController.foodListObject = [foodObjectArray objectAtIndex:indexPath.row];
        }
        
        destViewController.isForEditing = isForEditing ;
        
    }
    
}

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


@end
