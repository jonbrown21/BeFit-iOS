//
//  DeviceDetailViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class DeviceDetailViewController: UIViewController,
UIBarPositioningDelegate,
UINavigationBarDelegate {
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var navigationbar: UINavigationBar!
    
    var device: FoodList?
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationbar.delegate = self
        
        if let device = device {
            nameTextField.text = device.name
        }
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Actions
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            let alertController = UIAlertController(title: "Error", message: "Please enter food list name", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
    //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter food list name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
    //        [alert show];
            return
        }
        
        if !AppDelegate.check(forDuplicateFoodList: nameTextField.text ?? "").isEmpty {
            let alertController = UIAlertController(title: "Error", message: "Food List already exists", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
           // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food List already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            return
        }
        
        let maxID = getMaxTranslationMaxId() + 1
        
        guard let context = managedObjectContext else {
            assertionFailure()
            return
        }
        
        if let device = device {
            // Update existing device
            device.name = nameTextField.text ?? ""
            device.orderIndex = NSNumber(value: maxID)
            
        } else {
            // Create a new managed object
            let list = NSEntityDescription.insertNewObject(forEntityName: "FoodListObject", into: context) as! FoodList
            list.name = nameTextField.text ?? ""
            list.orderIndex = NSNumber(value: maxID)
            list.foods = NSSet()
        }
        
        do {
            try context.save()
        } catch let error {
            print("Can't Save!", error.localizedDescription)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIBarPositioningDelegate
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    //MARK: - Private
    
    private func getMaxTranslationMaxId() -> Int {
        guard let context = managedObjectContext else {
            assertionFailure()
            return 0
        }
        
        let request = FoodList.fetchRequest() as NSFetchRequest<FoodList>
        let sortDescriptor = NSSortDescriptor(key: "orderIndex", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            
            guard let firstResult = results.first else {
                return 0
            }
            
            let maximumValue = firstResult.orderIndex?.intValue ?? 0
            print("The max value is for request is:", maximumValue)
            
            return maximumValue
        } catch let error {
            print("Failed to fetch:", error.localizedDescription)
            return 0
        }
    }
}
