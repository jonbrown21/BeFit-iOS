//
//  StoreViewController.m
//  BeFit iOS
//
//  Created by Satinder Singh on 2/17/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "StoreViewController.h"
#import "BeFitTracker-Swift.h"

@interface StoreViewController ()
{
    NSString *selectedlabel;
    NSMutableIndexSet* _busyIndexes;
    NSArray *CellTitles;
    NSArray *CellSubTitles;
    AvePurchaseButton* globalButton ;
}
@end
@implementation StoreViewController
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
    
     _busyIndexes = [NSMutableIndexSet new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetButtonStateManually:) name:@"SetButtonState" object:nil];
    
    CellTitles = [NSArray arrayWithObjects:@"54,000 Food Database", @"Restore Purchase", nil];
    CellSubTitles = [NSArray arrayWithObjects:@"Larger Database of Food Items", @"", nil];
    
//    [self fetchAvailableProducts];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    productsRequest.delegate = nil ;
    productsRequest = nil ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)SetButtonStateManually:(NSNotification *) notification
{
     _busyIndexes = [NSMutableIndexSet new];
    [self.tableView reloadData];
}
- (void)tapsRemoveAds{
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.befit.food.database"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SetButtonState" object:self userInfo:nil];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetButtonState" object:self userInfo:nil];
     NSLog(@"request - didFailWithError: %@", error.description);
    
    NSLog(@"request - didFailWithError: %@", [[error userInfo] objectForKey:@"NSLocalizedDescription"]);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[[error userInfo] objectForKey:@"NSLocalizedDescription"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[error userInfo] objectForKey:@"NSLocalizedDescription"] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//    [alert show];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    long count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"No products available" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No products available" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
//        [alert show];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SetButtonState" object:self userInfo:nil];
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
   
}

