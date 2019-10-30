//
//  BFMasterTableViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/28/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BFMasterTableViewController: UIViewController,
    NSFetchedResultsControllerDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
UISearchBarDelegate {
    //MARK: Properties
    @IBOutlet weak var foodSearchBar: UISearchBar!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var isUserDefinedFoodDisplay: Bool = false
    private var selectedIndexPath: IndexPath?
    private var selectedlabel: String?
    private var busyIndexes: IndexSet = IndexSet()
    
    private var fetchedResultsController: NSFetchedResultsController<Food>?
    //private var foodArray: [Food] = []
    //private var searchResults: [Food] = []
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: Methods
    
    func purchaseButtonTapped(_ button: AvePurchaseButton) {
        guard let indexPath = (button.superview as? UITableViewCell).flatMap({ tableView.indexPath(for: $0) }) else {
            return
        }
        
        let index = indexPath.row
        
        // handle taps on the purchase button by
        switch button.buttonState {
        case .normal:
            // progress -> confirmation
            button.setButtonState(.confirmation, animated: true)
            
        case .confirmation:
            // confirmation -> "purchase" progress
            busyIndexes.insert(index)
            button.setButtonState(.progress, animated: true)
            
        case .progress:
            // progress -> back to normal
            busyIndexes.remove(index)
            button.setButtonState(.normal, animated: true)
            
        @unknown default:
            break
        }
    }
    
    func getAllFoodItems() -> [Food] {
        guard let context = managedObjectContext else {
            assertionFailure()
            return []
        }
        
        let request = Food.fetchRequest() as NSFetchRequest<Food>
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return (try? context.fetch(request)) ?? []
    }
    
    func setupFetchedResultsController(_ searchedText: String) {
        //    NSManagedObjectContext *context = [self managedObjectContext];
        //
        //    Food* list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodObject" inManagedObjectContext:context];
        //    list.name = @"BA Test" ;
        //    list.userDefined = [NSNumber numberWithBool:YES] ;
        //    NSError *error;
        //    [context save:&error];
        //
        //    self.FoodArray = [NSMutableArray arrayWithArray:[self GetAllFoodItems]] ;
        
        guard let context = managedObjectContext else {
            assertionFailure()
            return
        }
        
        // 1 - Decide what Entity you want
        let request = Food.fetchRequest() as NSFetchRequest<Food>
        let testForTrue = NSPredicate(format: "userDefined == %@", NSNumber(value: isUserDefinedFoodDisplay))
        let namePred = NSPredicate(format: "name CONTAINS[cd] %@", searchedText)
        
        if !searchedText.isEmpty {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [testForTrue, namePred])
            request.predicate = compoundPredicate
        } else {
            request.predicate = testForTrue
        }
        
        //    NSString *theFrameThatWasTouchedwithTheUsersFinger = [[NSString alloc]init];
        //    theFrameThatWasTouchedwithTheUsersFinger = note;
        
        
        // 3 - Filter it if you want
        
        //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", @"Burger"];
        
        //[request setPredicate:predicate];
        
        // 4 - Sort it if you want
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare))]
        
        
        // 5 - Fetch it
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "uppercaseFirstLetterOfName", cacheName: nil)
        try? fetchedResultsController?.performFetch()
        
        //    self.FoodArray = [NSMutableArray arrayWithCapacity:[self.fetchedResultsController.fetchedObjects count]];
        
        print("fetchedResultsController.fetchedObjects.count:", fetchedResultsController?.fetchedObjects?.count ?? 0)
        //foodArray = fetchedResultsController?.fetchedObjects ?? []
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Text change -", searchText)
        
        setupFetchedResultsController(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel clicked")
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search Clicked")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.showLoader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupFetchedResultsController(foodSearchBar.text ?? "")
        AppDelegate.hideLoader()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var newBounds = tableView.bounds
        newBounds.origin.y = newBounds.origin.y + foodSearchBar.bounds.size.height
        tableView.bounds = newBounds
        //    foodSearchBar.showsCancelButton = YES;
        //    [foodSearchBar setShowsCancelButton:YES animated:YES];
        foodSearchBar.placeholder = "Search Food"
        busyIndexes = IndexSet()
        isUserDefinedFoodDisplay = false
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = true
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(true, animated: true)
        
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsScopeBar = false
        searchBar.sizeToFit()
        searchBar.setShowsCancelButton(false, animated: true)
        
        return true
    }
    
    //MARK: - Table view data source
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return UILocalizedIndexedCollation.current().sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return UILocalizedIndexedCollation.current().section(forSectionIndexTitle: index)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController?.sections?[section]
        return sectionInfo?.name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCount = fetchedResultsController?.sections?.count ?? 0
        print("sectionCount:", sectionCount)
        
        return sectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        
        //    if (section == 0)
        //    {
        //        return 2;
        //    }
        let sectionInfo = fetchedResultsController?.sections?[section]
        return sectionInfo?.numberOfObjects ?? 0
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50.0
        } else if section == 1 {
            return 50.0
        } else {
            return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let foodData = fetchedResultsController?.object(at: indexPath) else {
            return false
        }
        
        if foodData.userDefined?.intValue == 1 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            selectedIndexPath = indexPath
            
            let alert = UIAlertController(title: "Befit", message: "Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .default) { [weak alert] _ in
                alert?.dismiss(animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                guard let context = self?.managedObjectContext,
                    let fetchedResultsController = self?.fetchedResultsController else {
                        return
                }
                
                context.delete(fetchedResultsController.object(at: indexPath))
                
                do {
                    try context.save()
                } catch let error {
                    print("Can't Delete!", error.localizedDescription)
                    return
                }
                
                // Remove device from table view
                
                //         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                self?.setupFetchedResultsController(self?.foodSearchBar.text ?? "")
            })
            
            present(alert, animated: true)
            
            //[[[UIAlertView alloc] initWithTitle:@"Befit" message:@"Food item deleted from User Food Library will remove it from all other libraries. Would you like to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil]show];
            // Delete object from database
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let NormalCellIdentifier = "NormalCell"
        //    static NSString *TitleCellIdentifier = @"TitleCell";
        //    static NSString *RestoreCellIdentifier = @"RestoreButton";
        
        let neededCellType = NormalCellIdentifier
        //    NSArray *CellTitles = [NSArray arrayWithObjects:@"25,000 Food Database", @"Restore Purchase", nil];
        //    NSArray *CellSubTitles = [NSArray arrayWithObjects:@"Larger Database of Food Items", @"", nil];
        //
        //    if(indexPath.section == 0 && indexPath.row == 0) {
        //        neededCellType = TitleCellIdentifier;
        //    } else if(indexPath.section == 0 && indexPath.row == 1) {
        //        neededCellType = RestoreCellIdentifier;
        //    }
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: neededCellType)
        
        if cell == nil {
            // create  a cell with some nice defaults
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: neededCellType)
            cell.layoutMargins = .zero
            cell.separatorInset = .zero
            cell.detailTextLabel?.textColor = UIColor.gray
            
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
        
        switch neededCellType {
        case NormalCellIdentifier:
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
            
            //        Food *foodData = [self.FoodArray objectAtIndex:indexPath.row];
            //        NSLog(@"indexPath : %ld  ===== %ld",(long)indexPath.section,(long)indexPath.row);
            let foodData = fetchedResultsController?.object(at: indexPath)
            cell.textLabel?.text = foodData?.name
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailNews", sender: self)
    }
    
    //MARK: - prepareForSegue Functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailNews":
            guard let indexPath = tableView.indexPathForSelectedRow,
                let fetchedResultsController = fetchedResultsController else {
                    break
            }
            
            if let destViewController = segue.destination as? DetailViewController {
                destViewController.foodData = fetchedResultsController.object(at: indexPath)
            }
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func OpenModal(_ sender: AnyObject) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "FoodList") else {
            return
        }
        
        present(controller, animated: true)
    }
    
    @IBAction func SegmentControllerValueChanged(_ sender: AnyObject) {
        guard let segmentedControl = sender as? UISegmentedControl else {
            return
        }
        
        let selectedSegment = segmentedControl.selectedSegmentIndex
        
        if selectedSegment == 0 {
            //toggle the correct view to be visible
            isUserDefinedFoodDisplay = false
        } else {
            //toggle the correct view to be visible
            isUserDefinedFoodDisplay = true
        }
        
        setupFetchedResultsController(foodSearchBar.text ?? "")
    }
    
    @IBAction func AddFoodButtonTapped(_ sender: AnyObject) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "AddFood") else {
            return
        }
        
        present(controller, animated: true)
    }
    
    @IBAction func OpenStore(_ sender: AnyObject) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "BefitStore") else {
            return
        }
        
        present(controller, animated: true)
    }
}
