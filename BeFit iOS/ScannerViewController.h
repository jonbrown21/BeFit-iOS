//
//  ViewController.h
//  iOS7_BarcodeScanner
//
//  Created by Jake Widmer on 11/16/13.
//  Copyright (c) 2013 Jake Widmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Barcode.h"
#import "Food.h"
#import "FoodList.h"
#import "IQUIView+IQKeyboardToolbar.h"
#import "AppDelegate.h"

@interface ScannerViewController : UIViewController<UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    Barcode *scannedBarCode;
    NSArray* foodListArray;
    FoodList* selectedFoodList ;
}
@property (strong, nonatomic) NSMutableArray * allowedBarcodeTypes;
@property (weak, nonatomic) IBOutlet UITextField *txtHiddenField;
@property (nonatomic,strong) NSMutableDictionary* scannedObject ;
@property ( nonatomic) id delegate ;
@end

@protocol ScannedDataDelegate <NSObject>

-(void)SetScannedDataInFields ;

@end
