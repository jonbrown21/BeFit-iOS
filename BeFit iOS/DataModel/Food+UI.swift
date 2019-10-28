//
//  Food+UI.swift
//  BeFit Tracker
//
//  Created by Andrej Slegl on 10/23/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

extension Food {
    @objc var uppercaseFirstLetterOfName: String? {
        willAccessValue(forKey: "uppercaseFirstLetterOfName")
        
        let val = name?.first?.uppercased()
        
        didAccessValue(forKey: "uppercaseFirstLetterOfName")
        
        return val
    }
    
    func setNameValue(_ value: String) {
        name = value
    }
    
    func setCalValue(_ value: String) {
        guard let int64Value = Int64(value) else {
            assertionFailure()
            return
        }
        
        calories = NSNumber(value: int64Value)
    }
    
    // MARK: - Bool
    
    @objc var hideServing: Bool {
        return servingDescription1?.lowercased() == "1 item"
    }
    
    @objc var changableColumnIsEditable: Bool {
        return false
    }
    
    // MARK: - STRINGS
    
    @objc var calciumValue: String {
        return CalculateValues("calcium")
    }
    @objc var calciumValuePerc: String {
        return CalculatePercent("calcium", divider: 10)
    }
    @objc var carbsPercent: String {
        return CalculatePercent("carbs", divider: 3.0)
    }
    @objc var carbsValue: String {
        return CalculateValues("carbs")
    }
    @objc var cholesterolPercent: String {
        return CalculatePercent("cholesteral", divider: 3.0)
    }
    @objc var cholesterolValue: String {
        return CalculateValues("cholesteral")
    }
    @objc var dietaryFiberPercent: String {
        return CalculatePercent("dietaryFiber", divider: 0.25)
    }
    @objc var dietaryFiberValue: String {
        return CalculateValues("dietaryFiber")
    }
    @objc var ironValue: String {
        return CalculateValues("iron")
    }
    @objc var ironValuePerc: String {
        return CalculatePercent("iron", divider: 1.8)
    }
    @objc var monounsaturatedFatValue: String {
        return CalculateValues("monosaturatedFat")
    }
    @objc var nameValue: String {
        return name ?? ""
    }
    @objc var polyunsaturatedFatValue: String {
        return CalculateValues("polyFat")
    }
    @objc var proteinValue: String {
        return CalculateValues("protein")
    }
    @objc var saturatedFatPercent: String {
        return CalculatePercent("saturatedFat", divider: 0.20)
    }
    @objc var saturatedFatValue: String {
        return CalculateValues("saturatedFat")
    }
    @objc var sodiumPercent: String {
        return CalculatePercent("sodium", divider: 24)
    }
    @objc var sodiumValue: String {
        return CalculateValues("sodium")
    }
    @objc var sugarsValue: String {
        return CalculateValues("sugars")
    }
    @objc var vitaminAValue: String {
        return CalculateValues("vitaminA")
    }
    @objc var vitaminCValue: String {
        return CalculateValues("vitaminC")
    }
    @objc var vitaminCValuePerc: String {
        return CalculatePercent("vitaminC", divider: 6)
    }
    @objc var servingAmount1Value: String {
        return servingDescription1 ?? ""
    }
    @objc var caloriesLongValueTip: String {
        return String(format: "%ld", caloriesLongValue)
    }
    @objc var viteValue: String {
        return CalculateValues("vitaminE")
    }
    @objc var vitaminEValuePerc: String {
        return CalculatePercent("vitaminE", divider: 9.5)
    }
    @objc var vitaminAValuePerc: String {
        return CalculatePercent("vitaminA", divider: 50)
    }
    @objc var polyFatValuePerc: String {
        return CalculatePercent("polyFat", divider: 9)
    }
    @objc var monoFatValuePerc: String {
        return CalculatePercent("monosaturatedFat", divider: 11)
    }
    @objc var CarbsPrint: String {
        return String(format: "%@ / 300mg", carbsValue)
    }
    @objc var CholPrint: String {
        return String(format: "%ld / 300mg", cholesterolValueAsLong)
    }
    @objc var protPrint: String {
        return String(format: "%@ / 50g", proteinValue)
    }
    @objc var sodPrint: String {
        return String(format: "%@ / 2400mg", sodiumValue)
    }
    @objc var fibPrint: String {
        return String(format: "%@ / 25g", dietaryFiberValue)
    }
    @objc var tfatPrint: String {
        return String(format: "%ld / 50g", sugarsValueAsLong)
    }
    
