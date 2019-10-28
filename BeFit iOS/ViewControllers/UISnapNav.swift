//
//  UISnapNav.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/28/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class UISnapNav: UINavigationController, UINavigationBarDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBar.appearance()
        appearance.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        appearance.shadowImage = UIImage()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
