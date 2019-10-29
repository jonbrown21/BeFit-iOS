//
//  SwiftCommon.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/26/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

enum CustomError: Error {
    case unknownType
    case requiredObjectNil
    case invalidURL
    case fileNotFound
    case noManagedObjectContext
}

struct Constants {
    static let secondsPerHour: TimeInterval = 60 * 60
    static let secondsPerDay: TimeInterval = secondsPerHour * 24
}

extension CWColors {
    func color(forKey: String) -> UIColor {
        return (colors[forKey] as? UIColor) ?? .black
    }
}