    @objc var transFatValue: String {
        let ValueToDisplay = totalFatValueAsDouble
        let totalFat = saturatedFat?.doubleValue ?? 0
        let transfat = ValueToDisplay - totalFat
        var QuantityActualValue: Double = 1
        
        if let quantityNumber = quantity {
            QuantityActualValue = quantityNumber.doubleValue
            if QuantityActualValue <= 0 {
                QuantityActualValue = 1
            }
        }
        
        var actualValue = round(((transfat * selectedServingWeight.doubleValue) / 100) * QuantityActualValue)
        let userValue = round(transfat * QuantityActualValue)
        
        if actualValue < 0 {
            actualValue = 0
        } else if actualValue == 0 {
            actualValue = 0
        }
        
        if userDefined?.intValue == 0 {
            return String(format: "%.0lfg", userValue)
        } else {
            return String(format: "%.0lfg", actualValue)
        }
    }
    
    @objc var caloriesStringValue: String {
        return String(format: "%ldg", calories?.int64Value ?? 0)
    }
    
    @objc var CalsPrint: String
    {
        let defaults = UserDefaults.standard
        var lbsprefint = defaults.double(forKey: "goal-name")
        
        if lbsprefint < 0 {
            lbsprefint = 2000
        }
        
        return String(format: "%ld / %.f", caloriesLongValue, round(lbsprefint))
    }
    
    @objc var caloriesFromFatValue: String
    {
        var QuantityActualValue: Int64 = 1
        
        if let quantityNumber = quantity {
            QuantityActualValue = quantityNumber.int64Value
            if QuantityActualValue <= 0 {
                QuantityActualValue = 1
            }
        }
        
        let totalFat = (saturatedFat?.doubleValue ?? 0) + (monosaturatedFat?.doubleValue ?? 0) + (polyFat?.doubleValue ?? 0)
        let intermediateValue = totalFat * 9
        let endingValue = ((intermediateValue * selectedServingWeight.doubleValue) / 100) * Double(QuantityActualValue)
        return String(format: "%.0lf", endingValue)
    }
    
    @objc var totalFatValueAsDouble: Double {
        let QuantityActualValue: Int64 = 1
        let totalFat = (saturatedFat?.doubleValue ?? 0.0) + (monosaturatedFat?.doubleValue ?? 0.0) + (polyFat?.doubleValue ?? 0.0)
        let servingWeight = selectedServingWeight.int64Value * QuantityActualValue
        let calculatedFat = ((totalFat * Double(servingWeight)) / 100) * Double(QuantityActualValue)
        
        if userDefined?.intValue == 0 {
            return round(calculatedFat)
        } else {
            return round(totalFat)
        }
    }
    
    @objc var totalFatValue: String {
        let QuantityActualValue: Double = 1
        let valueToDisplay = totalFatValueAsDouble * QuantityActualValue
        return String(format: "%.0lfg", valueToDisplay)
    }
    
    @objc var calfromFatValuePerc: String {
        return CalculatePerc(nil, divider:2000, long: caloriesLongValue)
    }
    
    @objc var totalFatPercent: String {
        return CalculatePerc("totalfat", divider:65, long:0)
    }
    
    @objc var totalValuePerc: String {
        let totalFat = (saturatedFat?.doubleValue ?? 0) + (monosaturatedFat?.doubleValue ?? 0) + (polyFat?.doubleValue ?? 0)
        let intermediateValue = totalFat * 9
        
    #if USEDTOBE
        let Result = (intermediateValue / selectedServingWeight.doubleValue) * 100
        return String(format: "%.0lf%%", Result)
    #endif
        let Result = (intermediateValue / selectedServingWeight.doubleValue) * 100
        let valueForDisplay = Result / 100
        return String(format: "%.0lf%%", valueForDisplay)
    }
    
    @objc var proteinValuePerc: String {
        let totalProt = protein?.doubleValue ?? 0
        let totalCals = calories?.doubleValue ?? 0
        
        guard totalCals > 0 else {
            return "NO CALORIES!"
        }
        
    #if USEDTOBE
        let ValueForCalculation = totalProt * 4
        let Result = (ValueForCalculation / totalCals) * 100
        
        return String(format: "%.0lf%%", Result)
    #endif
        let valueForCalculation = totalProt * 4
        let Result = (valueForCalculation / totalCals) * 100
        
        let valueForDisplay = ((Result * selectedServingWeight.doubleValue) / 100)
        return String(format: "%.0lf%%", valueForDisplay)
    }
    
