//
//  DeviceViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

protocol DeviceViewControllerDelegate: class {
    func valueChanged(selectedFoodLists: [FoodList])
}

class DeviceViewController: UITableViewController {
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
        
        guard let managedObjectContext = managedObjectContext else {
            assertionFailure()
            return
        }
        
        if isFromAddFoodScreen {
            let fetchRequest = FoodList.fetchRequest() as NSFetchRequest<FoodList>
            fetchRequest.predicate = NSPredicate(format: "name != 'Food Library'")
            devices = try? managedObjectContext.fetch(fetchRequest)
            
            devices = AppDelegate.getfoodListItems() as? [FoodList]
            btnCancel.title = "Back"
            
            tableView.reloadData()
        } else {
            finalDisplayArray = [AppDelegate.getUserFoodLibrary() as! [FoodList]]
            
            let fetchRequest = FoodList.fetchRequest() as NSFetchRequest<FoodList>
            let predicate1 = NSPredicate(format: "name != 'Food Library'")
            let predicate2 = NSPredicate(format: "name != 'User Food Library'")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
            
            fetchRequest.predicate = compoundPredicate
            devices = try? managedObjectContext.fetch(fetchRequest)
            
            if let dev = devices {
                finalDisplayArray.append(dev)
            }
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        if !isFromAddFoodScreen {
            sectionNameArray = ["User Food Library", "Custom Food Library"]
        }
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
        
        // Configure the cell...
        if isFromAddFoodScreen {
            guard let devices = devices else {
                return cell
            }
            
            // Configure the cell...
            let device = devices[indexPath.row]
            cell.textLabel?.text = String(format: "%@", device.name ?? "")
            
            if selectedFoodLists.contains(device) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else {
            let arr = finalDisplayArray[indexPath.section]
            let device = arr[indexPath.row]
            cell.textLabel?.text = String(format: "%@", device.name ?? "")
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let devices = devices else {
            return
        }
        
        let device = devices[indexPath.row]
        
        if device.name == "User Food Library" {
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
            context.delete(device)
            
            do {
                try context.save()
            } catch let error {
                print("Can't Delete! %@", error.localizedDescription)
                return
            }
            
            self.devices?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            let actionSheet = UIAlertController(title: "Food List", message: "What would you like to do?", preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            
            actionSheet.addAction(UIAlertAction(title: "View Food Items", style: .destructive) { [weak self] _ in
                self?.performSegue(withIdentifier: "segue_foodObjects", sender: self)
            })
            
            actionSheet.addAction(UIAlertAction(title: "Edit food list", style: .default) { [weak self] _ in
                self?.performSegue(withIdentifier: "UpdateDevice", sender: self)
            })
            
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
        let index = tableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        
        guard index.section < finalDisplayArray.count else {
            return
        }
        
        let arr = finalDisplayArray[index.section]
        
        guard index.row < arr.count else {
            return
        }
        
        let selectedDevice = arr[index.row]
        
        switch segue.identifier {
        case "UpdateDevice":
            if let destViewController = segue.destination as? DeviceDetailViewController {
                destViewController.device = selectedDevice
            }
            
        case "segue_foodObjects":
            if let destViewController = segue.destination as? FoodObjectsViewController {
                destViewController.foodListObject = selectedDevice
            }
            
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
}