- (IBAction) restore{
    
    [AppDelegate ShowLoader ];
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
           
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{

    
    for(SKPaymentTransaction *transaction in transactions){
        //if you have multiple in app purchases in your app,
        //you can get the product identifier of this transaction
        //by using transaction.payment.productIdentifier
        //
        //then, check the identifier against the product IDs
        //that you have defined to check which product the user
        //just purchased
        
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                
                [self UpdateDatabaseAfterPurchase];
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SetButtonState" object:self userInfo:nil];
                
                
                break;
            case SKPaymentTransactionStateRestored:
                
            {
                NSLog(@"Transaction state -> Restored");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Code to update the UI/send notifications based on the results of the background processing
                    [AppDelegate HideLoader] ;
                    
                });
                
                [self UpdateDatabaseAfterPurchase];
                
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"SetButtonState" object:self userInfo:nil];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
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
-(void)purchaseButtonTapped:(AvePurchaseButton*)button
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)button.superview];
    NSInteger index = indexPath.row;
    
    // handle taps on the purchase button by
    switch(button.buttonState)
    {
        case AvePurchaseButtonStateNormal:
            // progress -> confirmation
            
            [button setButtonState:AvePurchaseButtonStateConfirmation animated:YES];
            break;
            
        case AvePurchaseButtonStateConfirmation:
            // confirmation -> "purchase" progress
            [_busyIndexes addIndex:index];
            [button setButtonState:AvePurchaseButtonStateProgress animated:YES];
            [self tapsRemoveAds];
            break;
            
        case AvePurchaseButtonStateProgress:
            // progress -> back to normal
            [_busyIndexes removeIndex:index];
            [button setButtonState:AvePurchaseButtonStateNormal animated:YES];
            break;
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
   

    
    if (cell == nil)
    {
        
        // create  a cell with some nice defaults
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
    }
    // add a buttons as an accessory and let it respond to touches
    AvePurchaseButton* button = [[AvePurchaseButton alloc] initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(purchaseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    globalButton = button ;
    //Only add content to cell if it is new
    if(indexPath.row == 0)
    {
        
        // configure the cell
        cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // configure the purchase button in state normal
        AvePurchaseButton* button = (AvePurchaseButton*)cell.accessoryView;
        button.buttonState = AvePurchaseButtonStateNormal;
        button.normalTitle = @"$ 2.99";
        button.confirmationTitle = @"BUY";
        [button sizeToFit];
        
        // if the item at this indexPath is being "busy" with purchasing, update the purchase
        // button's state to reflect so.
        if([_busyIndexes containsIndex:indexPath.row] == YES)
        {
            button.buttonState = AvePurchaseButtonStateProgress;
        }
        
    }
    
    //Only add content to cell if it is new
    if(indexPath.row == 1)
    {
        
        // configure the cell
        cell.textLabel.text = [CellTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [CellSubTitles objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 1)
    {
        [self restore];
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
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)UpdateDatabaseAfterPurchase
{
    
    if ([[AppDelegate CheckForDuplicateFoodItem:@"Baja Strawberry Kiwi"]count] > 0)
    {
        return ;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // Code to update the UI/send notifications based on the results of the background processing
        [AppDelegate ShowLoaderForPurchase] ;   
        
    });
    
    
    [self performSelector:@selector(CallAfterSomeDelay) withObject:nil afterDelay:0.7];
    
}
-(void)CallAfterSomeDelay
{
    NSSet *distinctSet = [NSSet setWithArray:[AppDelegate CheckForDuplicateFoodList:@"Food Library"]];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"ZFOODOBJECT" ofType:@"json"];
    NSError *error;
    
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    for (int iCount = 0; iCount < jsonArray.count; iCount++)
    {
        NSDictionary*dict = [jsonArray objectAtIndex:iCount];
        Food* list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodObject" inManagedObjectContext:context];
        
        list.name = dict[@"ZNAME"] ;
        list.sugars = [NSNumber numberWithInt:[dict[@"ZSUGARS"] intValue]];
        list.sodium = [NSNumber numberWithInt:[dict[@"ZSODIUM"] intValue]];
        list.saturatedFat = [NSNumber numberWithDouble:[dict[@"ZSATURATEDFAT"] doubleValue]];
        list.selectedServing = [NSNumber numberWithInt:[dict[@"ZSELECTEDSERVING"] intValue]];
        list.dietaryFiber = [NSNumber numberWithInt:[dict[@"ZDIETARYFIBER"] intValue]];
        list.monosaturatedFat = [NSNumber numberWithDouble:[dict[@"ZMONOSATURATEDFAT"] doubleValue]];
        list.vitaminA = [NSNumber numberWithDouble:[dict[@"ZVITAMINA"] doubleValue]];
        list.calories = [NSNumber numberWithInt:[dict[@"ZCALORIES"] intValue]];
        list.servingWeight2 = [NSNumber numberWithInt:[dict[@"ZSERVINGWEIGHT2"] intValue]];
        list.vitaminE = [NSNumber numberWithDouble:[dict[@"ZVITAMINE"] doubleValue]];
        list.servingDescription2 = dict[@"ZSERVINGDESCRIPTION2"];
        list.calcium = [NSNumber numberWithDouble:[dict[@"ZCALCIUM"] doubleValue]];
        list.quantity = [NSNumber numberWithInt:[dict[@"ZQUANTITY"] intValue]];
        list.polyFat = [NSNumber numberWithDouble:[dict[@"ZPOLYFAT"] doubleValue]];
        list.servingWeight1 = [NSNumber numberWithInt:[dict[@"ZSERVINGWEIGHT1"] intValue]];
        list.protein = [NSNumber numberWithInt:[dict[@"ZPROTEIN"] intValue]];
        list.cholesteral = [NSNumber numberWithInt:[dict[@"ZCHOLESTERAL"] intValue]];
        list.servingDescription1 = dict[@"ZSERVINGDESCRIPTION1"];
        list.vitaminC = [NSNumber numberWithDouble:[dict[@"ZVITAMINC"] doubleValue]];
        list.iron = [NSNumber numberWithDouble:[dict[@"ZIRON"] doubleValue]];
        list.carbs = [NSNumber numberWithInt:[dict[@"ZCARBS"] intValue]];
        
        list.foodListsBelongTo = distinctSet ;
        
        
        list.userDefined = [NSNumber numberWithBool:FALSE] ;
        
    }
    
    
    if (![context save:&error])
    {
        NSLog(@"errror while saving : %@",error.description);
    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Database updated successfully" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
       // [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Database updated successfully" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
    }
    [AppDelegate HideLoader];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