    @objc var sugarsValuePerc: String {
        let totalSugar = sugars?.doubleValue ?? 0
        
    #if USEDTOBE
        let Result = (totalSugar / selectedServingWeight.doubleValue) * 100
        return String(format: "%.0lf%%", Result)
    #endif
        let Result = (totalSugar / selectedServingWeight.doubleValue) * 100
        let valueForDisplay = Result / 100
        return String(format: "%.0lf%%", valueForDisplay)
    }
    
    @objc var servingAmount2Value: String? {
        return servingDescription2
    }
    
    @objc var servingAmountValue: String? {
        let indexOfItem = selectedServing?.intValue ?? 0
        
        if indexOfItem == 1 {
            return servingAmount2Value
        }
        
        return servingDescription1
    }
    
    // MARK: - DOUBLES
    
    @objc var calciumValueAsDouble: Double {
        return CalculateDouble("calcium")
    }
    @objc var ironValueAsDouble: Double {
        return CalculateDouble("iron")
    }
    @objc var monounsaturatedFatValueAsDouble: Double {
        return CalculateDouble("monosaturatedFat")
    }
    @objc var polyunsaturatedFatValueAsDouble: Double {
        return CalculateDouble("polyFat")
    }
    @objc var saturatedFatValueAsDouble: Double {
        return CalculateDouble("saturatedFat")
    }
    @objc var vitaminCValueAsDouble: Double {
        return CalculateDouble("vitaminC")
    }
    @objc var vitaminAValueAsDouble: Double {
        return CalculateDouble("vitaminA")
    }
    @objc var vitaminEValueAsDouble: Double {
        return CalculateDouble("vitaminE")
    }
    
    // MARK: - LONG
    
    @objc var selectedServingWeight: NSNumber {
        let indexOfItem = selectedServing?.intValue ?? 0
        if selectedServing == nil {
            print("selectedServing should never be null")
        }
        
        if indexOfItem == 1 {
            return servingWeight2 ?? NSNumber(value: 0)
        } else {
            return servingWeight1 ?? NSNumber(value: 0)
        }
    }
    
    @objc var sodiumValueAsLong: Int64 {
        return CalculateLong("sodium")
    }
    @objc var proteinValueAsLong: Int64 {
        return CalculateLong("protein")
    }
    @objc var sugarsValueAsLong: Int64 {
        return CalculateLong("sugars")
    }
    @objc var caloriesValue: Int64 {
        return calories?.int64Value ?? 0
    }
    @objc var dietaryFiberValueAsLong: Int64 {
        return CalculateLongAdj("dietaryFiber")
    }
    @objc var cholesterolValueAsLong: Int64 {
        return  CalculateLongAdj("cholesteral")
    }
    @objc var carbsValueAsLong: Int64 {
        return CalculateLongAdj("carbs")
    }
    
    @objc var caloriesLongValue: Int64 {
        let originalCalorieValue = calories?.int64Value ?? 0
        
        return originalCalorieValue
    }
    
    @objc var quantityLongValue: Int64 {
        var actualValue: Int64 = 1
        
        if let quantityNumber = quantity {
            actualValue = quantityNumber.int64Value
            if actualValue <= 0 {
                actualValue = 1
            }
        }
        
        return actualValue
    }
    
    @objc var calFromDiet: Int64 {
        //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        //NSString*  lbspref = [defaults objectForKey:@"goal-name"];
        //long yourLong = [lbspref longLongValue];
        let originalCalorieRatingValue = calories?.int64Value ?? 0
        
        //NSString *calValue =  Cals;
        //long yourCals = [ self caloriesLongValue ];
        //long result = (yourLong - yourCals);
        
        return originalCalorieRatingValue
    }
    
