//
//  ImageDownloader.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

class ImageDownloader {
    typealias ImageCallback = (UIImage?, Error?) -> Void
    
    private class Downloader {
        let url: URL
        private var callbacks = [ImageCallback]()
        
        init(url: URL) {
            self.url = url
        }
        
        func download(on queue: DispatchQueue, callback: @escaping ImageCallback) {
            let wasEmpty = callbacks.isEmpty
            callbacks.append(callback)
            
            guard wasEmpty else {
                return
            }
            
            queue.async {
                var image: UIImage?
                var error: Error?
                
                do {
                    let data = try Data(contentsOf: self.url)
                    image = UIImage(data: data)
                    
                    if image == nil {
                        throw CustomError.unableToDecodeImage
                    }
                } catch let err {
                    error = err
                    print("image loading failed for \"\(self.url)\":/n\(err.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    var tmp = [ImageCallback]()
                    swap(&tmp, &self.callbacks)
                    
                    for callback in tmp {
                        callback(image, error)
                    }
                }
            }
        }
    }
    
    private init() {
    }
    
    static let shared = ImageDownloader()
    
    private let queue = DispatchQueue(label: "image downloader", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
    private var downloaders = [URL: Downloader]()
    
    func image(for url: URL, callback: @escaping ImageCallback) {
        assert(Thread.isMainThread)
        let downloader = downloaders[url] ?? Downloader(url: url)
        downloaders[url] = downloader
        downloader.download(on: queue, callback: callback)
    }
}
