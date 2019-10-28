//
//  AddFoodViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/24/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class AddFoodViewController: UIViewController,
UIPickerViewDelegate,
UIPickerViewDataSource,
ScannedDataDelegate,
DeviceViewControllerDelegate {
    //MARK: - Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtServingDescription1: UITextField!
    @IBOutlet weak var txtServingDescription2: UITextField!
    @IBOutlet weak var txtServWeight1: UITextField!
    @IBOutlet weak var txtServWeight2: UITextField!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var txtCalories: UITextField!
    @IBOutlet weak var txtProteins: UITextField!
    @IBOutlet weak var txtCalcium: UITextField!
    @IBOutlet weak var txtIron: UITextField!
    @IBOutlet weak var txtPolyFat: UITextField!
    @IBOutlet weak var txtSaturatedFat: UITextField!
    @IBOutlet weak var txtCholesterol: UITextField!
    @IBOutlet weak var txtSelectedServing: UITextField!
    @IBOutlet weak var txtVitaminA: UITextField!
    @IBOutlet weak var txtVitaminC: UITextField!
    @IBOutlet weak var txtVitaminE: UITextField!
    @IBOutlet weak var txtDietaryFiber: UITextField!
    @IBOutlet weak var txtSugar: UITextField!
    @IBOutlet weak var txtSodium: UITextField!
    @IBOutlet weak var txtMonoSaturatedFat: UITextField!
    @IBOutlet weak var txtChooseFoodList: UITextField!
    @IBOutlet weak var txtCarbohydrates: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnAddFoodList: UIButton!
    
    @IBOutlet weak var btnScan: UIBarButtonItem!
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    
    private var foodListArray: [FoodList] {
        return AppDelegate.getfoodListItems() as! [FoodList]
    }
    
    private var selectedFoodList: FoodList?
    private var selectedListArray: [FoodList]?
    @objc var foodListObject: Food?
    @objc var isForEditing: Bool = false
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1.0)
        makeButton(btnAdd, color: buttColor)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: (btnAdd.frame.origin.y - btnAdd.frame.size.height))
        
        if isForEditing && foodListObject != nil {
            btnScan.isEnabled = false
            btnScan.tintColor = UIColor.clear
            btnAdd.setTitle("Update Food", for: .normal)
            title = "Update Food"
            setData()
        } else {
            btnAdd.setTitle("Add Food", for: .normal)
            title = "Add Food"
        }
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        txtChooseFoodList.inputView = picker
        
        selectedFoodList = foodListArray.first
    }
    
    func setData()
    {
        txtName.text = foodListObject?.name
        txtSugar.text = (foodListObject?.sugars).flatMap { String(format: "%@", $0) }
        txtSodium.text = (foodListObject?.sodium).flatMap { String(format: "%@", $0) }
        txtSaturatedFat.text = (foodListObject?.saturatedFat).flatMap { String(format: "%@", $0) }
        txtDietaryFiber.text = (foodListObject?.dietaryFiber).flatMap { String(format: "%@", $0) }
        txtMonoSaturatedFat.text = (foodListObject?.monosaturatedFat).flatMap { String(format: "%@", $0) }
        txtVitaminA.text = (foodListObject?.vitaminA).flatMap { String(format: "%@", $0) }
        txtCalories.text = (foodListObject?.calories).flatMap { String(format: "%@", $0) }
        txtServWeight2.text = (foodListObject?.servingWeight2).flatMap { String(format: "%@", $0) }
        txtVitaminE.text = (foodListObject?.vitaminE).flatMap { String(format: "%@", $0) }
        txtSelectedServing.text = (foodListObject?.selectedServing).flatMap { String(format: "%@", $0) }
        txtServingDescription2.text = (foodListObject?.servingDescription2).flatMap { String(format: "%@", $0) }
        txtCalcium.text = (foodListObject?.calcium).flatMap { String(format: "%@", $0) }
        txtQuantity.text = (foodListObject?.quantity).flatMap { String(format: "%@", $0) }
        txtPolyFat.text = (foodListObject?.polyFat).flatMap { String(format: "%@", $0) }
        txtServWeight1.text = (foodListObject?.servingWeight1).flatMap { String(format: "%@", $0) }
        txtProteins.text = (foodListObject?.protein).flatMap { String(format: "%@", $0) }
        txtCholesterol.text = (foodListObject?.cholesteral).flatMap { String(format: "%@", $0) }
        txtServingDescription1.text = (foodListObject?.servingDescription1).flatMap { String(format: "%@", $0) }
        txtVitaminC.text = (foodListObject?.vitaminC).flatMap { String(format: "%@", $0) }
        txtIron.text = (foodListObject?.iron).flatMap { String(format: "%@", $0) }
        txtCarbohydrates.text = (foodListObject?.carbs).flatMap { String(format: "%@", $0) }
        
    //    NSMutableArray* foodArray = [NSMutableArray arrayWithArray:[self.foodListObject.foodListsBelongTo allObjects]];
        
        selectedListArray = foodListObject?.foodListsBelongTo?.allObjects as? [FoodList]
        
    //    if (foodArray.count > 0)
    //    {
    //        selectedFoodList = foodArray[0];
    //        _txtChooseFoodList.text = [NSString stringWithFormat:@"%@",selectedFoodList.name];
    //    }
    }
    
    // MARK: - IBAction
    
    @IBAction func cancel(_ sender: AnyObject) {
        popViewController(false)
    }
    
    @IBAction func ScanButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "segue_scan", sender: self)
    }
    
    @IBAction func AddFoodList(_ sender: AnyObject) {
        performSegue(withIdentifier: "segue_foodList", sender: self)
    }
    
    @IBAction func AddButtonTapped(_ sender: AnyObject) {
        guard checkForEmptyTextfield() else {
            return
        }
        
        if AppDelegate.check(forDuplicateFoodItem: txtName.text ?? "").count == 0 || foodListObject != nil {
            if (txtSelectedServing.text.flatMap { Int($0) } ?? 0) > 12 {
                let alertController = UIAlertController(title: "Error", message: "Selected servings can not be more than 12", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(ok)
                
                present(alertController, animated: true)
                
                //            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Selected servings can not be more than 12" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                return
            }
            
            guard let context = managedObjectContext else {
                assertionFailure()
                return
            }
            
            var msg = "Food added Successfully"
            var list: Food!
            
            if let foodListObject = foodListObject, isForEditing {
                list = foodListObject
                msg = "Food updated Successfully"
            } else {
                list = (NSEntityDescription.insertNewObject(forEntityName: "FoodObject", into: context) as! Food)
            }
            
            func toInt(_ string: String?) -> NSNumber {
                return (string.flatMap { Int($0) }).flatMap { NSNumber(value: $0) } ?? NSNumber(value: 0)
            }
            
            func toDouble(_ string: String?) -> NSNumber {
                return (string.flatMap { Double($0) }).flatMap { NSNumber(value: $0) } ?? NSNumber(value: 0)
            }
            
            list.name = txtName.text
            list.sugars = toInt(txtSugar.text)
            list.sodium = toInt(txtSodium.text)
            list.saturatedFat = toDouble(txtSaturatedFat.text)
            list.selectedServing = toInt(txtSelectedServing.text)
            list.dietaryFiber = toInt(txtDietaryFiber.text)
            list.monosaturatedFat = toDouble(txtMonoSaturatedFat.text)
            list.vitaminA = toDouble(txtVitaminA.text)
            list.calories = toInt(txtCalories.text)
            list.servingWeight2 = toInt(txtServWeight2.text)
            list.vitaminE = toDouble(txtVitaminE.text)
            list.servingDescription2 = txtServingDescription2.text
            list.calcium = toDouble(txtCalcium.text)
            list.quantity = toInt(txtQuantity.text)
            list.polyFat = toDouble(txtPolyFat.text)
            list.servingWeight1 = toInt(txtServWeight1.text)
            list.protein = toInt(txtProteins.text)
            list.cholesteral = toInt(txtCholesterol.text)
            list.servingDescription1 = txtServingDescription1.text
            list.vitaminC = toDouble(txtVitaminC.text)
            list.iron = toDouble(txtIron.text)
            list.carbs = toInt(txtCarbohydrates.text)
            
            if let listObj = AppDelegate.getUserFoodLibrary()?.first as? FoodList {
                if selectedListArray == nil {
                    selectedListArray = []
                }
                
                if !selectedListArray!.contains(listObj) {
                    selectedListArray!.append(listObj)
                }
                
                list.foodListsBelongTo = NSSet(array: selectedListArray!)
            } else {
                assertionFailure()
            }
            
            list.userDefined = NSNumber(value: 1)
            
            do {
                try context.save()
            } catch let error {
                print("error while saving:", error.localizedDescription)
                return
            }
            
            popViewController(true)
            
            let alertController = UIAlertController(title: "Success", message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            // [[[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
        else
        {
            let alertController = UIAlertController(title: "Error", message: "Food item already exists", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
    }
    
    // MARK: - Private
    
    private func makeButton(_ butz: UIButton, color colortouse: UIColor) {
        let layer = butz.layer
        layer.masksToBounds = true
        layer.cornerRadius = 4.0 //when radius is 0, the border is a rectangle
        layer.borderWidth = 1.0
        layer.borderColor = colortouse.cgColor
        butz.backgroundColor = colortouse
    }
    
    private func popViewController(_ isFoodAdded: Bool) {
        if isForEditing && foodListObject != nil {
            if isFoodAdded
            {
                var navigationArray = navigationController?.viewControllers ?? []
                var idx: Int?
                for (i, controller) in navigationArray.enumerated() {
                    if controller is FoodObjectsViewController {
                        idx = i
                    }
                }
                
                if let i = idx {
                    navigationArray.remove(at: i)
                    navigationController?.viewControllers = navigationArray
                }
            }
            
            navigationController?.popViewController(animated: true)
        } else if foodListObject != nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func checkForEmptyTextfield() -> Bool
    {
        if txtName.text?.isEmpty ?? true {
            let alertController = UIAlertController(title: "Error", message: "Please enter food name", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter food name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
            //        [alert show];
            return false
            
        } else if (txtSelectedServing.text.flatMap { Int($0) }) ?? 0 == 0 {
            let alertController = UIAlertController(title: "Error", message: "Please fill selected servings", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            //        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill selected servings." delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles: nil]show];
            return false
            
        } else if selectedListArray?.isEmpty ?? true {
            let alertController = UIAlertController(title: "Error", message: "Please choose a food list", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            
            present(alertController, animated: true)
            
            //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose any food list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            //        [alert show];
            return false
        }
        
        return true
    }
    
    private func showScannedFoodData(_ foodData: [String: Any])
    {
        func toNSNumber(_ key: String) -> NSNumber {
            return (foodData[key] as? NSNumber) ?? NSNumber(value: 0)
        }
        
        func toString(_ key: String) -> String {
            return (foodData[key] as? String) ?? ""
        }
        
        txtName.text = toString("item_name")
        txtSugar.text = String(format: "%@", toNSNumber("nf_sugars")) // Int
        txtSodium.text = String(format: "%@", toNSNumber("nf_sodium")) // Int
        txtSaturatedFat.text = String(format: "%@", toNSNumber("nf_saturated_fat")) // Double
        txtSelectedServing.text = String(format: "%@", toNSNumber("nf_serving_size_qty")) // Int
        txtDietaryFiber.text = String(format: "%@", toNSNumber("nf_dietary_fiber")) // Int
        txtMonoSaturatedFat.text = String(format: "%@", toNSNumber("nf_monounsaturated_fat")) // Double
        txtVitaminA.text = String(format: "%@", toNSNumber("nf_vitamin_a_dv")) // Double
        txtCalories.text = String(format: "%@", toNSNumber("nf_calories")) // Int
        txtServWeight2.text = String(format: "%@", toNSNumber("")) // Int
        txtVitaminE.text = String(format: "%@", toNSNumber("nf_vitamin_e_dv")) // Double
        txtServingDescription2.text = ""
        txtCalcium.text = String(format: "%@", toNSNumber("nf_calcium_dv")) // Double
        txtQuantity.text = String(format: "%@", NSNumber(value: 0)) // toNSNumber("nf_serving_size_qty")
        txtPolyFat.text = String(format: "%@", toNSNumber("nf_polyunsaturated_fat")) // Double
        txtServWeight1.text = String(format: "%@", toNSNumber("nf_serving_weight_grams")) // Int
        txtProteins.text = String(format: "%@", toNSNumber("nf_protein")) // Int
        txtCholesterol.text = String(format: "%@", toNSNumber("nf_cholesterol")) // Int
        txtServingDescription1.text = toString("item_description")
        txtVitaminC.text = String(format: "%@", toNSNumber("nf_vitamin_c_dv")) // Double
        txtIron.text = String(format: "%@", toNSNumber("nf_iron_dv")) // Double
        txtCarbohydrates.text = String(format: "%@", toNSNumber("nf_total_carbohydrate")) // Int
    }
    
    //MARK: - ScannedDataDelegate
    
    func setScannedDataInFields(data: [String: Any]) {
        if data.count > 0 {
            print(data)
            showScannedFoodData(data)
        }
    }
    
    //MARK: - Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return foodListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let list = foodListArray[row]
        return list.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFoodList = foodListArray[row]
        txtChooseFoodList.text = selectedFoodList?.name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "segue_foodList":
            if let destViewController = segue.destination as? DeviceViewController {
                destViewController.selectedFoodLists = selectedListArray ?? []
                destViewController.isFromAddFoodScreen = true
                destViewController.delegate = self
            }
            
        case "segue_scan":
            if let destViewController = segue.destination as? ScannerViewController {
                destViewController.delegate = self
            }
            
        default:
            break
        }
        
        super.prepare(for: segue, sender: sender)
    }
    
    //MARK: DeviceViewControllerDelegate
    
    func valueChanged(selectedFoodLists: [FoodList]) {
        selectedListArray = selectedFoodLists
    }
}