    @objc var ratingLongValue: Int64 {
        let ValueForCalculation = Double(caloriesLongValue)
        let Result = (ValueForCalculation / 2000) * 100
        
        //Round it to one decimal
        let CaloriesRatingPercent = round(10 * Result) / 10
        
        if CaloriesRatingPercent >= 0 && CaloriesRatingPercent <= 21 {
            return 5
        } else if CaloriesRatingPercent >= 21 && CaloriesRatingPercent <= 41 {
            return 4
        } else if CaloriesRatingPercent >= 41 && CaloriesRatingPercent <= 61 {
            return 3
        } else if CaloriesRatingPercent >= 61 && CaloriesRatingPercent <= 81 {
            return 2
        } else if CaloriesRatingPercent >= 81 && CaloriesRatingPercent <= 100 {
            return 1
        } else if CaloriesRatingPercent > 100 {
            return 1
        }
        
        return 0
    }
    
    // MARK: - INT
    
    @objc var servingWeight1Value: Int64 {
        return servingWeight1?.int64Value ?? 0
    }
    
    @objc var indexOfServingBeingDisplayed: Int64 {
        return selectedServing?.int64Value ?? 0
    }
    
    // MARK: - Food Values FLOATS
    
    @objc var caloriesFloatValuePerc: Float {
        return CalculateFloat("calories", divider: 2000)
    }
    @objc var calfromFatValuePercFloat: Float {
        return CalculateFloat("calfromfat", divider: 80)
    }
    @objc var saturatedFatPercentFloat: Float {
        return CalculateFloat("saturatedFat", divider: 25)
    }
    @objc var totalFatPercentfloat: Float {
        return CalculateFloat("totalFat", divider: 65)
    }
    @objc var monoSaturatedFatPercentFloat: Float {
        return CalculateFloat("monosaturatedFat", divider: 24)
    }
    @objc var cholPercentFloat: Float {
        return CalculateFloat("cholesteral", divider: 300)
    }
    
    // MARK: - FUNCTIONS
    
    func calculateValues(_ key: String) -> String? {
        let QuantityActualValue: Double = 1
        let userValue = (value(forKey: key) as? NSNumber)?.doubleValue ?? 0.0 * QuantityActualValue
        let actualValue = (((value(forKey: key) as? NSNumber)?.doubleValue ?? 0.0 * selectedServingWeight.doubleValue) / 100) * QuantityActualValue

        if userDefined?.intValue == 0 {
            if key == "sodium" || key == "calcium" || key == "iron" || key == "vitaminC" || key == "vitaminA" {
                return String(format: "%.0lfmg", actualValue)
            }
            
            if key == "cholesteral" {
                return String(format: "%.0lfmg", userValue)
            }
            
            return String(format: "%.0lfg", actualValue)
        } else {
            if key == "sodium" || key == "cholesteral" || key == "calcium" || key == "iron" || key == "vitaminC" || key == "vitaminA" {
                return String(format: "%.0lfmg", userValue)
            }
            
            return String(format: "%.0lfg", userValue)
        }
    }
    
    func CalculateFloat(_ key: String, divider diverToUse: Double) -> Float {
        let QuantityActualValue: Double = 1
        
        if key == "calfromfat" {
            let totalFat = (saturatedFat?.doubleValue ?? 0) + (monosaturatedFat?.doubleValue ?? 0) + (polyFat?.doubleValue ?? 0)
            let intermediateValue = totalFat * 9
            let endingValue = ((intermediateValue * selectedServingWeight.doubleValue) / 100) * QuantityActualValue
            
            let finalValue = Float(endingValue / diverToUse)
            if finalValue > 1 {
                return 0.99
            } else if finalValue >= 0 && finalValue <= 0.06 {
                return 0.12
            } else {
                return finalValue
            }
        }
        
        if key == "totalFat" {
            let totalFat = (saturatedFat?.doubleValue ?? 0) + (monosaturatedFat?.doubleValue ?? 0) + (polyFat?.doubleValue ?? 0)
            let userResult = round(totalFat)
            let myFloatTotal = Float(userResult / diverToUse)
            
            if myFloatTotal > 1 {
                return 0.99
            } else if myFloatTotal >= 0 && myFloatTotal <= 0.06 {
                return 0.12
            } else {
                return myFloatTotal
            }
        }
        
        let calLong = (value(forKey: key) as? NSNumber)?.int64Value ?? 0
        let myFloat = Float(calLong) / Float(diverToUse)
        
        if myFloat > 1 {
            return 0.99
        } else if myFloat >= 0 && myFloat <= 0.06 {
            return 0.12
        }  else {
            return myFloat
        }
    }
    
