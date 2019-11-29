//
//  CustomCell.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell, AsyncImageViewDelegate {
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var dev_label: UILabel!
    @IBOutlet weak var star_1: UIImageView!
    @IBOutlet weak var star_2: UIImageView!
    @IBOutlet weak var star_3: UIImageView!
    @IBOutlet weak var star_4: UIImageView!
    @IBOutlet weak var star_5: UIImageView!
    @IBOutlet private weak var logo_image: AsyncImageView!
    @IBOutlet private weak var logo_active: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply image boarder effects. It looks
        // much nicer with rounded corners. You can
        // also apply other effect too if you wish.
        logo_image.layer.cornerRadius = 16.0
        logo_image.clipsToBounds = true
        logo_active.clipsToBounds = true
        logo_image.delegate = self
    }
    
    func setLogoImage(_ imagePath: String?) {
        logo_active.stopAnimating()
        logo_image.set(imagePath: imagePath)
        
        if logo_image.loadingImageURL != nil {
            logo_active.startAnimating()
        }
    }
    
    func isLoadingChanged(asyncImageView: AsyncImageView, isLoading: Bool) {
        if !isLoading {
            logo_active.stopAnimating()
        }
    }
}
