//
//  DetailViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/28/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import IQKeyboardManager

class DetailViewController: UIViewController,
    UIPickerViewDelegate,
UIPickerViewDataSource {
    //MARK: - Properties
    
    //@IBOutlet weak var lablView: UILabel!
    @IBOutlet weak var calView: UILabel!
    @IBOutlet weak var fatView: UILabel!
    @IBOutlet weak var satfatView: UILabel!
    @IBOutlet weak var polyfatView: UILabel!
    @IBOutlet weak var monofatView: UILabel!
    @IBOutlet weak var fatCals: UILabel!
    @IBOutlet weak var servingSize: UILabel!
    @IBOutlet weak var cholView: UILabel!
    @IBOutlet weak var sodView: UILabel!
    @IBOutlet weak var fiberView: UILabel!
    @IBOutlet weak var sugarView: UILabel!
    @IBOutlet weak var protView: UILabel!
    @IBOutlet weak var carbsView: UILabel!
    @IBOutlet weak var calcView: UILabel!
    @IBOutlet weak var ironView: UILabel!
    @IBOutlet weak var vitaView: UILabel!
    @IBOutlet weak var viteView: UILabel!
    @IBOutlet weak var vitcView: UILabel!
    @IBOutlet weak var transView: UILabel!
    @IBOutlet weak var Add: UIButton!
    
    @IBOutlet weak var calPerc: UILabel!
    @IBOutlet weak var calPercGr: UILabel!
    @IBOutlet weak var tfatPerc: UILabel!
    @IBOutlet weak var sfatPerc: UILabel!
    @IBOutlet weak var pfatPerc: UILabel!
    @IBOutlet weak var mfatPerc: UILabel!
    @IBOutlet weak var cholPerc: UILabel!
    @IBOutlet weak var ffPerc: UILabel!
    @IBOutlet weak var sodPerc: UILabel!
    @IBOutlet weak var fibPerc: UILabel!
    @IBOutlet weak var sugPerc: UILabel!
    @IBOutlet weak var protPerc: UILabel!
    @IBOutlet weak var carbPerc: UILabel!
    @IBOutlet weak var calcPerc: UILabel!
    @IBOutlet weak var ironPerc: UILabel!
    @IBOutlet weak var vitaPerc: UILabel!
    @IBOutlet weak var vitePerc: UILabel!
    @IBOutlet weak var vitcPerc: UILabel!
    
    //@IBOutlet weak var calProgTxt: UILabel!
    @IBOutlet weak var calProg: UIProgressView!
    @IBOutlet weak var tfatProg: UIProgressView!
    @IBOutlet weak var sfatProg: UIProgressView!
    @IBOutlet weak var calffatProg: UIProgressView!
    @IBOutlet weak var mfatProg: UIProgressView!
    @IBOutlet weak var cholProg: UIProgressView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtPicker: UITextField!
    @IBOutlet weak var btnTodayIntake: UIButton!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    @IBOutlet weak var wview: UIView!
    @IBOutlet weak var navigationBarScrollLabel: CBAutoScrollLabel!
    
    private var format: DateFormatter!
    private var foodListArray: [FoodList] = []
    private var selectedFoodList: FoodList?
    //private var selectedlabel: String?
    //private var progColor: UIColor?
    //private var myData: Data?
    var foodData: Food?
    
    private var webview: WKWebView!
    //private var lineChart: CWLineChart!
    //private var barChart: CWBarChart!
    //private var pieChart: CWPieChart!
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: - Methods
    
    private func random(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    /* Progress Bars */
    private func prog(_ val1: UIProgressView, data val2: Double) {
        val1.progress = Float(val2)
        print("array:", val2)
        
        val1.trackTintColor = UIColor.black.withAlphaComponent(0.1)
        
        if val2 < 0.40 {
            val1.progressTintColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1)
        } else if val2 < 0.75 {
            val1.progressTintColor = UIColor(red: 0.41, green: 0.64, blue: 0.80, alpha: 1)
        } else if val2 <= 1 {
            val1.progressTintColor = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1)
        }
    }
    
    @IBAction func AddFoodButtonTapped(_ sender: AnyObject) {
        txtPicker.becomeFirstResponder()
    }
    
    private func addDoughnut() {
        guard let foodData = foodData else {
            assertionFailure()
            return
        }
        
        let cfromfat = foodData.calories?.floatValue ?? 0
        let cfromfatgr = cfromfat / 100
        
        let tfat = Float(foodData.totalFatValueAsDouble)
        let tfatgr = tfat / 100
        
        let sfat = Float(foodData.saturatedFatValue.trimmingCharacters(in: .letters)) ?? 0
        let sfatgr = sfat / 100
        
        let chol = Float(foodData.cholesterolValue.trimmingCharacters(in: .letters)) ?? 0
        let cholgr = chol / 100
        
        let realValues = [foodData.caloriesStringValue, foodData.totalFatValue, foodData.saturatedFatValue, foodData.cholesterolValue]
        
        let recipePhotos = ["Calories", "Total Fat", "Saturated Fat", "Cholesterol"]
        
        let recipieData = [NSNumber(value: cfromfatgr), NSNumber(value: tfatgr), NSNumber(value: sfatgr), NSNumber(value: cholgr)]
        
        let colorData = [
            CWColors.shared().color(forKey: CWCAsbestos),
            CWColors.shared().color(forKey: CWCEmerald),
            CWColors.shared().color(forKey: CWCSunFlower),
            CWColors.shared().color(forKey: CWCPomegrante),
            CWColors.shared().color(forKey: CWCOrange),
            CWColors.shared().color(forKey: CWCAmethyst),
            CWColors.shared().color(forKey: CWCConcrete)
        ]
        
        var data = [CWSegmentData]()
        
        for i in 0 ..< recipieData.count {
            let object1 = recipieData[i]
            let object2 = recipePhotos[i]
            let object3 = colorData[i]
            let object4 = realValues[i]
            
            let segment = CWSegmentData()
            segment.value = object1
            segment.label = String(format: "%@ : %@", object2, object4)
            let c1 = object3
            let c2 = c1.withAlphaComponent(0.8)
            segment.color = c2
            segment.highlight = c1
            data.append(segment)
        }
        
        //    id win = [self.webview windowScriptObject];
        let pc = CWDoughnutChart(webView: webview, name: "Doughnut1", width: 200, height: 200, data: data, options: nil)
        
        pc?.add()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webview = WKWebView(frame: wview.bounds)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.center = wview.center
        wview.addSubview(webview)
        
        let viewsDictionary: [String: UIView] = ["webview": webview]
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[webview]|", options: [], metrics: nil, views: viewsDictionary))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webview]|", options: [], metrics: nil, views: viewsDictionary))
        //    [_wview setBackgroundColor:[UIColor redColor]];
        
        self.webview = webview
        let resourcesPath = Bundle.main.resourcePath ?? ""
        let htmlPath = resourcesPath.appending("/cw.html")
        
        webview.load(URLRequest(url: URL(fileURLWithPath: htmlPath, isDirectory: false)))
        
        webview.isOpaque = false
        webview.backgroundColor = .clear
        webview.scrollView.isScrollEnabled = false
        webview.isMultipleTouchEnabled = false
        
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: wview.frame.origin.y + wview.frame.size.height)
        format = DateFormatter()
        format.dateFormat = "MM/dd/yyyy"
        
        // navigation bar auto scroll label
        navigationBarScrollLabel.text = foodData?.name
        navigationBarScrollLabel.pauseInterval = 3
        navigationBarScrollLabel.font = UIFont.boldSystemFont(ofSize: 20)
        navigationBarScrollLabel.textColor = .white
        navigationBarScrollLabel.observeApplicationNotifications()
        
        // self.title = foodData.name;
        
        // Set Data and Titles
        
        //lablView.text = foodData?.name
        calView.text = foodData?.caloriesStringValue
        servingSize.text = foodData?.servingDescription1
        fatView.text = foodData?.totalFatValue
        satfatView.text = foodData?.saturatedFatValue
        polyfatView.text = foodData?.polyunsaturatedFatValue
        monofatView.text = foodData?.monounsaturatedFatValue
        fatCals.text = foodData?.caloriesFromFatValue
        cholView.text = foodData?.cholesterolValue
        sodView.text = foodData?.sodiumValue
        fiberView.text = foodData?.dietaryFiberValue
        sugarView.text = foodData?.sugarsValue
        protView.text = foodData?.proteinValue
        carbsView.text = foodData?.carbsValue
        calcView.text = foodData?.calciumValue
        ironView.text = foodData?.ironValue
        vitaView.text = foodData?.vitaminAValue
        viteView.text = foodData?.viteValue
        vitcView.text = foodData?.vitaminCValue
        transView.text = foodData?.transFatValue
        tfatPerc.text = foodData?.totalFatPercent
        calPerc.text = foodData?.calfromFatValuePerc
        calPercGr.text = foodData?.calfromFatValuePerc
        sfatPerc.text = foodData?.saturatedFatPercent
        pfatPerc.text = foodData?.polyFatValuePerc
        mfatPerc.text = foodData?.monoFatValuePerc
        cholPerc.text = foodData?.cholesterolPercent
        ffPerc.text = foodData?.totalValuePerc
        sodPerc.text = foodData?.sodiumPercent
        fibPerc.text = foodData?.dietaryFiberPercent
        sugPerc.text = foodData?.sugarsValuePerc
        protPerc.text = foodData?.proteinValuePerc
        carbPerc.text = foodData?.carbsPercent
        calcPerc.text = foodData?.calciumValuePerc
        ironPerc.text = foodData?.ironValuePerc
        vitaPerc.text = foodData?.vitaminAValuePerc
        vitcPerc.text = foodData?.vitaminCValuePerc
        vitePerc.text = foodData?.vitaminEValuePerc
        
        // Progress Bar Code
        
        prog(calProg, data: Double(foodData?.caloriesFloatValuePerc ?? 0))
        prog(tfatProg, data: Double(foodData?.totalFatPercentfloat ?? 0))
        prog(sfatProg, data: Double(foodData?.saturatedFatPercentFloat ?? 0))
        prog(calffatProg, data: Double(foodData?.calfromFatValuePercFloat ?? 0))
        prog(mfatProg, data: Double(foodData?.monoSaturatedFatPercentFloat ?? 0))
        prog(cholProg, data: Double(foodData?.cholPercentFloat ?? 0))
        
        //UIColor *redcolor = [UIColor colorWithRed:0.91 green:0.30 blue:0.24 alpha:1.0];
        let buttColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1)
        //UIColor *greyColor = [UIColor colorWithRed:0.74 green:0.76 blue:0.78 alpha:1.0];
        
        makeButton(Add, color: buttColor)
        makeButton(btnTodayIntake, color: buttColor)
        
        let time1: CGFloat = 3.49
        let time2: CGFloat = 8.13
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            let newTime = time1 + time2
            print("New time:", newTime)
            self?.addDoughnut()
        }
        
        foodListArray = AppDelegate.getfoodListItems()
        selectedFoodList = foodListArray.first
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        txtPicker.inputView = picker
        
        txtPicker.addDoneOnKeyboard(withTarget: self, action: #selector(doneAction))
        
        if (foodData?.userDefined?.intValue ?? 0) == 0 {
            btnEdit.isEnabled = false
            btnEdit.tintColor = .clear
        }
    }
    
    @objc private func doneAction() {
        txtPicker.resignFirstResponder()
        
        //[self performSelector:@selector(CallAfterDelay) withObject:nil afterDelay:0.7];
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.callAfterDelay()
        }
    }
    
    private func callAfterDelay() {
        guard let context = managedObjectContext, let selectedFoodList = selectedFoodList else {
            assertionFailure()
            return
        }
        
        let foodSet = (foodData?.foodListsBelongTo?.mutableCopy() as? NSMutableSet) ?? NSMutableSet()
        if !foodSet.contains(selectedFoodList)
        {
            if let list = AppDelegate.getUserFoodLibrary().first {
                if !foodSet.contains(list) && foodData?.userDefined?.intValue == 1 {
                    foodSet.add(list)
                }
            }
            
            foodSet.add(selectedFoodList)
            foodData?.foodListsBelongTo = foodSet
            
            do {
                try context.save()
                
                let alertController = UIAlertController(title: "Success", message: "Food Item added successfully", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                present(alertController, animated: true)
                
                // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food Item added successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            } catch let error {
                print("error while saving:", error.localizedDescription)
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Food Item already exists", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            present(alertController, animated: true)
            
            //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food Item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        }
    }
    
    private func makeButton(_ butz: UIButton, color colortouse: UIColor) {
        let layer = butz.layer
        layer.masksToBounds = true
        layer.cornerRadius = 4.0 //when radius is 0, the border is a rectangle
        layer.borderWidth = 1.0
        layer.borderColor = colortouse.cgColor
        butz.backgroundColor = colortouse
    }
    
    private func checkForDuplicateFoodItem() -> [UserFoodRecords] {
        guard let context = managedObjectContext else {
            return []
        }
        
        let request = UserFoodRecords.fetchRequest() as NSFetchRequest<UserFoodRecords>
        let dateStr = format.string(from: Date())
        let predicate = NSPredicate(format: "date LIKE[c] %@", dateStr)
        request.predicate = predicate
        
        return (try? context.fetch(request)) ?? []
    }
    
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
        //txtPicker.text = selectedFoodList?.name
    }
    
    @IBAction func EditFood(_ sender: AnyObject) {
        performSegue(withIdentifier: "segue_edit", sender: self)
    }
    
    @IBAction func TodaysFoodIntake(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Befit", message: "Please enter servings", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { $0.placeholder = NSLocalizedString("Qty", comment: "Qty") })
        
        if let txtServings = alertController.textFields?.first {
            txtServings.keyboardType = .phonePad
        }
        
        alertController.view.tag = 100
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { [weak alertController] _ in
            alertController?.dismiss(animated: true)
        })
        
        alertController.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak alertController] _ in
            let txtServings = alertController?.textFields?.first
            
            if txtServings?.text?.isEmpty ?? true {
                let alertController = UIAlertController(title: "Error", message: "Please enter servings", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                self?.present(alertController, animated: true)
                
                
                //            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
                //            [alert show];
                return
            }
            
            guard let me = self,
                let foodData = me.foodData,
                let context = me.managedObjectContext else {
                    return
            }
            
            var record = NSEntityDescription.insertNewObject(forEntityName: "UserFoodRecords", into: context) as! UserFoodRecords
            let dateStr = me.format.string(from: Date())
            var servings = (txtServings?.text).flatMap { Int($0) } ?? 0
            let newfood = NSMutableSet(object: foodData)
            let recordArray = me.checkForDuplicateFoodItem()
            
            for newRecord in recordArray {
                let foodArray = newRecord.foodIntake
                if foodArray?.contains(foodData) ?? false {
                    servings = servings + (newRecord.servings?.intValue ?? 0)
                    record = newRecord
                }
            }
            
            //        if ([recordArray count] > 0)
            //        {
            //            record = recordArray[0] ;
            //            newfood = record.foodIntake.mutableCopy ;
            //            [newfood addObject:foodData];
            //        }
            record.date = dateStr
            record.servings = NSNumber(value: servings)
            record.foodIntake = newfood
            
            do {
                try context.save()
                
                let alertController = UIAlertController(title: "Success", message: "Food successfully added to Today's Intake list", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                me.present(alertController, animated: true)
                
                // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food successfully added to Today's Intake list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
            } catch let error {
                print("error while saving:", error.localizedDescription)
            }
        })
        
        present(alertController, animated: true)
        
        //UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Befit" message:@"Please enter servings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        //[alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        //UITextField *txtServings = [alertController textFieldAtIndex:0];
        
        
        //alert.tag = 100;
        //[alert show];
        
        
        
        //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Befit" message:@"Please enter servings" preferredStyle:UIAlertControllerStyleAlert];
        //    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //        textField.placeholder = @"Servings";
        //    }];
        //    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        //        UITextField *txtServings = [alertController textFields][0];
        //        if (txtServings.text.length == 0)
        //        {
        //            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter servings" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
        //            [alert show];
        //            return ;
        //        }
        //        NSManagedObjectContext *context = [self managedObjectContext];
        //        UserFoodRecords* record = [NSEntityDescription insertNewObjectForEntityForName:@"UserFoodRecords" inManagedObjectContext:context];
        //        NSString* dateStr = [format stringFromDate:[NSDate new]] ;
        //        NSInteger servings = txtServings.text.integerValue ;
        //        NSMutableSet* newfood = [NSMutableSet setWithObject:foodData];
        //        NSArray* recordArray = [self CheckForDuplicateFoodItem] ;
        //
        //        for (int iCount = 0; iCount < recordArray.count; iCount++)
        //        {
        //            UserFoodRecords* newRecord = [recordArray objectAtIndex:iCount];
        //            NSMutableArray* foodArray = [[NSMutableArray alloc] initWithArray:[newRecord.foodIntake allObjects]];
        //            if ([foodArray containsObject:foodData])
        //            {
        //                servings = servings + newRecord.servings.integerValue ;
        //                record = newRecord ;
        //            }
        //        }
        //
        //
        //
        //
        //        //        if ([recordArray count] > 0)
        //        //        {
        //        //            record = recordArray[0] ;
        //        //            newfood = record.foodIntake.mutableCopy ;
        //        //            [newfood addObject:foodData];
        //        //        }
        //        record.date = dateStr ;
        //        record.servings = [NSNumber numberWithInteger:servings] ;
        //        record.foodIntake = newfood ;
        //
        //
        //        NSError *error;
        //        if (![context save:&error])
        //        {
        //            NSLog(@"errror while saving : %@",error.description);
        //        }
        //        else
        //        {
        //            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food successfully added to Today's Intake list" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        //        }
        //    }];
        //    [alertController addAction:confirmAction];
        //    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //
        //    }];
        //    [alertController addAction:cancelAction];
        //    [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destViewController = segue.destination as? AddFoodViewController {
            destViewController.foodListObject = foodData
            destViewController.isForEditing = true
        }
        
        super.prepare(for: segue, sender: sender)
    }
}
