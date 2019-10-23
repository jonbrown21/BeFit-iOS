//
//  UserFoodRecords+CoreDataProperties.swift
//  BeFit Tracker
//
//  Created by Andrej Slegl on 10/23/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//
//

import Foundation
import CoreData


extension UserFoodRecords {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserFoodRecords> {
        return NSFetchRequest<UserFoodRecords>(entityName: "UserFoodRecords")
    }

    @NSManaged public var date: String?
    @NSManaged public var servings: NSNumber?
    @NSManaged public var foodIntake: NSSet?

}

// MARK: Generated accessors for foodIntake
extension UserFoodRecords {

    @objc(addFoodIntakeObject:)
    @NSManaged public func addToFoodIntake(_ value: Food)

    @objc(removeFoodIntakeObject:)
    @NSManaged public func removeFromFoodIntake(_ value: Food)

    @objc(addFoodIntake:)
    @NSManaged public func addToFoodIntake(_ values: NSSet)

    @objc(removeFoodIntake:)
    @NSManaged public func removeFromFoodIntake(_ values: NSSet)

}
