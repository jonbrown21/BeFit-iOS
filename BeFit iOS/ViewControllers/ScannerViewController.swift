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
//import CoreData

protocol ScannedDataDelegate: class {
    func setScannedDataInFields(data: [String: Any])
}

class ScannerViewController: UIViewController,
    UIPickerViewDataSource,
    UIPickerViewDelegate,
AVCaptureMetadataOutputObjectsDelegate {
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
    @IBOutlet weak var txtHiddenField: UITextField!
    @IBOutlet weak var previewView: UIView!
    
    private var scannedBarCode: Barcode?
    private var foodListArray: [FoodList] = []
    private var selectedFoodList: FoodList?
    private var foundBarcodes: [Barcode] = []
    private var allowedBarcodeTypes: [String] = []
    
    private var captureSession: AVCaptureSession!
    private var videoDevice: AVCaptureDevice!
    private var videoInput: AVCaptureDeviceInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var running: Bool = false
    private var metadataOutput: AVCaptureMetadataOutput!
    
    //private var managedObjectContext: NSManagedObjectContext? {
    //    return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    //}
    
    weak var delegate: ScannedDataDelegate?
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        
        // listen for going into the background and stop the session
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        allowedBarcodeTypes = [
            "org.iso.QRCode",
            "org.iso.PDF417",
            "org.gs1.UPC-E",
            "org.iso.Aztec",
            "org.iso.Code39",
            "org.iso.Code39Mod43",
            "org.gs1.EAN-13",
            "org.gs1.EAN-8",
            "com.intermec.Code93",
            "org.iso.Code128"
        ]
        
        foodListArray = AppDelegate.getfoodListItems()
        selectedFoodList = foodListArray.first
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        txtHiddenField.inputView = picker
        txtHiddenField.addDoneOnKeyboard(withTarget: self, action: #selector(doneAction))
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
    
    @objc private func doneAction() {
        AppDelegate.showLoader()
        
        txtHiddenField.resignFirstResponder()
        
        placeGetRequest("action") { [weak self] (data, response, error) in
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
        guard captureSession == nil else {
            return
        }
        
        // 2
        videoDevice = AVCaptureDevice.default(for: .video)
        guard videoDevice != nil else {
            print("No video camera on this device!")
            return
        }
        
        // 3
        captureSession = AVCaptureSession()
        
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
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        
        // capture and process the metadata
        metadataOutput = AVCaptureMetadataOutput()
        let metadataQueue = DispatchQueue(label: "com.1337labz.featurebuild.metadata")
        //dispatch_queue_t metadataQueue =
        //dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
        metadataOutput.setMetadataObjectsDelegate(self, queue: metadataQueue)
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        }
    }
    
    private func startRunning() {
        guard !running else {
            return
        }
        
        captureSession.startRunning()
        
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        running = true
    }
    
    private func stopRunning() {
        guard running else {
            return
        }
        
        captureSession.stopRunning()
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
        for obj in metadataObjects {
            if obj is AVMetadataMachineReadableCodeObject {
                if let code = previewLayer.transformedMetadataObject(for: obj) as? AVMetadataMachineReadableCodeObject {
                    if let barcode = Barcode.processMetadataObject(code) {
                        if allowedBarcodeTypes.contains(barcode.getType()) {
                            validBarcodeFound(barcode)
                            return
                        }
                    }
                }
            }
        }
    }
    
    private func validBarcodeFound(_ barcode: Barcode) {
        stopRunning()
        foundBarcodes.append(barcode)
        scannedBarCode = barcode
        showBarcodeAlert(barcode)
    }
    
    private func showBarcodeAlert(_ barcode: Barcode) {
        let alertMessage = "A new product is found. Would you like to add this or continue with scanning?"
        
        let alert = UIAlertController(title: "New Product", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            self?.doneAction()
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
    
    //- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    //{
    //    if(buttonIndex == 0)
    //    {
    //        //Code for Done button
    //        // TODO: Create a finished view
    ////        [_txtHiddenField becomeFirstResponder];
    //        [self doneAction];
    //    }
    //    if(buttonIndex == 1)
    //    {
    //        //Code for Scan more button
    //        [self startRunning];
    //    }
    //}
    
    private func placeGetRequest(_ action: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let scannedBarCode = scannedBarCode else {
            completionHandler(nil, nil, CustomError.requiredObjectNil)
            return
        }
        
        let urlString = String(format: "https://api.nutritionix.com/v1_1/item?upc=%@&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93", scannedBarCode.getData())
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil, nil, CustomError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: completionHandler).resume()
        
        //    NSString *urlString = [NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=49000036756&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93"];
        //    NSString *urlString = [NSString stringWithFormat:@"https://www.barcodelookup.com/0028400337274"];
    }
    
    /*
     @IBAction func AddFoodToLibrary(_ foodData: NSDictionary) {
     guard let context = managedObjectContext else {
     assertionFailure()
     return
     }
     
     if (foodData["nf_serving_size_qty"] as? Int) ?? 0 == 0
     {
     let alertController = UIAlertController(title: "Error", message: "Please fill selected servings", preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
     
     present(alertController, animated: true)
     
     //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill selected servings." delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles: nil]show];
     return
     } else if (foodData["nf_serving_size_qty"] as? Int) ?? 0 > 12 {
     let alertController = UIAlertController(title: "Error", message: "Selected servings can not be more than 12", preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
     
     present(alertController, animated: true)
     
     // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Selected servings can not be more than 12" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
     return
     }
     
     let list = NSEntityDescription.insertNewObject(forEntityName: "FoodObject", into: context) as! Food
     list.name = foodData["item_name"] as? String
     
     list.sugars = ![foodData[@"nf_sugars"] isEqual: [NSNull null]]? [NSNumber numberWithInt:[foodData[@"nf_sugars"] intValue]]: [NSNumber numberWithInteger:0 ];
     list.sodium = ![foodData[@"nf_sodium"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_sodium"] intValue]]: [NSNumber numberWithInteger:0 ];
     list.saturatedFat = ![foodData[@"nf_saturated_fat"] isEqual: [NSNull null]]?[NSNumber numberWithDouble:[foodData[@"nf_saturated_fat"] doubleValue]]: [NSNumber numberWithInteger:0 ];
     list.selectedServing = ![foodData[@"nf_serving_size_qty"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_size_qty"] intValue]]:[NSNumber numberWithInteger:0 ];
     list.dietaryFiber = ![foodData[@"nf_dietary_fiber"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_dietary_fiber"] intValue]]: [NSNumber numberWithInteger:0 ];
     list.monosaturatedFat = ![foodData[@"nf_monounsaturated_fat"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_monounsaturated_fat"] doubleValue]]: [NSNumber numberWithInteger:0 ];
     list.vitaminA = ![foodData[@"nf_vitamin_a_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_a_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ];
     list.calories = ![foodData[@"nf_calories"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_calories"] intValue]]: [NSNumber numberWithInteger:0 ];
     list.servingWeight2 = ![foodData[@""] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@""] intValue]]: [NSNumber numberWithInteger:0 ];
     list.vitaminE = ![foodData[@"nf_vitamin_e_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_e_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ];
     list.servingDescription2 = @"" ;// foodData[@""];
     list.calcium = ![foodData[@"nf_calcium_dv"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_calcium_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ];
     list.quantity = [NSNumber numberWithInteger:0] ; // ![foodData[@"nf_serving_size_qty"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_size_qty"] intValue]]:[NSNumber numberWithInteger:0 ];
     list.polyFat = ![foodData[@"nf_polyunsaturated_fat"] isEqual: [NSNull null]]? [NSNumber numberWithDouble:[foodData[@"nf_polyunsaturated_fat"] doubleValue]]:[NSNumber numberWithInteger:0 ];
     list.servingWeight1 = ![foodData[@"nf_serving_weight_grams"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_serving_weight_grams"] intValue]]:[NSNumber numberWithInteger:0 ];
     list.protein = ![foodData[@"nf_protein"] isEqual: [NSNull null]] ? [NSNumber numberWithInt:[foodData[@"nf_protein"] intValue]]:[NSNumber numberWithInteger:0 ];
     list.cholesteral = ![foodData[@"nf_cholesterol"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_cholesterol"] intValue]]:[NSNumber numberWithInteger:0 ];
     list.servingDescription1 = ![foodData[@"item_description"] isEqual: [NSNull null]]?foodData[@"item_description"]:@"";
     list.vitaminC = ![foodData[@"nf_vitamin_c_dv"] isEqual: [NSNull null]] ? [NSNumber numberWithDouble:[foodData[@"nf_vitamin_c_dv"] doubleValue]]:[NSNumber numberWithInteger:0 ];
     list.iron = ![foodData[@"nf_iron_dv"] isEqual: [NSNull null]]?[NSNumber numberWithDouble:[foodData[@"nf_iron_dv"] doubleValue]]: [NSNumber numberWithInteger:0 ];
     list.carbs = ![foodData[@"nf_total_carbohydrate"] isEqual: [NSNull null]]?[NSNumber numberWithInt:[foodData[@"nf_total_carbohydrate"] intValue]]:[NSNumber numberWithInteger:0 ];
     
     list.foodListsBelongTo = NSSet(array: [selectedFoodList].compactMap { $0 })
     list.userDefined = NSNumber(value: 1)
     
     do {
     try context.save()
     } catch let error {
     print("error while saving : %@", error.localizedDescription)
     return
     }
     
     DispatchQueue.main.async {
     // Code to update the UI/send notifications based on the results of the background processing
     let alertController = UIAlertController(title: "Success", message: "Food added Successfully", preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
     
     self.present(alertController, animated: true)
     
     // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food added Successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
     }
     }*/
    
    //MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return foodListArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let list = foodListArray[row]
        return list.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFoodList = foodListArray[row]
        txtHiddenField.text = selectedFoodList?.name
    }
    
    func settingsChanged(_ allowedTypes: NSMutableArray) {
        for obj in allowedTypes {
            print(obj)
        }
        
        allowedBarcodeTypes = (allowedTypes as? [String]) ?? []
    }
}
