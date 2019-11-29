//
//  FoodObjectsViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FoodObjectsViewController: UITableViewController {
    //MARK: Properties
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    
    private var foodObjectArray: [Food] = []
    
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
        title = foodListObject?.name
        
        if foodListObject?.name == "User Food Library" {
            btnAdd.isEnabled = false
            btnAdd.tintColor = .clear
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        foodObjectArray = (foodListObject?.foods?.allObjects as? [Food]) ?? []
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
        
        guard let foodObject = AppDelegate.check(forDuplicateFoodItem: foodName ?? "").first else {
            assertionFailure()
            return
        }
        
        if foodObject.userDefined?.intValue == 1 {
            foodObjectArray.remove(at: indexPath.row)
            foodListObject?.removeFromFoods(foodObject)
            
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
                let alertController = UIAlertController(title: "Befit", message: "Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                    self?.deleteFoodItem(at: indexPath)
                })
                
                alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.present(alertController, animated: true)
                }
                
                // [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]show];
            } else {
                let food = foodObjectArray.remove(at: indexPath.row)
                foodListObject?.removeFromFoods(food)
                
                // Remove device from table view
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                do {
                    try context.save()
                } catch let error {
                    print("Can't Delete!", error.localizedDescription)
                    return
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let food = foodObjectArray[indexPath.row]
        
        if food.userDefined?.intValue == 1 {
            performSegue(withIdentifier: "segue_edit", sender: food)
        } else {
            let alertController = UIAlertController(title: "Befit", message: "Default food item cannot be edited", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            present(alertController, animated: true)
            
            //        [[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Default food item cannot be edited" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
    }
    
    @IBAction private func AddNewFood(_ sender: AnyObject) {
        performSegue(withIdentifier: "segue_edit", sender: self)
    }
    
    //MARK: - prepareForSegue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let addFoodViewController as AddFoodViewController:
            let food = sender as? Food
            addFoodViewController.foodListObject = food
            addFoodViewController.selectedListArray = [foodListObject].compactMap { $0 }
            addFoodViewController.isForEditing = food?.userDefined?.intValue == 1
            
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
