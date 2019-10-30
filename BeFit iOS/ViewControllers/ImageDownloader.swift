//
//  ImageDownloader.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

class ImageDownloader {
    private init() { }
    
    private let queue = DispatchQueue(label: "image downloader", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
    
    static let shared = ImageDownloader()
    
    func image(for url: URL, callback: @escaping (UIImage?, Error?) -> Void) {
        queue.async {
            var image: UIImage?
            var error: Error?
            
            do {
                let data = try Data(contentsOf: url)
                image = UIImage(data: data)
                
                if image == nil {
                    throw CustomError.unableToDecodeImage
                }
            } catch let err {
                error = err
                print("image loading failed for \"\(url)\":/n\(err.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                callback(image, error)
            }
        }
    }
}
