//
//  DetailView.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/30/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Social
import Accounts

// You cam change the message to whatever you want.
// However, make sure you leave the two '%@' symbols
// in the message, as they are automatically replaced
// by the 'app name' and 'developer name' respectively.
// The app url link is also attatched to the share sheet.
let SHARE_MESS = "Check out %@ #app by %@"

// Once again you can edit the email message but make
// sure you leave the three '%@' signs. The email string
// contains an extra '%@' symbol which is automatically
// replaced with the app url link.
let SHARE_MESS_EMAIL = "Check out %@ app by %@ - %@"

let APP_LINK_FORMAT = "http://itunes.apple.com/app/id%@"

class DetailView: UIViewController,
UIActionSheetDelegate,
MFMessageComposeViewControllerDelegate,
MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate {
    //MARK: - Properties
    
    // Labels - name, version, etc...
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_dev_name: UILabel!
    @IBOutlet weak var label_price: UILabel!
    @IBOutlet weak var label_age: UILabel!
    @IBOutlet weak var label_version: UILabel!
    @IBOutlet weak var label_size: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Rating star images.
    @IBOutlet weak var star_1: UIImageView!
    @IBOutlet weak var star_2: UIImageView!
    @IBOutlet weak var star_3: UIImageView!
    @IBOutlet weak var star_4: UIImageView!
    @IBOutlet weak var star_5: UIImageView!
    
    // Images - logo & screenshots.
    @IBOutlet weak var app_logo: AsyncImageView!
    
    // Main scroll view - for all content.
    @IBOutlet weak var scroll: UIScrollView!
    
    // Description label - iPad ONLY.
    // On the iPhone the description is
    // shown in a Alert View.
    @IBOutlet weak var description_text: UITextView!
    
    // iPad Only - black activity indicator view.
    //@IBOutlet weak var active_black: UIActivityIndicatorView!
    //@IBOutlet weak var background_active_black: UIView!
    
    // App download link - for sharing and
    // for opening the app store app.
    var url_with_id: String!
    
    // Input data - name, logo, etc...
    var input_name: String!
    var input_dev_name: String!
    var input_logo_link: String!
    var input_price: String!
    var input_age: String!
    var input_version: String!
    var input_size: String!
    var input_rating: String!
    var input_id: String!
    var input_description: String!
    var input_screenshot: [String]!
    
    // Current screenshot being viewed.
    //private var current_screenshot: Int = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Buttons
    
    @IBAction func done() {
        dismiss(animated: true)
    }
    
    @IBAction func share() {
        let actionSheetTitle = "Share app"
        let button_1 = "Facebook"
        let button_2 = "Twitter"
        let button_3 = "Email"
        let button_4 = "Copy Link"
        let cancelTitle = "Cancel"
        
        //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionSheetTitle delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:button_1, button_2, button_3, button_4, nil];
        
        //[actionSheet showInView:self.view];
        
        let actionSheet = UIAlertController(title: actionSheetTitle, message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        actionSheet.addAction(UIAlertAction(title: button_1, style: .default) { [weak self] _ in
            // Facebook button tapped.
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                self?.send_fb_post()
            } else {
                let alert = UIAlertController(title: "Info", message: "You can't send a Facebook post right now, make sure your device has an internet connection and you have at least one Facebook account setup.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
                    self?.presentedViewController?.dismiss(animated: false, completion: nil)
                })
                
                self?.present(alert, animated: true, completion: nil)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: button_2, style: .default) { [weak self] _ in
            // Twitter button tapped.
            
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                self?.send_tweet()
            } else {
                let alert = UIAlertController(title: "Info", message: "You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { _ in
                    self?.presentedViewController?.dismiss(animated: false, completion: nil)
                })
                
                self?.present(alert, animated: true, completion: nil)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: button_3, style: .default) { [weak self] _ in
            // Email button tapped.
            
            if MFMailComposeViewController.canSendMail(),
                let me = self {
                let composer = MFMailComposeViewController()
                composer.mailComposeDelegate = self
                composer.setToRecipients([""])
                composer.setSubject("")
                let link = String(format: APP_LINK_FORMAT, me.input_id ?? "")
                composer.setMessageBody(String(format: SHARE_MESS_EMAIL, me.input_name ?? "", me.input_dev_name ?? "", link), isHTML: false)
                
                me.present(composer, animated: true, completion: nil)
            }
        })
        
        actionSheet.addAction(UIAlertAction(title: button_4, style: .default) { [weak self] _ in
            // Copy Link button tapped.

            UIPasteboard.general.string = String(format: APP_LINK_FORMAT, self?.input_id ?? "")
        })
        
        // Present action sheet.
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func download() {
        guard let url = url_with_id.flatMap({ URL(string: $0) }) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    @IBAction func view_description() {
        let alert = UIAlertController(title: "App Info", message: input_description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            self?.presentedViewController?.dismiss(animated: false, completion: nil)
        })
        
        present(alert, animated: true, completion: nil)
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Info" message:input_description delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    //    [alert show];
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.clipsToBounds = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        if let defaultPrefsURL = Bundle.main.path(forResource: "defaultPrefs", ofType: "plist").flatMap({ URL(fileURLWithPath: $0, isDirectory: false) }) {
            if let data = try? Data(contentsOf: defaultPrefsURL) {
                var format = PropertyListSerialization.PropertyListFormat.xml
                if let defaultPreferences = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as? [String: AnyObject] {
                    UserDefaults.standard.register(defaults: defaultPreferences)
                }
            }
        }
        
        var contentOffset: CGFloat = 0
        for singleImageFilename in input_screenshot ?? [] {
            guard let imageURL = URL(string: singleImageFilename) else {
                continue
            }
            
            let imageViewFrame = CGRect(x: contentOffset, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            let imageView = AsyncImageView(frame: imageViewFrame)
            
            imageView.contentMode = .scaleAspectFit
            imageView.set(imageURL: imageURL)
            
            scrollView.addSubview(imageView)
            contentOffset += imageView.frame.width
        }
        
        scrollView.contentSize = CGSize(width: contentOffset, height: scrollView.frame.height)
        
        // Do any additional setup after loading the view.
        
        // Get rid of the UIStatus bar.
        setNeedsStatusBarAppearanceUpdate()
        
        // Add nice corner effect to
        // black activity indicator background.
        //background_active_black.layer.cornerRadius = 16
        
        // Setup the scroll view.
        scroll.isScrollEnabled = true
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            let result = UIScreen.main.bounds.size
            
            if result.height == 480 {
                // 3.5 inch display.
                scroll.contentSize = CGSize(width: 320, height: 497)
                star_1.frame = star_1.frame.offsetBy(dx: 0, dy: 10)
                star_2.frame = star_2.frame.offsetBy(dx: 0, dy: 10)
                star_3.frame = star_3.frame.offsetBy(dx: 0, dy: 10)
                star_4.frame = star_4.frame.offsetBy(dx: 0, dy: 10)
                star_5.frame = star_5.frame.offsetBy(dx: 0, dy: 10)
            }
            
            if result.height >= 568 {
                // 4 inch display (or bigger).
                scroll.contentSize = CGSize(width: 320, height: 985)
            }
        }
        
        // Apply nice curved border - app logo.
        app_logo.layer.cornerRadius = 16
        app_logo.layer.masksToBounds = true
        
        // Load the input data.
        refresh()
    }
    
    private func refresh() {
        //active_black.startAnimating()
        //background_active_black.alpha = 1
        
        // Set the labels first - name, age, etc...
        label_name.text = input_name
        label_dev_name.text = input_dev_name
        label_price.text = input_price
        label_size.text = input_size
        label_age.text = input_age
        label_version.text = input_version
        description_text.text = input_description
        
        // If the device is an iPad, show the description
        // text view label. On iPhone this is shown in a
        // alert view popup text view.
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            
        }
        
        // Set the app download url.
        url_with_id = String(format: APP_LINK_FORMAT, input_id ?? "")
        
        // Set the rating stars.
        let rating = input_rating.flatMap { Int($0) } ?? 0
        
        star_1.alpha = rating >= 1 ? 1 : 0
        star_2.alpha = rating >= 2 ? 1 : 0
        star_3.alpha = rating >= 3 ? 1 : 0
        star_4.alpha = rating >= 4 ? 1 : 0
        star_5.alpha = rating >= 5 ? 1 : 0
        
        // Download and set the app logo.
        app_logo.set(imagePath: input_logo_link)
    }
    
    //MARK: - Social sharing methods - FB/TW ///
    
    private func send_fb_post() {
        // Create an instance of the FB Sheet.
        guard let fbSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook) else {
            assertionFailure()
            return
        }
        
        // Sets the completion handler. Note that we don't know which thread the
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue.
        fbSheet.completionHandler = { result in
            switch result {
                    // This means the user cancelled without sending the FB.
            case .cancelled:
                    break
                    
                    // This means the user hit 'Send'.
            case .done:
                    break
                
            @unknown default:
                break
            }
        }
        
        // Set the initial body of the FB post.
        fbSheet.setInitialText(String(format: SHARE_MESS, input_name ?? "", input_dev_name ?? ""))
        // Add an URL to the FB post.
        fbSheet.add(URL(string: String(format: APP_LINK_FORMAT, input_id ?? "")))
        
        // Presents the FB Sheet to the user.
        present(fbSheet, animated: false, completion: nil)
    }
    
    private func send_tweet() {
        // Create an instance of the Tweet Sheet.
        guard let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else {
            assertionFailure()
            return
        }
        
        // Sets the completion handler. Note that we don't know which thread the
        // block will be called on, so we need to ensure that any UI updates occur
        // on the main queue.
        tweetSheet.completionHandler = { result in
            switch result {
                    // This means the user cancelled without sending the Tweet.
            case .cancelled:
                    break
                    
                    // This means the user hit 'Send'.
            case .done:
                    break
                
            @unknown default:
                break
            }
        }
        
        // Set the initial body of the Tweet.
        tweetSheet.setInitialText(String(format: SHARE_MESS, input_name ?? "", input_dev_name ?? ""))
        
        // Add an URL to the Tweet.
        tweetSheet.add(URL(string: String(format: APP_LINK_FORMAT, input_id ?? "")))
        
        // Presents the Tweet Sheet to the user.
        present(tweetSheet, animated: false, completion: nil)
    }
    
    //MARK: - Mail sending methods
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: false, completion: nil)
        
        if result == .failed {
            let alert = UIAlertController(title: "Message Error", message: "Mail was unable to send your E-Mail. Make sure you are connected to an EDGE/3G/4G or WiFi conection and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
                self?.presentedViewController?.dismiss(animated: false, completion: nil)
            })
            
            present(alert, animated: true, completion: nil)
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Error" message:@"Mail was unable to send your E-Mail. Make sure you are connected to an EDGE/3G/4G or WiFi conection and try again." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    //        [alert show];
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled, .failed, .sent:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}
