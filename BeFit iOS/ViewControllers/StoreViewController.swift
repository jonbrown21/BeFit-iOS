//
//  StoreViewController.swift
//  BeFitTracker
//
//  Created by Andrej Slegl on 10/29/19.
//  Copyright © 2019 Jon Brown. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import CoreData

class StoreViewController: UITableViewController,
    SKPaymentTransactionObserver,
SKProductsRequestDelegate {
    //MARK: - Properties
    
    private let setButtonStateNotificationName = Notification.Name(rawValue: "SetButtonState")
    private var productsRequest: SKProductsRequest?
    private var validProducts: [Any] = []
    private var product: SKProduct?
    
    //private var selectedlabel: String?
    private var busyIndexes: IndexSet = IndexSet()
    private var CellTitles: [String] = []
    private var CellSubTitles: [String] = []
    //private var globalButton: AvePurchaseButton!
    
    private var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext
    }
    
    //MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem;
        NotificationCenter.default.addObserver(self, selector: #selector(setButtonStateManually), name: setButtonStateNotificationName, object: nil)
        CellTitles = ["54,000 Food Database", "Restore Purchase"]
        CellSubTitles = ["Larger Database of Food Items", ""]
        
        //    [self fetchAvailableProducts];
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SKPaymentQueue.default().remove(self)
        productsRequest?.delegate = nil
        productsRequest = nil
    }
    
    @objc private func setButtonStateManually(_ notification: Notification) {
        busyIndexes = IndexSet()
        tableView.reloadData()
    }
    
    func tapsRemoveAds() {
        print("User requests to remove ads")
        
        if SKPaymentQueue.canMakePayments() {
            print("User can make payments")
            
            //If you have more than one in-app purchase, and would like
            //to have the user purchase a different product, simply define
            //another function and replace kRemoveAdsProductIdentifier with
            //the identifier for the other product
            
            productsRequest = SKProductsRequest(productIdentifiers: Set(arrayLiteral: "com.befit.food.database"))
            productsRequest?.delegate = self
            productsRequest?.start()
        } else {
            print("User cannot make payments due to parental controls")
            //this is called the user cannot make payments, most likely due to parental controls
            NotificationCenter.default.post(name: setButtonStateNotificationName, object: self)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        NotificationCenter.default.post(name: setButtonStateNotificationName, object: self)
        print("request - didFailWithError:", error.localizedDescription)
        //NSLog(@"request - didFailWithError: %@", [[error userInfo] objectForKey:@"NSLocalizedDescription"]);
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alertController, animated: true)
        
        //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"NSLocalizedDescription"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        //    [alert show];
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let validProduct = response.products.first {
            print("Products Available!")
            purchase(validProduct)
        } else {
            print("No products available")
            let alertController = UIAlertController(title: "Error", message: "No products available", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(alertController, animated: true)
            
            //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No products available" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            //        [alert show];]
            NotificationCenter.default.post(name: setButtonStateNotificationName, object: self)
            //this is called if your product id is not valid, this shouldn't be called unless that happens.
        }
    }
    
    private func purchase(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    @IBAction func restore() {
        AppDelegate.showLoader()
        //this is called when the user restores purchases, you should hook this up to a button
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("received restored transactions:", queue.transactions.count)
        
        for transaction in queue.transactions {
            if transaction.transactionState == .restored {
                //called when the user successfully restores a purchase
                print("Transaction state -> Restored")
                
                //if you have more than one in-app purchase product,
                //you restore the correct product for the identifier.
                //For example, you could use
                //if(productID == kRemoveAdsProductIdentifier)
                //to get the product identifier for the
                //restored purchases, you can use
                //
                //NSString *productID = transaction.payment.productIdentifier;
                
                SKPaymentQueue.default().finishTransaction(transaction)
                break;
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            //if you have multiple in app purchases in your app,
            //you can get the product identifier of this transaction
            //by using transaction.payment.productIdentifier
            //
            //then, check the identifier against the product IDs
            //that you have defined to check which product the user
            //just purchased
            
            switch transaction.transactionState {
            case .purchasing:
                print("Transaction state -> Purchasing")
                //called when the user is in the process of purchasing, do not add any of your own code here.
                
            case .purchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                SKPaymentQueue.default().finishTransaction(transaction)
                print("Transaction state -> Purchased")
                updateDatabaseAfterPurchase()
                NotificationCenter.default.post(name: setButtonStateNotificationName, object: self)
                
            case .restored:
                print("Transaction state -> Restored")
                DispatchQueue.main.async {
                    AppDelegate.hideLoader()
                }
                
                updateDatabaseAfterPurchase()
                
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                //called when the transaction does not finish
                NotificationCenter.default.post(name: setButtonStateNotificationName, object: self)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    //-(void)fetchAvailableProducts{
    //    NSSet *productIdentifiers = [NSSet setWithObjects:@"food_0171",nil];
    //    productsRequest = [[SKProductsRequest alloc]
    //                       initWithProductIdentifiers:productIdentifiers];
    //    productsRequest.delegate = self;
    //    [productsRequest start];
    //}
    //
    //- (BOOL)canMakePurchases
    //{
    //    return [SKPaymentQueue canMakePayments];
    //}
    //- (void)purchaseMyProduct:(SKProduct*)product{
    //    if([SKPaymentQueue canMakePayments]){
    //        NSLog(@"User can make payments");
    //
    //        //If you have more than one in-app purchase, and would like
    //        //to have the user purchase a different product, simply define
    //        //another function and replace kRemoveAdsProductIdentifier with
    //        //the identifier for the other product
    //
    //        SKProductsRequest *products_Request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"food_0171"]];
    //        products_Request.delegate = self;
    //        [products_Request start];
    //
    //    }
    //    else{
    //        NSLog(@"User cannot make payments due to parental controls");
    //        //this is called the user cannot make payments, most likely due to parental controls
    //    }
    //}
    //
    //#pragma mark StoreKit Delegate
    //
    //
    //-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
    //{
    //    SKProduct *validProduct = nil;
    //    int count = [response.products count];
    //    if (count>0) {
    //        validProducts = response.products;
    //        validProduct = [response.products objectAtIndex:0];
    //        if ([validProduct.productIdentifier
    //             isEqualToString:@"food_0171"]) {
    //
    //        }
    //    } else {
    //        UIAlertView *tmp = [[UIAlertView alloc]
    //                            initWithTitle:@"Not Available"
    //                            message:@"No products to purchase"
    //                            delegate:self
    //                            cancelButtonTitle:nil
    //                            otherButtonTitles:@"Ok", nil];
    //        [tmp show];
    //
    //
    //
    //    }
    //
    //}
    
    @objc private func purchaseButtonTapped(_ button: AvePurchaseButton) {
        guard let indexPath = (button.superview as? UITableViewCell).flatMap({ tableView.indexPath(for: $0) }) else {
            assertionFailure()
            return
        }
        
        let index = indexPath.row
        
        // handle taps on the purchase button by
        switch button.buttonState {
        case .normal:
            // progress -> confirmation
            button.setButtonState(.confirmation, animated: true)
            
        case .confirmation:
            // confirmation -> "purchase" progress
            busyIndexes.insert(index)
            button.setButtonState(.progress, animated: true)
            tapsRemoveAds()
            
        case .progress:
            // progress -> back to normal
            busyIndexes.remove(index)
            button.setButtonState(.normal, animated: true)
            
        @unknown default:
            break
        }
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        // Configure the cell...
        if cell == nil {
            // create  a cell with some nice defaults
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
            cell.layoutMargins = .zero
            cell.separatorInset = .zero
            cell.detailTextLabel?.textColor = UIColor.gray
        }
        
        // add a buttons as an accessory and let it respond to touches
        let button = AvePurchaseButton(frame: .zero)
        button.addTarget(self, action: #selector(purchaseButtonTapped), for: .touchUpInside)
        cell.accessoryView = button
        //globalButton = button
        
        //Only add content to cell if it is new
        
        switch indexPath.row {
        case 0:
            // configure the cell
            cell.textLabel?.text = CellTitles[indexPath.row]
            cell.detailTextLabel?.text = CellSubTitles[indexPath.row]
            cell.selectionStyle = .none
            
            // configure the purchase button in state normal
            button.buttonState = .normal
            button.normalTitle = "$ 2.99"
            button.confirmationTitle = "BUY"
            button.sizeToFit()
            
            // if the item at this indexPath is being "busy" with purchasing, update the purchase
            // button's state to reflect so.
            if busyIndexes.contains(indexPath.row) {
                button.buttonState = .progress
            }
            
        case 1:
            // configure the cell
            cell.textLabel?.text = CellTitles[indexPath.row]
            cell.detailTextLabel?.text = CellSubTitles[indexPath.row]
            cell.selectionStyle = .none
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            restore()
        }
    }
    
    //- (void)purchase:(SKProduct *)product{
    //    SKPayment *payment = [SKPayment paymentWithProduct:product];
    //
    //    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //    [[SKPaymentQueue defaultQueue] addPayment:payment];
    //}
    //
    //- (IBAction) restore{
    //    //this is called when the user restores purchases, you should hook this up to a button
    //    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    //    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    //}
    //
    //- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
    //{
    //    NSLog(@"received restored transactions: %i", queue.transactions.count);
    //    for(SKPaymentTransaction *transaction in queue.transactions){
    //        if(transaction.transactionState == SKPaymentTransactionStateRestored){
    //            //called when the user successfully restores a purchase
    //            NSLog(@"Transaction state -> Restored");
    //
    //            //if you have more than one in-app purchase product,
    //            //you restore the correct product for the identifier.
    //            //For example, you could use
    //            //if(productID == kRemoveAdsProductIdentifier)
    //            //to get the product identifier for the
    //            //restored purchases, you can use
    //            //
    //            //NSString *productID = transaction.payment.productIdentifier;
    //
    //            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //            break;
    //        }
    //    }
    //}
    //
    //- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    //    for(SKPaymentTransaction *transaction in transactions){
    //        //if you have multiple in app purchases in your app,
    //        //you can get the product identifier of this transaction
    //        //by using transaction.payment.productIdentifier
    //        //
    //        //then, check the identifier against the product IDs
    //        //that you have defined to check which product the user
    //        //just purchased
    //
    //        switch(transaction.transactionState){
    //            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
    //                //called when the user is in the process of purchasing, do not add any of your own code here.
    //                break;
    //            case SKPaymentTransactionStatePurchased:
    //                //this is called when the user has successfully purchased the package (Cha-Ching!)
    //                 //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
    //                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //                NSLog(@"Transaction state -> Purchased");
    //                break;
    //            case SKPaymentTransactionStateRestored:
    //                NSLog(@"Transaction state -> Restored");
    //                //add the same code as you did from SKPaymentTransactionStatePurchased here
    //                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //                break;
    //            case SKPaymentTransactionStateFailed:
    //                //called when the transaction does not finish
    //                if(transaction.error.code == SKErrorPaymentCancelled){
    //                    NSLog(@"Transaction state -> Cancelled");
    //                    //the user cancelled the payment ;(
    //                }
    //                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //                break;
    //        }
    //    }
    //}
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true)
    }
    
    private func updateDatabaseAfterPurchase() {
        guard AppDelegate.check(forDuplicateFoodItem: "Baja Strawberry Kiwi").isEmpty else {
            return
        }
        
        DispatchQueue.main.async {
            AppDelegate.showLoaderForPurchase()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.callAfterSomeDelay()
        }
    }
    
    private func callAfterSomeDelay() {
        do {
            guard let context = managedObjectContext else {
                throw CustomError.noManagedObjectContext
            }
            
            guard let filePath = Bundle.main.path(forResource: "ZFOODOBJECT", ofType: "json") else {
                throw CustomError.fileNotFound
            }
            
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath, isDirectory: false))
            let object = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let distinctSet = NSSet(array: AppDelegate.check(forDuplicateFoodList: "Food Library"))
            
            guard let jsonArray = object as? [[String: Any]] else {
                throw CustomError.unknownType
            }
            
            for dict in jsonArray {
                let list = NSEntityDescription.insertNewObject(forEntityName: "FoodObject", into: context) as! Food
                
                func toNSNumber(_ key: String) -> NSNumber {
                    return (dict[key] as? NSNumber) ?? NSNumber(value: 0)
                }
                
                list.name = dict["ZNAME"] as? String
                list.sugars = toNSNumber("ZSUGARS") // Int
                list.sodium = toNSNumber("ZSODIUM") // Int
                list.saturatedFat = toNSNumber("ZSATURATEDFAT") // Double
                list.selectedServing = toNSNumber("ZSELECTEDSERVING") // Int
                list.dietaryFiber = toNSNumber("ZDIETARYFIBER") // Int
                list.monosaturatedFat = toNSNumber("ZMONOSATURATEDFAT") // Double
                list.vitaminA = toNSNumber("ZVITAMINA") // Double
                list.calories = toNSNumber("ZCALORIES") // Int
                list.servingWeight2 = toNSNumber("ZSERVINGWEIGHT2") // Int
                list.vitaminE = toNSNumber("ZVITAMINE") // Double
                list.servingDescription2 = dict["ZSERVINGDESCRIPTION2"] as? String
                list.calcium = toNSNumber("ZCALCIUM") // Double
                list.quantity = toNSNumber("ZQUANTITY") // Int
                list.polyFat = toNSNumber("ZPOLYFAT") // Double
                list.servingWeight1 = toNSNumber("ZSERVINGWEIGHT1") // Int
                list.protein = toNSNumber("ZPROTEIN") // Int
                list.cholesteral = toNSNumber("ZCHOLESTERAL") // Int
                list.servingDescription1 = dict["ZSERVINGDESCRIPTION1"] as? String
                list.vitaminC = toNSNumber("ZVITAMINC") // Double
                list.iron = toNSNumber("ZIRON") // Double
                list.carbs = toNSNumber("ZCARBS") // Int
                
                list.foodListsBelongTo = distinctSet
                list.userDefined = NSNumber(value: 0)
            }
            
            let alertController = UIAlertController(title: "Success", message: "Database updated successfully", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            present(alertController, animated: true)
            
            // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Database updated successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        } catch let error {
            print("errror while saving:", error.localizedDescription)
        }
        
        AppDelegate.hideLoader()
    }
    
    /*
    // Override to support conditional editing of the table view.
    - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
        // Return NO if you do not want the specified item to be editable.
        return YES;
    }
    */

    /*
    // Override to support editing the table view.
    - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
        // Return NO if you do not want the item to be re-orderable.
        return YES;
    }
    */
}