    func CalculatePerc(_ key: String?, divider diverToUse: Double, long longtouse: Int64) -> String {
        if key == "totalfat" {
            let totalFat = (saturatedFat?.doubleValue ?? 0) + (monosaturatedFat?.doubleValue ?? 0) + (polyFat?.doubleValue ?? 0)
            let result = round((totalFat / diverToUse) * 100)
            let userResult = round(totalFat)
            
            if userDefined?.intValue == 1 {
                return String(format: "%.0lf%%", userResult)
            } else {
                return String(format: "%.0lf%%", result)
            }
        }
        
        let ValueForCalculation = longtouse
        let Result = round((Double(ValueForCalculation) / diverToUse) * 100)
        
        return String(format: "%.0lf%%", Result)
    }
    
    func CalculateDouble(_ key: String) -> Double {
        var QuantityActualValue: Int64 = 1
        
        if let quantityNumber = quantity {
            QuantityActualValue = quantityNumber.int64Value
            if QuantityActualValue <= 0 {
                QuantityActualValue = 1
            }
        }
        
        let int64Value = (value(forKey: key) as? NSNumber)?.int64Value ?? 0
        let userValue = int64Value * QuantityActualValue
        let actualValue = ((int64Value * selectedServingWeight.int64Value) / 100) * QuantityActualValue
        
        if userDefined?.intValue == 0 {
            return Double(userValue)
        } else {
            return Double(actualValue)
        }
    }
    
    func CalculateValues(_ key: String) -> String {
        let QuantityActualValue: Double = 1
        
        let doubleValue = (value(forKey: key) as? NSNumber)?.doubleValue ?? 0
        let userValue = doubleValue * QuantityActualValue
        let actualValue = (( doubleValue * selectedServingWeight.doubleValue) / 100) * QuantityActualValue
        
        if userDefined?.intValue == 0 {
            if key == "sodium" || key == "calcium" || key == "iron" || key == "vitaminC" || key == "vitaminA" {
                return String(format: "%.0lfmg", actualValue)
            }
            if key == "cholesteral" {
                return String(format: "%.0lfmg", userValue)
            }
            return String(format: "%.0lfg", actualValue)
        } else {
            if key == "sodium" || key == "cholesteral" || key == "calcium" || key == "iron" || key == "vitaminC" || key == "vitaminA" {
                return String(format: "%.0lfmg", userValue)
            }
            return String(format: "%.0lfg", userValue)
        }
    }
    
    func CalculateLongAdj(_ key: String) -> Int64 {
        var QuantityActualValue: Int64 = 1
        
        if let quantityNumber = quantity {
            QuantityActualValue = quantityNumber.int64Value
            if QuantityActualValue <= 0 {
                QuantityActualValue = 1
            }
        }
        let carbsL = ((value(forKey: key) as? NSNumber)?.int64Value ?? 0) * QuantityActualValue
        
        return carbsL
    }
    
    func CalculateLong(_ key: String) -> Int64 {
        var QuantityActualValue: Int64 = 1
        
        if let quantityNumber = quantity {
            QuantityActualValue = quantityNumber.int64Value
            if QuantityActualValue <= 0 {
                QuantityActualValue = 1
            }
        }
        
        let int64Value = (value(forKey: key) as? NSNumber)?.int64Value ?? 0
        let userValue = int64Value * QuantityActualValue
        let actualValue = ((int64Value * selectedServingWeight.int64Value) / 100) * QuantityActualValue
        
        if userDefined?.intValue == 0 {
            return userValue
        } else {
            return actualValue
        }
    }
    
    func CalculatePercent(_ key: String, divider diverToUse: Double) -> String {
    #if USEDTOBE
        let ValueForCalculation = (value(forKey: key) as? NSNumber)?.doubleValue ?? 0
        let Result = (ValueForCalculation / diverToUse) * 100
        
        //Round it to one decimal
        let ValueToDisplay = round(10 * Result) / 10
        
        return String(format: "%.0lf%%", ValueToDisplay)
    #endif
        let valueForCalculation = (value(forKey: key) as? NSNumber)?.doubleValue ?? 0
        let intermediateValue1 = ((valueForCalculation * selectedServingWeight.doubleValue) / 100)
        let valueForDisplay = (intermediateValue1 / diverToUse)
        
        return String(format: "%.0lf%%", valueForDisplay)
    }
    
    func setIndexOfServingBeingDisplayed(_ indexToSet: Int64) {
        selectedServing = NSNumber(value: indexToSet)
    }
}
