//
//  ViewController.m
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//


#import "ScannerViewController.h"
#import "BeFitTracker-Swift.h"

@import AVFoundation;   // iOS7 only import style

@interface ScannerViewController ()

@property (strong, nonatomic) NSMutableArray * foundBarcodes;
@property (weak, nonatomic) IBOutlet UIView *previewView;


@end

@implementation ScannerViewController{
    /* Here’s a quick rundown of the instance variables (via 'iOS 7 By Tutorials'):
     
     1. _captureSession – AVCaptureSession is the core media handling class in AVFoundation. It talks to the hardware to retrieve, process, and output video. A capture session wires together inputs and outputs, and controls the format and resolution of the output frames.
     
     2. _videoDevice – AVCaptureDevice encapsulates the physical camera on a device. Modern iPhones have both front and rear cameras, while other devices may only have a single camera.
     
     3. _videoInput – To add an AVCaptureDevice to a session, wrap it in an AVCaptureDeviceInput. A capture session can have multiple inputs and multiple outputs.
     
     4. _previewLayer – AVCaptureVideoPreviewLayer provides a mechanism for displaying the current frames flowing through a capture session; it allows you to display the camera output in your UI.
     5. _running – This holds the state of the session; either the session is running or it’s not.
     6. _metadataOutput - AVCaptureMetadataOutput provides a callback to the application when metadata is detected in a video frame. AV Foundation supports two types of metadata: machine readable codes and face detection.
     7. _backgroundQueue - Used for showing alert using a separate thread.
     */
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCaptureSession];
    _previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_previewLayer];
    self.foundBarcodes = [[NSMutableArray alloc] init];
    
    // listen for going into the background and stop the session
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    
    // set default allowed barcode types, remove types via setings menu if you don't want them to be able to be scanned
    self.allowedBarcodeTypes = [NSMutableArray new];
    [self.allowedBarcodeTypes addObject:@"org.iso.QRCode"];
    [self.allowedBarcodeTypes addObject:@"org.iso.PDF417"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.UPC-E"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Aztec"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code39Mod43"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-13"];
    [self.allowedBarcodeTypes addObject:@"org.gs1.EAN-8"];
    [self.allowedBarcodeTypes addObject:@"com.intermec.Code93"];
    [self.allowedBarcodeTypes addObject:@"org.iso.Code128"];
    
    foodListArray = [AppDelegate GetfoodListItems];
     selectedFoodList = foodListArray[0] ;
    
    UIPickerView* picker = [UIPickerView new];
    picker.delegate = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator = YES;
    _txtHiddenField.inputView = picker ;
    
    [_txtHiddenField addDoneOnKeyboardWithTarget:self action:@selector(doneAction)];
}





- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}
-(void)doneAction
{
    [AppDelegate ShowLoader];
    
    [_txtHiddenField resignFirstResponder];
    
    
    
    [self placeGetRequest:@"action" withHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // your code
        
        if (!error )
        {
            
            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"userData : %@", userData);
            if (!userData)
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Please try again later" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
               
                
//                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Something went wrong. Please try again later"
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"Okay"
//                                                        otherButtonTitles:nil];
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Code to update the UI/send notifications based on the results of the background processing
                    //[message show];
                     [self presentViewController:alertController animated:YES completion:nil];
                });
                

            }
            else if ([userData[@"status_code"] intValue] != 404 )
            {
               
                if ([[AppDelegate CheckForDuplicateFoodItem:userData[@"item_name"]] count] == 0)
                {
//                    [self AddFoodToLibrary:userData];
                     [self.scannedObject addEntriesFromDictionary:userData] ;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Code to update the UI/send notifications based on the results of the background processing
                        [self.delegate SetScannedDataInFields];
                       [self.navigationController popViewControllerAnimated:YES];
                        
                    });
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Code to update the UI/send notifications based on the results of the background processing
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food item already exists" preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:ok];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                        
                        
//                        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food item already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                        
                    });
                    
                }
                
                
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Code to update the UI/send notifications based on the results of the background processing
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:userData[@"error_message"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                   // [[[UIAlertView alloc] initWithTitle:@"Error" message:userData[@"error_message"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
                    
                });
                
            }
            
            
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Please try again later" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            
            
