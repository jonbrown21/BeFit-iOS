//
//  PresentingNavigationController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 11/1/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

class PresentingNavigationController: UINavigationController {
    weak var navigationListener: VCNavigationListener?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationListener?.didDisappear(viewController: self)
    }
}
