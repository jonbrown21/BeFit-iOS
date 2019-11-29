//
//  CustomProgView.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/28/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class CustomProgView: UIProgressView {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: frame.size.width, height: 9)
    }
}
