//
//  ScannerViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/25/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import IQKeyboardManager
import CoreHaptics

protocol ScannedDataDelegate: AnyObject {
    func setScannedDataInFields(data: [String: Any])
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    /* Here’s a quick rundown of the instance variables (via 'iOS 7 By Tutorials'):
     
     1. _captureSession – AVCaptureSession is the core media handling class in AVFoundation. It talks to the hardware to retrieve, process, and output video. A capture session wires together inputs and outputs, and controls the format and resolution of the output frames.
     
     2. _videoDevice – AVCaptureDevice encapsulates the physical camera on a device. Modern iPhones have both front and rear cameras, while other devices may only have a single camera.
     
     3. _videoInput – To add an AVCaptureDevice to a session, wrap it in an AVCaptureDeviceInput. A capture session can have multiple inputs and multiple outputs.
     
     4. _previewLayer – AVCaptureVideoPreviewLayer provides a mechanism for displaying the current frames flowing through a capture session; it allows you to display the camera output in your UI.
     5. _running – This holds the state of the session; either the session is running or it’s not.
     6. _metadataOutput - AVCaptureMetadataOutput provides a callback to the application when metadata is detected in a video frame. AV Foundation supports two types of metadata: machine readable codes and face detection.
     7. _backgroundQueue - Used for showing alert using a separate thread.
     */
    
    //MARK: Properties
    
    static let supportedMetadataTypes: [AVMetadataObject.ObjectType] = [
        .qr,
        .pdf417,
        .upce,
        .aztec,
        .code39,
        .code39Mod43,
        .ean13,
        .ean8,
        .code93,
        .code128
    ]
    
    @IBOutlet weak var previewView: UIView!
    
    private var captureSession: AVCaptureSession?
    private var videoDevice: AVCaptureDevice?
    private var videoInput: AVCaptureDeviceInput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var running: Bool = false
    private var metadataOutput: AVCaptureMetadataOutput?
    
    weak var delegate: ScannedDataDelegate?
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        
        // listen for going into the background and stop the session
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRunning()
    }
    
    //MARK: - Private
    
    private func doneAction(code: String) {
        AppDelegate.showLoader()
        
        placeGetRequest(code: code) { [weak self] (data, response, error) in
            if error == nil {
                do {
                    let object = try JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
                    
                    guard let userData = object as? [String: Any] else {
                        throw CustomError.unknownType
                    }
                    
                    print("userData:", userData)
                    
                    if (userData["status_code"] as? Int) != 404 {
                        if AppDelegate.check(forDuplicateFoodItem: (userData["item_name"] as? String) ?? "").isEmpty {
                            //[self AddFoodToLibrary:userData];
                            DispatchQueue.main.async {
                                self?.delegate?.setScannedDataInFields(data: userData)
                                self?.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            DispatchQueue.main.async {
                                // Code to update the UI/send notifications based on the results of the background processing
                                
                                let alertController = UIAlertController(title: "Success", message: "Food item already exists", preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                
                                self?.present(alertController, animated: true)
                                
                                //[[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            // Code to update the UI/send notifications based on the results of the background processing
                            let alertController = UIAlertController(title: "Error", message: (userData["error_message"] as? String) ?? "Something went wrong. Please try again later", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                            
                            self?.present(alertController, animated: true)
                            
                            // [[[UIAlertView alloc] initWithTitle:@"Error" message:userData[@"error_message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                        }
                    }
                } catch {
                    let alertController = UIAlertController(title: "Error", message: "Something went wrong. Please try again later", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                    DispatchQueue.main.async {
                        self?.present(alertController, animated: true)
                    }
                }
            } else {
                print("Error:", error?.localizedDescription ?? "")
                
                let alertController = UIAlertController(title: "Error", message: "Something went wrong. Please try again later", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                //            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
                //                                                              message:@"Something went wrong. Please try again later"
                //                                                             delegate:nil
                //                                                    cancelButtonTitle:@"Okay"
                //                                                    otherButtonTitles:nil];
                DispatchQueue.main.async {
                    self?.present(alertController, animated: true)
                }
            }
            
            DispatchQueue.main.async {
                AppDelegate.hideLoader()
                self?.startRunning()
            }
        }
    }
    
    //MARK: - AV capture methods
    
    private func setupCaptureSession() {
        // 1
        guard self.captureSession == nil else {
            return
        }
        
        // 2
        let videoDevice: AVCaptureDevice! = AVCaptureDevice.default(for: .video)
        guard videoDevice != nil else {
            print("No video camera on this device!")
            return
        }
        
        // 3
        let captureSession = AVCaptureSession()
        let videoInput: AVCaptureDeviceInput
        
        // 4
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error {
            print("Cannot start capturing video:", error.localizedDescription)
            return
        }
        
        // 5
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // 6
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        // capture and process the metadata
        let metadataOutput = AVCaptureMetadataOutput()
        let metadataQueue = DispatchQueue(label: "com.1337labz.featurebuild.metadata")
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        }
        
        metadataOutput.metadataObjectTypes = ScannerViewController.supportedMetadataTypes.filter {
            metadataOutput.availableMetadataObjectTypes.contains($0)
        }
        
        self.captureSession = captureSession
        self.videoDevice = videoDevice
        self.videoInput = videoInput
        self.previewLayer = previewLayer
        self.metadataOutput = metadataOutput
        
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
    }
    
    private func startRunning() {
        guard !running else {
            return
        }
        
        if captureSession == nil {
            setupCaptureSession()
        }
        
        captureSession?.startRunning()
        
        if let metadataOutput = metadataOutput {
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        }
        
        running = captureSession != nil
    }
    
    private func stopRunning() {
        guard running else {
            return
        }
        
        captureSession?.stopRunning()
        running = false
    }
    
    @objc private func applicationWillEnterForeground() {
        startRunning()
    }
    
    @objc private func applicationDidEnterBackground() {
        stopRunning()
    }
    
    //MARK: - Button action functions
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    //MARK: - Delegate functions
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                continue
            }
            
            guard let stringValue = readableObject.stringValue else {
                continue
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            validBarcodeFound(stringValue)
            break
        }
    }
    
    private func validBarcodeFound(_ code: String) {
        stopRunning()
        showBarcodeAlert(code: code)
    }
    
    private func showBarcodeAlert(code: String) {
        let alertMessage = "A new product is found. Would you like to add this or continue with scanning?"
        
        let alert = UIAlertController(title: "New Product", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.doneAction(code: code)
        })
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.startRunning()
        })
        
        //        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"New Product"
        //                                                          message:alertMessage
        //                                                         delegate:self
        //                                                cancelButtonTitle:@"Add"
        //                                                otherButtonTitles:@"Continue",nil];
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func placeGetRequest(code: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString = String(format: "https://api.nutritionix.com/v1_1/item?upc=%@&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93", code)
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil, nil, CustomError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
        
        //    NSString *urlString = [NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=49000036756&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93"];
        //    NSString *urlString = [NSString stringWithFormat:@"https://www.barcodelookup.com/0028400337274"];
    }
}
