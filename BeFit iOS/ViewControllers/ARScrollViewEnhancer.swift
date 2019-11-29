//
//  ARScrollViewEnhancer.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class ARScrollViewEnhancer: UIView {
    @IBOutlet weak var scrollView: UIScrollView?
    
    override func hitTest(_ pt: CGPoint, with event: UIEvent?) -> UIView? {
        if point(inside: pt, with: event) {
            return scrollView
        }
        
        return nil
    }
}
