//
//  Food+CoreDataProperties.swift
//  BeFit Tracker
//
//  Created by Andrej Slegl on 10/23/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "FoodObject")
    }

    @NSManaged public var sugars: NSNumber?
    @NSManaged public var sodium: NSNumber?
    @NSManaged public var saturatedFat: NSNumber?
    @NSManaged public var selectedServing: NSNumber?
    @NSManaged public var dietaryFiber: NSNumber?
    @NSManaged public var monosaturatedFat: NSNumber?
    @NSManaged public var vitaminA: NSNumber?
    @NSManaged public var calories: NSNumber?
    @NSManaged public var servingWeight2: NSNumber?
    @NSManaged public var vitaminE: NSNumber?
    @NSManaged public var servingDescription2: String?
    @NSManaged public var name: String?
    @NSManaged public var calcium: NSNumber?
    @NSManaged public var quantity: NSNumber?
    @NSManaged public var polyFat: NSNumber?
    @NSManaged public var servingWeight1: NSNumber?
    @NSManaged public var protein: NSNumber?
    @NSManaged public var cholesteral: NSNumber?
    @NSManaged public var servingDescription1: String?
    @NSManaged public var vitaminC: NSNumber?
    @NSManaged public var iron: NSNumber?
    @NSManaged public var userDefined: NSNumber?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var carbs: NSNumber?
    @NSManaged public var foodIntakeBelongsTO: NSSet?
    @NSManaged public var foodListsBelongTo: NSSet?

}

// MARK: Generated accessors for foodIntakeBelongsTO
extension Food {

    @objc(addFoodIntakeBelongsTOObject:)
    @NSManaged public func addToFoodIntakeBelongsTO(_ value: UserFoodRecords)

    @objc(removeFoodIntakeBelongsTOObject:)
    @NSManaged public func removeFromFoodIntakeBelongsTO(_ value: UserFoodRecords)

    @objc(addFoodIntakeBelongsTO:)
    @NSManaged public func addToFoodIntakeBelongsTO(_ values: NSSet)

    @objc(removeFoodIntakeBelongsTO:)
    @NSManaged public func removeFromFoodIntakeBelongsTO(_ values: NSSet)

}

// MARK: Generated accessors for foodListsBelongTo
extension Food {

    @objc(addFoodListsBelongToObject:)
    @NSManaged public func addToFoodListsBelongTo(_ value: FoodList)

    @objc(removeFoodListsBelongToObject:)
    @NSManaged public func removeFromFoodListsBelongTo(_ value: FoodList)

    @objc(addFoodListsBelongTo:)
    @NSManaged public func addToFoodListsBelongTo(_ values: NSSet)

    @objc(removeFoodListsBelongTo:)
    @NSManaged public func removeFromFoodListsBelongTo(_ values: NSSet)

}
