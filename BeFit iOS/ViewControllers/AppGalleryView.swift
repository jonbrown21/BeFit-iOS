//
//  AppGalleryView.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/29/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit

private let DEV_NAME = "jonbrowndesigns"
private let DEV_NAME2 = "thearcoftheunitedstates"
private let GALLERY_URL_FORMAT = "https://itunes.apple.com/search?term=%@&country=us&entity=software"

class AppGalleryView: UIViewController,
UITableViewDataSource,
UITableViewDelegate {
    //MARK: - Properties
    // TableView - show the logo, labels, etc...
    @IBOutlet weak var app_table: UITableView!
    //@IBOutlet weak var active: UIActivityIndicatorView! // Activity indicator - data loading.
    
    // JSON parsing - data storage.
    private var appItems: [AppGalleryItem] = []
    private var appItems2: [AppGalleryItem] = []
    
    // Detail view - pass data on.
    private var isRefreshing = false
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //MARK: - Methods
    
    @IBAction func refresh_button() {
        refresh()
    }
    
    @IBAction func done() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        app_table.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        app_table.delegate = self
        app_table.dataSource = self
        
        // Start loading the data.
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        app_table.reloadData()
    }
    
    private func handleBack(_ sender: AnyObject) {
        // pop to root view controller
        navigationController?.popToRootViewController(animated: true)
    }
    
    private static func fetchAppItems(from url: URL, callback: @escaping ([AppGalleryItem]?, Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(nil, CustomError.invalidResponse)
                return
            }
            
            let statusCode = httpResponse.statusCode
            guard statusCode >= 200 && statusCode < 300 else {
                callback(nil, CustomError.invalidHttpResponse(statusCode: statusCode))
                return
            }
            
            // otherwise, everything is probably fine and you should interpret the `data` contents
            
            guard let data = data else {
                callback(nil, CustomError.requiredObjectNil)
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let galleryResponse = try jsonDecoder.decode(AppGalleryResponse.self, from: data)
                
                callback(galleryResponse.results, nil)
            } catch let error {
                callback(nil, error)
            }
        }.resume()
    }
    
    private func refresh() {
        guard !isRefreshing else {
            print("already refreshing...")
            return
        }
        
        // Setup the JSON url and download the data on request.
        let link1 = String(format: GALLERY_URL_FORMAT, DEV_NAME)
        let link2 = String(format: GALLERY_URL_FORMAT, DEV_NAME2)
        
        guard let url1 = URL(string: link1),
            let url2 = URL(string: link2) else {
            assertionFailure()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var error1: Error?
        var error2: Error?
        var items1: [AppGalleryItem]?
        var items2: [AppGalleryItem]?
        
        dispatchGroup.enter()
        AppGalleryView.fetchAppItems(from: url1) {
            items1 = $0
            error1 = $1
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        AppGalleryView.fetchAppItems(from: url2) {
            items2 = $0
            error2 = $1
            dispatchGroup.leave()
        }
        
        DispatchQueue.main.async {
            ProgressHUD.show("Please wait...")
        }
        
        isRefreshing = true
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            ProgressHUD.dismiss()
            self?.isRefreshing = false
            //self?.active.stopAnimating()
            
            if let error = error1 ?? error2 {
                print("Fetching Gallery Items failed:\n", error.localizedDescription)
                
                let msg = String(format: "Failed: %@", error.localizedDescription)
                let alert = UIAlertController(title: "Data loading error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
                    self?.presentedViewController?.dismiss(animated: true)
                })
                
                self?.present(alert, animated: true)
            } else {
                // If there is no error all the items should be set
                self?.appItems = items1!
                self?.appItems2 = items2!
                self?.app_table.reloadData()
            }
        }
    }
    
    private func createDetailViewController(for item: AppGalleryItem, dev_name: String) -> DetailView {
        // Edit the input size to MB.
        let size = (item.fileSizeBytes.flatMap { Double($0) } ?? 0) / (1024 * 1024)
        let rating = Int(item.averageUserRatingForCurrentVersion ?? 0)
        let newStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let firstvc = newStoryboard.instantiateViewController(withIdentifier: "more_detailview") as! DetailView
        
        // Set the data to be passed - names, links, etc...
        firstvc.input_name = item.trackName ?? ""
        firstvc.input_dev_name = dev_name
        firstvc.input_price = item.formattedPrice ?? ""
        firstvc.input_size = String(format: "%.1fMB", size)
        firstvc.input_age = item.contentAdvisoryRating ?? ""
        firstvc.input_version = String(format: "V%@", item.version ?? "")
        firstvc.input_id = String(format: "%d", item.trackId ?? 0)
        firstvc.input_rating = String(format: "%d", rating)
        firstvc.input_logo_link = item.artworkUrl512 ?? ""
        firstvc.input_description = item.description ?? ""
        
        // Pass the screenshot array. We will show the
        // correct image type depending on the device
        // and then what type of screenshots are available.
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            // If the device is an iPad, we will show iPad
            // size screenshots. However if the app is an iPhone
            // only app then we will have to show the iPhone
            // sized screenshots.
            
            if item.ipadScreenshotUrls?.count ?? 0 > 0 {
                firstvc.input_screenshot = item.ipadScreenshotUrls ?? []
            } else {
                firstvc.input_screenshot = item.screenshotUrls ?? []
            }
        } else {
            // If the device is an iPhone/iPod Touch, we will show
            // iPhone size screenshots. However if the app is an iPad
            // only app then we will have to show the iPad sized screenshots.
            
            if item.screenshotUrls?.count ?? 0 > 0 {
                firstvc.input_screenshot = item.screenshotUrls ?? []
            } else {
                firstvc.input_screenshot = item.ipadScreenshotUrls ?? []
            }
        }
        
        return firstvc
    }
    
    //MARK: - UITableView methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let defaultPrefsURL = Bundle.main.path(forResource: "defaultPrefs", ofType: "plist").flatMap({ URL(fileURLWithPath: $0, isDirectory: false) }) {
            if let data = try? Data(contentsOf: defaultPrefsURL) {
                var format = PropertyListSerialization.PropertyListFormat.xml
                if let defaultPreferences = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String: AnyObject] {
                    UserDefaults.standard.register(defaults: defaultPreferences)
                }
            }
        }
        
        switch indexPath.section {
        case 0:
            let item = appItems[indexPath.row]
            let selectedValue = item.trackName ?? ""
            let cellValue: String
            
            if selectedValue == "Animal Age Converter" {
                cellValue = "0"
            } else if selectedValue == "Seafood Guide" {
                cellValue = "1"
            } else if selectedValue == "We're Gurus!" {
                cellValue = "2"
            } else if selectedValue == "BeFit Tracker" {
                cellValue = "3"
            } else {
                cellValue = ""
            }
            
            print("WHY", cellValue)
            
            // Open the detail view and pass the data
            // to be presented in detail to the user.
            
            let firstvc = createDetailViewController(for: item, dev_name: "Jon Brown Designs")
            
            present(firstvc, animated: true) { [weak tableView] in
                tableView?.deselectRow(at: indexPath, animated: true)
            }
            
        case 1:
            print("WHY 2")
            
            let firstvc = createDetailViewController(for: appItems2[indexPath.row], dev_name: "The Arc")
            
            present(firstvc, animated: true) { [weak tableView] in
                tableView?.deselectRow(at: indexPath, animated: true)
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        
        func setupCell(with item: AppGalleryItem, dev_name: String) {
            let item = appItems[indexPath.row]
            // Set the labels - name, info, etc...
            cell.name_label.text = item.trackName ?? ""
            cell.dev_label.text = dev_name
            
            let rating = Int(item.averageUserRatingForCurrentVersion ?? 0)
            cell.star_1.alpha = rating >= 1 ? 1 : 0
            cell.star_2.alpha = rating >= 2 ? 1 : 0
            cell.star_3.alpha = rating >= 3 ? 1 : 0
            cell.star_4.alpha = rating >= 4 ? 1 : 0
            cell.star_5.alpha = rating >= 5 ? 1 : 0
            
            cell.setLogoImage(item.artworkUrl512)
        }
        
        switch indexPath.section {
        case 0:
            setupCell(with: appItems[indexPath.row], dev_name: "Jon Brown Designs")
            
        case 1:
            setupCell(with: appItems2[indexPath.row], dev_name: "The Arc")
            
        default:
            break
        }
        
        let isHidden = indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)
        cell.contentView.isHidden = isHidden
        cell.accessoryType = isHidden ? .none : .disclosureIndicator
        
        // Set the cell background colour.
        cell.backgroundColor = .white
        
        // Set the content restraints. Keep things in place
        // otherwise the image/labels dont seem to appear in
        // the correct position on the cell.
        cell.name_label.clipsToBounds = true
        cell.dev_label.clipsToBounds = true
        cell.star_1.clipsToBounds = true
        cell.star_2.clipsToBounds = true
        cell.star_3.clipsToBounds = true
        cell.star_4.clipsToBounds = true
        cell.star_5.clipsToBounds = true
        cell.contentView.clipsToBounds = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let heightForRow: CGFloat = 116
        
        if indexPath.section == 1 {
            if indexPath.row == 0 || indexPath.row == 1 {
                return 0
            }
        }
        
        return heightForRow
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Our Apps"
            
        case 1:
            return "Contributed"
            
        default:
            return "Contributed"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return appItems.count
            
        case 1:
            return appItems2.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50
            
        case 1:
            return 50
            
        default:
            return 50
        }
    }
    
    
}