//            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                              message:@"Something went wrong. Please try again later"
//                                                             delegate:nil
//                                                    cancelButtonTitle:@"Okay"
//                                                    otherButtonTitles:nil];
          
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Code to update the UI/send notifications based on the results of the background processing
                 [self presentViewController:alertController animated:YES completion:nil];
                
                //[message show];
                
            });
        }
        
        
        NSLog(@"Error : %@",error.description);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Code to update the UI/send notifications based on the results of the background processing
            [AppDelegate HideLoader];
            [self startRunning];
        });
        
    }];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AV capture methods

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    // 2
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice)
    {
        NSLog(@"No video camera on this device!");
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity =
    AVLayerVideoGravityResizeAspectFill;
    
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}

- (void)startRunning {
    if (_running) return;
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes =
    _metadataOutput.availableMetadataObjectTypes;
    _running = YES;
}
- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}

#pragma mark - Button action functions
- (IBAction)settingsButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"toSettings" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  
}


#pragma mark - Delegate functions

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [metadataObjects
     enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
                                  NSUInteger idx,
                                  BOOL *stop)
     {
         if ([obj isKindOfClass:
              [AVMetadataMachineReadableCodeObject class]])
         {
             // 3
             AVMetadataMachineReadableCodeObject *code =
             (AVMetadataMachineReadableCodeObject*)
             [_previewLayer transformedMetadataObjectForMetadataObject:obj];
             // 4
             Barcode * barcode = [Barcode processMetadataObject:code];
             
             for(NSString * str in self.allowedBarcodeTypes){
                if([barcode.getBarcodeType isEqualToString:str]){
                    [self validBarcodeFound:barcode];
                    return;
                }
            }
         }
     }];
}

- (void) validBarcodeFound:(Barcode *)barcode{
    [self stopRunning];
    [self.foundBarcodes addObject:barcode];
    scannedBarCode = barcode ;
    [self showBarcodeAlert:barcode];
}
- (void) showBarcodeAlert:(Barcode *)barcode{
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Code to do in background processing
        NSString * alertMessage = @"A new product is found. Would you like to add this or continue with scanning?";
        
        
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"New Product"
                                      message:alertMessage
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Add"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self doneAction];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Continue"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self startRunning];
                                 }];
        [alert addAction:ok];
        [alert addAction:cancel];
        
        
        
        
        
        
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"New Product"
//                                                          message:alertMessage
//                                                         delegate:self
//                                                cancelButtonTitle:@"Add"
//                                                otherButtonTitles:@"Continue",nil];
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Code to update the UI/send notifications based on the results of the background processing
            //[message show];
            
            [self presentViewController:alert animated:YES completion:nil];

        });
    });
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
-(void)placeGetRequest:(NSString *)action withHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))ourBlock {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=%@&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93", scannedBarCode.getBarcodeData];
//    NSString *urlString = [NSString stringWithFormat:@"https://api.nutritionix.com/v1_1/item?upc=49000036756&appId=ac7e3b7b&appKey=46ed6b62ac0d3c08c949c6ef20a9cb93"];
//    NSString *urlString = [NSString stringWithFormat:@"https://www.barcodelookup.com/0028400337274"];
   
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:ourBlock] resume];
}


- (IBAction)AddFoodToLibrary:(NSDictionary*)foodData
{
    if ([foodData[@"nf_serving_size_qty"]intValue] == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"lease fill selected servings" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill selected servings." delegate:nil cancelButtonTitle:@"Okay"otherButtonTitles: nil]show];
        return ;
    }
    else if ([foodData[@"nf_serving_size_qty"]intValue] > 12)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Selected servings can not be more than 12" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
       // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Selected servings can not be more than 12" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        return;
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    Food* list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodObject" inManagedObjectContext:context];
    list.name = foodData[@"item_name"] ;
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
    list.foodListsBelongTo = [NSSet setWithObject: selectedFoodList] ;
    
    
    list.userDefined = [NSNumber numberWithBool:YES] ;
    NSError *error;
    
    if (![context save:&error])
    {
        NSLog(@"errror while saving : %@",error.description);
    }
    else
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Code to update the UI/send notifications based on the results of the background processing
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Food added Successfully" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            
           // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Food added Successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        });
    }
    
   
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return foodListArray.count ;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    FoodList* list = [foodListArray objectAtIndex:row];
    
    return list.name;
}
- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedFoodList = [foodListArray objectAtIndex:row];
    _txtHiddenField.text = selectedFoodList.name ;
    
}



- (void) settingsChanged:(NSMutableArray *)allowedTypes{
    for(NSObject * obj in allowedTypes){
        NSLog(@"%@",obj);
    }
    if(allowedTypes){
        self.allowedBarcodeTypes = [NSMutableArray arrayWithArray:allowedTypes];
    }
}



@end


