//
//  FirstViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/28/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class FirstViewController: UIViewController,
    GenderPickerControllerDelegate,
    LifePickerControllerDelegate,
    GoalPickerControllerDelegate,
    UIActionSheetDelegate,
    UITextFieldDelegate,
    UIBarPositioningDelegate,
UINavigationBarDelegate {
    //MARK: - Properties
    
    @IBOutlet weak var Age: UITextField!
    @IBOutlet weak var Weight: UITextField!
    @IBOutlet weak var Hfeet: UITextField!
    @IBOutlet weak var Hinches: UITextField!
    @IBOutlet weak var Total: UILabel!
    //@IBOutlet weak var Gender: UITextField!
    @IBOutlet weak var MetricSwitch: UISwitch!
    @IBOutlet weak var inLab: UILabel!
    @IBOutlet weak var ftLab: UILabel!
    @IBOutlet weak var HCM: UITextField!
    @IBOutlet weak var cmLab: UILabel!
    @IBOutlet weak var switchLab: UILabel!
    @IBOutlet weak var lbs: UILabel!
    @IBOutlet weak var weightMet: UITextField!
    @IBOutlet weak var CalcButt: UIButton!
    //@IBOutlet weak var ResetButt: UIButton!
    @IBOutlet weak var GenderButt: UIButton!
    @IBOutlet weak var LifeButt: UIButton!
    @IBOutlet weak var GoalButt: UIButton!
    @IBOutlet weak var Recommended: UILabel!
    @IBOutlet weak var SliderLab: UILabel!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var GoalSiwtch: UISwitch!
    @IBOutlet weak var use: UILabel!
    @IBOutlet weak var navigationbar: UINavigationBar!
    
    private var LifeTableVC: UITableViewController!
    private var SimpleTableVC: UITableViewController!
    
    private var genderArray: [String] = []
    private var lifestyleArray: [String] = []
    private var goalArray: [String] = []
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationbar.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cancelNumberPad))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let defaults = UserDefaults.standard
        let gendervalue = defaults.string(forKey: "gender-name")
        let agevalue = defaults.string(forKey: "age-name")
        let weightvalue = defaults.string(forKey: "weight-name")
        let heightfeet = defaults.string(forKey: "heightfeet-name")
        let inchfeet = defaults.string(forKey: "inchfeet-name")
        let lifeValue = defaults.string(forKey: "lifestyle-name")
        let goalValue = defaults.string(forKey: "goal-name")
        let cmValue = defaults.string(forKey: "cmheightvalue-name")
        let kgValue = defaults.string(forKey: "kgheightvalue-name")
        let thegoal = defaults.string(forKey: "thegoal")
        let imUsing = defaults.string(forKey: "using")
        let recomendation = defaults.string(forKey: "recommended-name")
        let useMetric = defaults.bool(forKey: "use-metric")
        
        let rec = recomendation.flatMap { Float($0) } ?? 0
        let age = agevalue.flatMap { Float($0) } ?? 0
        let weight = weightvalue.flatMap { Float($0) } ?? 0
        let gender = gendervalue.flatMap { Float($0) } ?? 0
        let inches = inchfeet.flatMap { Float($0) } ?? 0
        let feet = heightfeet.flatMap { Float($0) } ?? 0
        let goal = goalValue.flatMap { Float($0) } ?? 0
        let life = lifeValue.flatMap { Float($0) } ?? 0
        let cm = cmValue.flatMap { Float($0) } ?? 0
        let kg = kgValue.flatMap { Float($0) } ?? 0
        let theGoal = thegoal.flatMap { Float($0) } ?? 0
        
        if imUsing == "yes" {
            Slider.value = rec
            SliderLab.text = recomendation ?? "0"
            GoalSiwtch.setOn(true, animated: true)
            Slider.isUserInteractionEnabled = false
            use.text = "Using"
            
        } else {
            Slider.value = theGoal
            SliderLab.text = thegoal ?? "0"
            GoalSiwtch.setOn(false, animated: true)
            Slider.isUserInteractionEnabled = true
            use.text = "Not Using"
        }
        
        // Automatically Set Lifestyle
        
        if life == 0 {
            LifeButt.setTitle("Sedentary", for: .normal)
        }   else if life == 1 {
            LifeButt.setTitle("Lightly Active", for: .normal)
        } else if life == 2 {
            LifeButt.setTitle("Moderately Active", for: .normal)
        } else if life == 3 {
            LifeButt.setTitle("Very Active", for: .normal)
        } else if life == 4 {
            LifeButt.setTitle("Extra Active", for: .normal)
        } else {
            LifeButt.setTitle("Select", for: .normal)
        }
        
        // Automatically Set Goal
        
        if goal == 0 {
            GoalButt.setTitle("Loose Weight", for: .normal)
        } else if goal == 1 {
            GoalButt.setTitle("Gain Weight", for: .normal)
        } else if goal == 2 {
            GoalButt.setTitle("Maintain Weight", for: .normal)
        } else {
            GoalButt.setTitle("Select", for: .normal)
        }
        
        // Automatically Call Age Value
        
        if age > 0 {
            Age.text = agevalue
        } else {
            Age.text = ""
        }
        
        // Automatically Call Weight Value
        
        if weight > 0 {
            Weight.text = weightvalue
        } else {
            Weight.text = ""
        }
        
        // Automatically Call Feet Value
        
        if feet > 0 {
            Hfeet.text = heightfeet
        } else {
            Hfeet.text = ""
        }
        
        // Automatically Call Inch Value
        
        if inches > 0 {
            Hinches.text = inchfeet
        } else {
            Hinches.text = ""
        }
        
        // Automatically Call CM Value
        
        if cm > 0 {
            HCM.text = cmValue
        } else {
            HCM.text = ""
        }
        
        // Automatically Call KG Value
        
        if kg > 0 {
            weightMet.text = kgValue
        } else {
            weightMet.text = ""
        }
        
        // Automatically Call Gender Value
        
        if gender == 0 {
            GenderButt.setTitle("Male", for: .normal)
        } else if gender == 1 {
            GenderButt.setTitle("Female", for: .normal)
        } else {
            GenderButt.setTitle("Select", for: .normal)
        }
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "whitey.png") ?? UIImage())
        
        genderArray = ["Male", "Female"]
        goalArray = ["Loose Weight", "Gain Weight", "Maintain Weight"]
        lifestyleArray = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extra Active"]
        
        let buttColor = UIColor(red: 0.18, green: 0.80, blue: 0.44, alpha: 1)
        let greyColor = UIColor(red: 0.74, green: 0.76, blue: 0.78, alpha: 1)
        //let redcolor = UIColor(red: 0.91, green: 0.30, blue: 0.24, alpha: 1)
        
        UITextField.appearance().tintColor = greyColor
        
        //makeButton(ResetButt, color: redcolor)
        makeButton(GoalButt, color: greyColor)
        makeButton(LifeButt, color: greyColor)
        makeButton(CalcButt, color: buttColor)
        makeButton(GenderButt, color: greyColor)
        
        MetricSwitch.isOn = useMetric
        didChangeSwitch(MetricSwitch)
        
        UISwitch.appearance().tintColor = UIColor(red: 0.66, green: 0.70, blue: 0.73, alpha: 1)
        MetricSwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        MetricSwitch.addTarget(self, action: #selector(setState), for: .valueChanged)
        GoalSiwtch.addTarget(self, action: #selector(didGoalSwitch), for: .valueChanged)
        
        Calculate(self)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set Background Color of UIStatusBar
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
        statusBarView.backgroundColor  = UIColor(red: 0.32, green: 0.66, blue: 0.82, alpha: 1)
        view.addSubview(statusBarView)
        
        let insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        if insets.top > 0 {
            // We're running on an iPhone with a notch.
            
            // Set Background Color of UIStatusBar
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let statusBarView =  UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight))
            statusBarView.backgroundColor  = UIColor(red: 0.32, green: 0.66, blue: 0.82, alpha: 1)
            view.addSubview(statusBarView)
        }
    }
    
    @IBAction func Reset(_ sender: AnyObject) {
        HCM.text = ""
        weightMet.text = ""
        Hinches.text = ""
        Hfeet.text = ""
        Weight.text = ""
        Age.text = ""
        Recommended.text = ""
        Total.text = ""
        Slider.value = 500
        SliderLab.text = "500"
        
        LifeButt.setTitle("Select", for: .normal)
        GoalButt.setTitle("Select", for: .normal)
        GenderButt.setTitle("Select", for: .normal)
        
        let resetValue = ""
        let defaults = UserDefaults.standard
        defaults.set(resetValue, forKey: "age-name")
        defaults.set(resetValue, forKey: "weight-name")
        defaults.set(resetValue, forKey: "heightfeet-name")
        defaults.set(resetValue, forKey: "inchfeet-name")
        defaults.set(resetValue, forKey: "cmheightvalue-name")
        defaults.set(resetValue, forKey: "kgheightvalue-name")
        defaults.set(resetValue, forKey: "goal-name")
        defaults.set(resetValue, forKey: "lifestyle-name")
        defaults.set(resetValue, forKey: "gender-name")
        defaults.set(resetValue, forKey: "recommended-name")
        defaults.set(resetValue, forKey: "thegoal")
        defaults.set("no", forKey: "using")
        defaults.set(false, forKey: "use-metric")
        
        GoalSiwtch.setOn(false, animated: false)
        MetricSwitch.setOn(false, animated: false)
    }
    
    @IBAction func sliderValueChanged(_ sender: AnyObject) {
        if sender === Slider {
            SliderLab.text = String(format: "%0.0f", Slider.value)
            UserDefaults.standard.set(String(format: "%0.0f", Slider.value), forKey: "thegoal")
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
    
    @objc private func cancelNumberPad() {
        view.endEditing(false)
    }
    
    @objc private func didGoalSwitch(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        let recomendation = defaults.string(forKey: "recommended-name")
        let rec = recomendation.flatMap { Float($0) } ?? 0
        
        if GoalSiwtch.isOn {
            use.text = "Using"
            Slider.value = rec
            Slider.isUserInteractionEnabled = false
            SliderLab.text = recomendation
            
            defaults.set("yes", forKey: "using")
            
        } else {
            use.text = "Not Using"
            Slider.isUserInteractionEnabled = true
            
            defaults.set("no", forKey: "using")
            
            Slider.value = 500
            SliderLab.text = "500"
        }
    }
    
    @objc private func didChangeSwitch(_ sender: UISwitch) {
        Hfeet.isHidden = MetricSwitch.isOn
        Hinches.isHidden = MetricSwitch.isOn
        inLab.isHidden = MetricSwitch.isOn
        ftLab.isHidden = MetricSwitch.isOn
        Weight.isHidden = MetricSwitch.isOn
        HCM.isHidden = !MetricSwitch.isOn
        cmLab.isHidden = !MetricSwitch.isOn
        weightMet.isHidden = !MetricSwitch.isOn
        
        if MetricSwitch.isOn {
            switchLab.text = "Metric"
            lbs.text = "kg"
        } else {
            switchLab.text = "Imperial"
            lbs.text = "lbs"
        }
    }
    
    @objc private func setState(_ sender: UISwitch) {
        let state = sender.isOn
        UserDefaults.standard.set(state, forKey: "use-metric")
        
        let rez = state ? "YES" : "NO"
        print(rez)
        Calculate(self)
    }
    
    @IBAction func Calculate(_ sender: AnyObject) {
        AppDelegate.showLoader(text: "Saving...")
        
        let defaults = UserDefaults.standard
        let gendervalue = defaults.string(forKey: "gender-name")
        let lifeValue = defaults.string(forKey: "lifestyle-name")
        let goalValue = defaults.string(forKey: "goal-name")
        
        var height: Float = 0
        var weight: Float = 0
        var lbs: Float = 0
        var inch: Float = 0
        var bmi: Float = 0
        var bmr: Float = 0
        var gender: Float = 0
        var age: Float = 0
        var lifestyles: Float = 0
        var BMRLIFESTYLE: Float = 0
        var goals: Float = 0
        var BMRGOALS: Float = 0
        var h_feet: Float = 0
        var i_feet: Float = 0
        var m_cm: Float = 0
        var m_kg: Float = 0
        
        // Automatically Set Age Value
        
        age = Age.text.flatMap { Float($0) } ?? 0
        let ageValue = String(format: "%lu", UInt64(age))
        defaults.set(ageValue, forKey: "age-name")
        // Automatically Set Weight Value
        
        weight = Weight.text.flatMap { Float($0) } ?? 0
        let weightValue = String(format: "%lu", UInt64(weight))
        defaults.set(weightValue, forKey: "weight-name")
        // Automatically Set Gender Value
        
        gender = gendervalue.flatMap { Float($0) } ?? 0
        lifestyles = lifeValue.flatMap { Float($0) } ?? 0
        goals = goalValue.flatMap { Float($0) } ?? 0
        
        // Automatically Set Height Feet Value
        
        h_feet = Hfeet.text.flatMap { Float($0) } ?? 0
        let heightfeetValue = String(format: "%lu", UInt64(h_feet))
        defaults.set(heightfeetValue, forKey: "heightfeet-name")
        // Automatically Set Height Inches Value
        
        i_feet = Hinches.text.flatMap { Float($0) } ?? 0
        let inchfeetValue = String(format: "%lu", UInt64(i_feet))
        defaults.set(inchfeetValue, forKey: "inchfeet-name")
        
        // Automatically Set Height CM Value
        
        m_cm = HCM.text.flatMap { Float($0) } ?? 0
        let cmheightvalue = String(format: "%lu", UInt64(m_cm))
        defaults.set(cmheightvalue, forKey: "cmheightvalue-name")
        
        // Automatically Set Height KG Value
        
        m_kg = weightMet.text.flatMap { Float($0) } ?? 0
        let kgheightvalue = String(format: "%lu", UInt64(m_kg))
        defaults.set(kgheightvalue, forKey: "kgheightvalue-name")
        
        if MetricSwitch.isOn {
            //Convert IN Input Values to Metric
            
            if (Weight.text ?? "").isEmpty == false {
                let lbs = Weight.text.flatMap { Float($0) } ?? 0
                let kg = lbs * 0.453592
                
                weightMet.text = String(format: "%.0f", kg)
            }
            
            if (Hfeet.text ?? "").isEmpty == false {
                height = ((Hfeet.text.flatMap { Float($0) } ?? 0) * 12) + (Hinches.text.flatMap { Float($0) } ?? 0)
                let revHeight = height * 2.54
                
                HCM.text = String(format: "%.0f", revHeight)
            }
            
            weight = weightMet.text.flatMap { Float($0) } ?? 0
            lbs = weight / 0.453592
            let HCMValue = HCM.text.flatMap { Float($0) } ?? 0
            inch = HCMValue * 0.393701
            height = HCMValue / 100
            age = Age.text.flatMap { Float($0) } ?? 0
            bmi = weight / (height * height)
            
            let FinishedBMI = String(format: "%.f", bmi)
            let bmiFloatValue = Float(FinishedBMI) ?? 0
            
            let theRange: String
            
            if bmiFloatValue < 16.5 {
                theRange = "Underweight"
            } else if bmiFloatValue < 18.5 {
                theRange = "Underweight";
            } else if bmiFloatValue < 27 {
                theRange = "Normal"
            } else if bmiFloatValue < 30 {
                theRange = "Overweight"
            } else if bmiFloatValue < 35 {
                theRange = "Obese"
            } else {
                theRange = "Obese"
            }
            
            let finalBMIOutput = String(format: "BMI: %.f | Rating: %@", bmi, theRange)
            
            if gender == 1 {
                bmr = 655 + (4.35 * lbs) + (4.7 * inch) - (4.7 * age)
                
                Total.text = String(format: "%@", finalBMIOutput)
                Recommended.text = String(format: "%.0f", bmr)
            } else {
                bmr = 66 + (6.23 * lbs) + (12.7 * inch) - (6.8 * age)
                
                Total.text = String(format: "%@", finalBMIOutput)
                Recommended.text = String(format: "%.0f", bmr)
            }
            
            if lifestyles == 0 {
                
                BMRLIFESTYLE = bmr * 1.2
                
            } else if lifestyles == 1 {
                
                BMRLIFESTYLE = bmr * 1.375
                
            } else if lifestyles == 2 {
                
                BMRLIFESTYLE = bmr * 1.55
                
            } else if lifestyles == 3 {
                
                BMRLIFESTYLE = bmr * 1.725
                
            } else if lifestyles == 4 {
                
                BMRLIFESTYLE = bmr * 1.9
                
            }
            
            if goals == 0 {
                
                BMRGOALS = BMRLIFESTYLE - 500
                
            } else if goals == 1 {
                
                BMRGOALS = BMRLIFESTYLE + 1000
                
            } else if goals == 2 {
                
                BMRGOALS = BMRLIFESTYLE
                
            } else {
                
                BMRGOALS = BMRLIFESTYLE
                
            }
            
            Recommended.text = String(format: "%.0f Calories", BMRGOALS)
            defaults.set(String(format: "%.0f", BMRGOALS), forKey: "recommended-name")
            
            let imUsing = defaults.string(forKey: "using")
            let recomendation = defaults.string(forKey: "recommended-name")
            let rec = recomendation.flatMap { Float($0) } ?? 0
            
            if imUsing == "yes" {
                Slider.value = rec
                SliderLab.text = recomendation
                GoalSiwtch.setOn(true, animated: true)
                Slider.isUserInteractionEnabled = false
                use.text = "Using"
            }
        } else {
            if (weightMet.text ?? "").isEmpty == false {
                let kg = weightMet.text.flatMap { Float($0) } ?? 0
                let lbs = kg / 0.453592
                
                Weight.text = String(format: "%.0f", lbs)
            }
            
            if (HCM.text ?? "").isEmpty == false {
                let cm = HCM.text.flatMap { Float($0) } ?? 0
                let INCH_IN_CM: Float = 2.54
                
                let numInches = Int(roundf(cm / INCH_IN_CM))
                let feet = numInches / 12
                let inches = numInches % 12
                
                Hfeet.text = String(format: "%d", feet)
                Hinches.text = String(format: "%d", inches)
            }
            
            height = ((Hfeet.text.flatMap { Float($0) } ?? 0) * 12) + (Hinches.text.flatMap { Float($0) } ?? 0)
            weight = Weight.text.flatMap { Float($0) } ?? 0
            age = Age.text.flatMap { Float($0) } ?? 0
            bmi = weight / (height * height) * 703
            
            let FinishedBMI = String(format: "%.f", bmi)
            let bmiFloatValue = Float(FinishedBMI) ?? 0
            
            let theRange: String
            
            if bmiFloatValue < 16.5 {
                theRange = "Underweight"
            } else if bmiFloatValue < 18.5 {
                theRange = "Underweight"
            } else if bmiFloatValue < 27 {
                theRange = "Normal"
            } else if bmiFloatValue < 30 {
                theRange = "Overweight"
            } else if bmiFloatValue < 35 {
                theRange = "Obese"
            } else {
                theRange = "Obese"
            }
            
            let finalBMIOutput = String(format: "BMI: %.f | Rating: %@", bmi, theRange)
            
            if gender == 1 {
                
                bmr = 655 + ( 4.35 * weight ) + ( 4.7 * height ) - ( 4.7 * age )
                
                Total.text = String(format: "%@", finalBMIOutput)
                
            } else {
                
                bmr =  66 + ( 6.23 * weight ) + ( 12.7 * height ) - ( 6.8 * age )
                Total.text = String(format: "%@", finalBMIOutput)
                
            }
            
            if lifestyles == 0 {
                
                BMRLIFESTYLE = bmr * 1.2
                
            } else if lifestyles == 1 {
                
                BMRLIFESTYLE = bmr * 1.375
                
            } else if lifestyles == 2 {
                
                BMRLIFESTYLE = bmr * 1.55
                
            } else if lifestyles == 3 {
                
                BMRLIFESTYLE = bmr * 1.725
                
            } else if lifestyles == 4 {
                
                BMRLIFESTYLE = bmr * 1.9
                
            }
            
            if goals == 0 {
                
                BMRGOALS = BMRLIFESTYLE - 500
                
                
            } else if goals == 1 {
                
                BMRGOALS = BMRLIFESTYLE + 1000
                
            } else if goals == 2 {
                
                BMRGOALS = BMRLIFESTYLE
                
            } else {
                
                BMRGOALS = BMRLIFESTYLE
                
            }
            
            Recommended.text = String(format: "%.0f Calories", BMRGOALS)
            defaults.set(String(format: "%.0f", BMRGOALS), forKey: "recommended-name")
            
            let imUsing = defaults.string(forKey: "using")
            let recomendation = defaults.string(forKey: "recommended-name")
            let rec = recomendation.flatMap { Float($0) } ?? 0
            
            if imUsing == "yes" {
                Slider.value = rec
                SliderLab.text = recomendation
                GoalSiwtch.setOn(true, animated: true)
                Slider.isUserInteractionEnabled = false
                use.text = "Using"
            }
        }
        
        AppDelegate.hideLoader()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count + range.length
        return newLength > 3 ? false : true
    }
    
    @IBAction func selectLifestylePressed(_ sender: AnyObject) {
        guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "LifeTableVC") as? UINavigationController else {
            return
        }
        
        guard let tableViewController = navigationController.viewControllers.first as? LifestyleTableView else {
            return
        }
        
        tableViewController.tableData = lifestyleArray
        tableViewController.navigationItem.title = "Lifestyle"
        tableViewController.delegate = self
        
        self.navigationController?.popToRootViewController(animated: true)
        present(navigationController, animated: true)
    }
    
    @IBAction func selectAnimalPressed(_ sender: AnyObject) {
        guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "SimpleTableVC") as? UINavigationController else {
            return
        }
        
        guard let tableViewController = navigationController.viewControllers.first as? PickerTableView else {
            return
        }
        
        tableViewController.tableData = genderArray
        tableViewController.navigationItem.title = "Gender"
        tableViewController.delegate = self
        
        self.navigationController?.popToRootViewController(animated: true)
        present(navigationController, animated: true)
    }
    
    @IBAction func selectGoalPressed(_ sender: AnyObject) {
        guard let navigationController = storyboard?.instantiateViewController(withIdentifier: "GoalTableVC") as? UINavigationController else {
            return
        }
        
        guard let tableViewController = navigationController.viewControllers.first as? GoalTableView else {
            return
        }
        
        tableViewController.tableData = goalArray
        tableViewController.navigationItem.title = "Goals"
        tableViewController.delegate = self
        
        self.navigationController?.popToRootViewController(animated: true)
        present(navigationController, animated: true)
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func itemSelectedLifestyle(atRow row: Int) {
        LifeButt.setTitle(lifestyleArray[row], for: .normal)
    }
    
    func itemSelectedGoal(atRow row: Int) {
        GoalButt.setTitle(goalArray[row], for: .normal)
    }
    
    func itemSelectedGender(atRow row: Int) {
        GenderButt.setTitle(genderArray[row], for: .normal)
    }
}
