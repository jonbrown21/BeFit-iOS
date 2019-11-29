//
//  AppGalleryResponse.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation

struct AppGalleryResponse: Decodable {
    let results: [AppGalleryItem]
}

struct AppGalleryItem: Decodable {
    /// App Name
    let trackName: String?
    
    /// Dev Name
    let sellerName: String?
    
    /// App Price
    let formattedPrice: String?
    
    /// App Icon
    let artworkUrl512: String?
    
    /// Screenshots iPhone
    let screenshotUrls: [String]?
    
    /// Screenshots iPad
    let ipadScreenshotUrls: [String]?
    
    /// App ID
    let trackId: Int?
    
    /// App version
    let version: String?
    
    /// App Description
    let description: String?
    
    /// Age
    let contentAdvisoryRating: String?
    
    /// App Rating
    let averageUserRatingForCurrentVersion: Float?
    
    /// App Size in bytes
    let fileSizeBytes: String?
}
