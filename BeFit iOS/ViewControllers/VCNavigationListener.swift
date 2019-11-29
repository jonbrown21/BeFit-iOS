//
//  VCNavigationListener.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 11/1/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

protocol VCNavigationListener: class {
    func didDisappear(viewController: UIViewController)
}
