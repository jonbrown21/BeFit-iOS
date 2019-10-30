//
//  CustomCell.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var dev_label: UILabel!
    @IBOutlet weak var star_1: UIImageView!
    @IBOutlet weak var star_2: UIImageView!
    @IBOutlet weak var star_3: UIImageView!
    @IBOutlet weak var star_4: UIImageView!
    @IBOutlet weak var star_5: UIImageView!
    @IBOutlet private weak var logo_image: UIImageView!
    @IBOutlet private weak var logo_active: UIActivityIndicatorView!
    
    private var loadingImageURL: URL?
    private var currentImageURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Apply image boarder effects. It looks
        // much nicer with rounded corners. You can
        // also apply other effect too if you wish.
        logo_image.layer.cornerRadius = 16.0
        logo_image.clipsToBounds = true
        logo_active.clipsToBounds = true
    }
    
    func setLogoImage(_ imagePath: String?) {
        logo_active.stopAnimating()
        loadImage(imagePath)
        
        if loadingImageURL != nil {
            logo_active.startAnimating()
        }
    }
    
    private func loadImage(_ imagePath: String?) {
        // Set the app logo in the imageview. We will also be caching
        // the images in asynchronously so that there is no image
        // flickering issues and so the UITableView uns smoothly
        // while being scrolled.
        
        let imageURL = imagePath.flatMap { URL(string: $0) }
        guard currentImageURL != imageURL else {
            return
        }
        
        logo_image.image = nil
        currentImageURL = nil
        
        guard loadingImageURL != imageURL else {
            return
        }
        
        loadingImageURL = imageURL
        
        guard let url = imageURL else {
            return
        }
        
        ImageDownloader.shared.image(for: url) { [weak self] (image, _) in
            guard self?.loadingImageURL == url else {
                return
            }
            
            self?.logo_active.stopAnimating()
            self?.loadingImageURL = nil
            
            if let img = image {
                self?.logo_image.image = img
                self?.currentImageURL = url
            }
        }
    }
}
