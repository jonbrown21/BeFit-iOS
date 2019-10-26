//
//  FoodObjectsViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class FoodObjectsViewController: UITableViewController {
    //MARK: Properties
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    
    private var items: NSSet?
    private var foodObjectArray: [Food] = []
    private var isForEditing: Bool = false
    private var selectedIndexPath: IndexPath?
    
    var foodListObject: FoodList?
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        title =  foodListObject?.name
        
        if foodListObject?.name == "User Food Library" {
            btnAdd.isEnabled = false
            btnAdd.tintColor = .clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isForEditing = false
        items = foodListObject?.foods
        foodObjectArray = (items?.allObjects as? [Food]) ?? []
        tableView.reloadData()
    }
    
    //MARK: - Private
    
    private func closeAlertview() {
        dismiss(animated: true, completion: nil)
    }
    
    private func deleteFoodItem(at indexPath: IndexPath) {
        guard let context = managedObjectContext else {
            assertionFailure()
            return
        }
        
        let foodName = foodObjectArray[indexPath.row].name
        
        guard let foodObject = AppDelegate.check(forDuplicateFoodItem: foodName)?.first as? Food else {
            assertionFailure()
            return
        }
        
        if foodObject.userDefined?.intValue == 1 {
            foodObjectArray.remove(at: indexPath.row)
            
            foodListObject?.foods = NSSet(array: foodObjectArray)
            
            context.delete(foodObject)
        } else {
            let alertController = UIAlertController(title: "Befit", message: "Default food item cannot be deleted directly from this library", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            present(alertController, animated: true)
            
            //            [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Default food item cannot be deleted directly from this library" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            return
        }
        
        // Remove device from table view
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        do {
            try context.save()
        } catch let error {
            print("Can't Delete!", error.localizedDescription)
            return
        }
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodObjectArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator
        let food = foodObjectArray[indexPath.row]
        cell.textLabel?.text = food.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let context = managedObjectContext else {
            assertionFailure()
            return
        }
        
        if editingStyle == .delete {
            // Delete object from database
            
            if foodListObject?.name == "User Food Library" {
                selectedIndexPath = indexPath
                
                let alertController = UIAlertController(title: "Befit", message: "Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                    self?.deleteFoodItem(at: indexPath)
                })
                
                alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { [weak self] _ in
                    self?.closeAlertview()
                }))
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
                
                // [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]show];
            } else {
                foodObjectArray.remove(at: indexPath.row)
                foodListObject?.foods = NSSet(array: foodObjectArray)
                
                //        [context deleteObject: [foodObjectArray objectAtIndex:indexPath.row]];
                
                // Remove device from table view
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                do {
                    try context.save()
                } catch let error {
                    print("Can't Delete!", error.localizedDescription)
                    return
                }
                
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let food = foodObjectArray[indexPath.row]
            
        if food.userDefined?.intValue == 1 {
                isForEditing = true
                performSegue(withIdentifier: "segue_edit", sender: self)
            } else {
            let alertController = UIAlertController(title: "Befit", message: "Default food item cannot be edited", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
            present(alertController, animated: true)
            
        //        [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Default food item cannot be edited" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            }
    }
    
    @IBAction func AddNewFood(_ sender: AnyObject) {
        performSegue(withIdentifier: "segue_edit", sender: self)
    }
    
    //MARK: - prepareForSegue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segue_edit":
            let indexPath = tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
            if let destViewController = segue.destination as? AddFoodViewController {
                if indexPath.row < foodObjectArray.count {
                    destViewController.foodListObject = foodObjectArray[indexPath.row]
                }
                
                destViewController.isForEditing = isForEditing
            }
        default:
            break
        }
        
        super.prepare(for: segue, sender: sender)
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
}
