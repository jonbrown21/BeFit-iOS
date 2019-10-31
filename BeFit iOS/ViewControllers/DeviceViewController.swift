//
//  DeviceViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DeviceViewControllerDelegate: class {
    func valueChanged(selectedFoodLists: [FoodList])
}

class DeviceViewController: UITableViewController,
DeviceDetailViewControllerDelegate {
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    
    private var finalDisplayArray: [[FoodList]] = []
    private var sectionNameArray: [String] = []
    
    private var devices: [FoodList]?
    var isFromAddFoodScreen: Bool = false
    var selectedFoodLists: [FoodList] = []
    weak var delegate: DeviceViewControllerDelegate?
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch the devices from persistent data store
        
        reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    private func reloadData() {
        guard let managedObjectContext = managedObjectContext else {
            assertionFailure()
            return
        }
        
        if isFromAddFoodScreen {
            devices = AppDelegate.getfoodListItems()
            btnCancel.title = "Back"
        } else {
            sectionNameArray = ["User Food Library", "Custom Food Library"]
            finalDisplayArray = [AppDelegate.getUserFoodLibrary()]
            
            let fetchRequest = FoodList.fetchRequest() as NSFetchRequest<FoodList>
            let predicate1 = NSPredicate(format: "name != 'Food Library'")
            let predicate2 = NSPredicate(format: "name != 'User Food Library'")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            
            fetchRequest.predicate = compoundPredicate
            let devices = try? managedObjectContext.fetch(fetchRequest)
            
            if let dev = devices {
                finalDisplayArray.append(dev)
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFromAddFoodScreen {
            return 1
        } else {
            return sectionNameArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromAddFoodScreen {
            return devices?.count ?? 0
        } else {
            let arr = finalDisplayArray[section]
            return arr.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if isFromAddFoodScreen {
            guard let devices = devices else {
                return cell
            }
            
            // Configure the cell...
            let device = devices[indexPath.row]
            cell.textLabel?.text = device.name ?? ""
            
            if selectedFoodLists.contains(device) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else {
            let arr = finalDisplayArray[indexPath.section]
            let device = arr[indexPath.row]
            cell.textLabel?.text = device.name ?? ""
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let lists: [FoodList]
        if let dev = devices {
            lists = dev
        } else {
            lists = finalDisplayArray[indexPath.section]
        }
        
        let list = lists[indexPath.row]
        
        if list.name == "User Food Library" {
            let alertController = UIAlertController(title: "Error", message: "User Food Library cannot be deleted", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"User Food Library cannot be deleted" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            //        [alert show];
            return
        }
        
        guard let context = managedObjectContext else {
            return
        }
        
        switch editingStyle {
        case .delete:
            context.delete(list)
            
            do {
                try context.save()
            } catch let error {
                print("Can't Delete!", error.localizedDescription)
                return
            }
            
            if devices != nil {
                devices?.remove(at: indexPath.row)
            } else {
                finalDisplayArray[indexPath.section].remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isFromAddFoodScreen {
            guard let devices = devices else {
                return
            }
            
            let device = devices[indexPath.row]
            if let idx = selectedFoodLists.firstIndex(of: device) {
                selectedFoodLists.remove(at: idx)
            } else {
                selectedFoodLists.append(device)
            }
            
            delegate?.valueChanged(selectedFoodLists: selectedFoodLists)
            tableView.reloadData()
        } else {
            let foodList = finalDisplayArray[indexPath.section][indexPath.row]
            
            let actionSheet = UIAlertController(title: "Food List", message: "What would you like to do?", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            actionSheet.addAction(UIAlertAction(title: "View Food Items", style: .default) { [weak self] _ in
                self?.performSegue(withIdentifier: "segue_foodObjects", sender: foodList)
            })
            
            if foodList.name != "User Food Library" {
                actionSheet.addAction(UIAlertAction(title: "Edit food list", style: .default) { [weak self] _ in
                    self?.performSegue(withIdentifier: "UpdateDevice", sender: foodList)
                })
            }
            
            // Present action sheet.
            actionSheet.view.tag = 1;
            
            present(actionSheet, animated: true)
            
            // UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Food List" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"View Food Objects" otherButtonTitles:@"Edit", nil];
            // popup.tag = 1;
            // [popup showInView:self.view];
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < sectionNameArray.count else {
            return nil
        }
        
        return sectionNameArray[section]
    }
    
    //MARK: - Private
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let navigationController as UINavigationController:
            if let deviceDetail = navigationController.topViewController as? DeviceDetailViewController {
                deviceDetail.device = sender as? FoodList
                deviceDetail.delegate = self
            }
            
        case let foodObjects as FoodObjectsViewController:
            foodObjects.foodListObject = sender as? FoodList
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: sender)
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
    
    @IBAction func cancel(_ sender: AnyObject) {
        if isFromAddFoodScreen {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func OpenModal(_ sender: AnyObject) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "ListView") {
            present(controller, animated: true)
        }
    }
    
    //MARK: - DeviceDetailViewControllerDelegate
    
    func deviceDetailViewControllerDidSave() {
        reloadData()
    }
}
