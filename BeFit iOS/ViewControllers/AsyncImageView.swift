//
//  AsyncImageView.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

protocol AsyncImageViewDelegate: class {
    func isLoadingChanged(asyncImageView: AsyncImageView, isLoading: Bool)
}

class AsyncImageView: UIImageView {
    weak var delegate: AsyncImageViewDelegate?
    
    private(set) var loadingImageURL: URL?
    private(set) var currentImageURL: URL?
    
    func set(imagePath: String?) {
        set(imageURL: imagePath.flatMap { URL(string: $0) })
    }
    
    func set(imageURL: URL?) {
        // Set the app logo in the imageview. We will also be caching
        // the images in asynchronously so that there is no image
        // flickering issues and so the UITableView uns smoothly
        // while being scrolled.
        
        guard currentImageURL != imageURL else {
            return
        }
        
        image = nil
        currentImageURL = nil
        
        guard loadingImageURL != imageURL else {
            return
        }
        
        loadingImageURL = imageURL
        
        guard let url = imageURL else {
            return
        }
        
        delegate?.isLoadingChanged(asyncImageView: self, isLoading: true)
        
        ImageDownloader.shared.image(for: url) { [weak self] (image, _) in
            guard let me = self, me.loadingImageURL == url else {
                return
            }
            
            me.delegate?.isLoadingChanged(asyncImageView: me, isLoading: false)
            me.loadingImageURL = nil
            
            if let img = image {
                me.image = img
                me.currentImageURL = url
            }
        }
    }
}
