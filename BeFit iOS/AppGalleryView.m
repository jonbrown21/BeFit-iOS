//
//  AppGalleryView.m
//  AppGallery
//
//  Created by Daniel Sadjadian on 16/08/2014.
//  Copyright (c) 2014 Daniel Sadjadian. All rights reserved.
//

#import "AppGalleryView.h"

@interface AppGalleryView ()

@end

@implementation AppGalleryView
@synthesize data_pass;

/// Buttons ///

-(IBAction)refresh_button {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Please wait..."];
        
        [self performSelector:@selector(hideHud) withObject:self afterDelay:1.0 ];
    });
    [self refresh];
    [self refresh2];
}
- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
    [ProgressHUD dismiss];
    });
}
-(IBAction)done {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/// View Did Load ///

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    // Initilise the app logo image cache.
    self.cached_images = [[NSMutableDictionary alloc] init];
    app_table.delegate = self;
    app_table.dataSource = self;
    
    // Start loading the data.
    [self refresh];
    [self refresh2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [app_table reloadData];
    });
    
}

- (void)viewWillAppear:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        [app_table reloadData];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}
/// Data load/reload method ///

-(void)refresh {
    
    // Show the user the data is loading.
    //[active startAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD show:@"Please wait..."];
    });
    
    
    
    // Setup the JSON url and download the data on request.
    NSString *link = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=us&entity=software", DEV_NAME];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    
    //NSURLConnection *jon_apps =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:theRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // handle basic connectivity issues here
        
        if (error) {
            //NSLog(@"dataTaskWithRequest error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
            });
            
            
            NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"Data loading error"
                                        message:msg
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *noButton = [UIAlertAction
                                       actionWithTitle:@"Dismiss"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                                           [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                       }];
            
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        // handle HTTP errors here
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            
            if (statusCode != 200) {
                //NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ProgressHUD dismiss];
                });
                NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
                
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"Data loading error"
                                            message:msg
                                            preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *noButton = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                               [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                           }];
                
                [alert addAction:noButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
            }
        }
        
        // otherwise, everything is probably fine and you should interpret the `data` contents
        
        responseData = [[NSMutableData alloc] init];
        [responseData setLength:0];
        [responseData appendData:data];
        
        NSError *myError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
        
        // Store how many apps need to be loaded.
        result_count = [[res valueForKey:@"resultCount"] integerValue];
        
        // Store the app data - name, icon, etc...
        app_names = [[res objectForKey:@"results"] valueForKey:@"trackName"];
        dev_names = [[res objectForKey:@"results"] valueForKey:@"sellerName"];
        app_prices = [[res objectForKey:@"results"] valueForKey:@"formattedPrice"];
        app_icons = [[res objectForKey:@"results"] valueForKey:@"artworkUrl512"];
        app_ids = [[res objectForKey:@"results"] valueForKey:@"trackId"];
        app_versions = [[res objectForKey:@"results"] valueForKey:@"version"];
        app_descriptions = [[res objectForKey:@"results"] valueForKey:@"description"];
        app_age = [[res objectForKey:@"results"] valueForKey:@"contentAdvisoryRating"];
        app_ratings = [[res objectForKey:@"results"] valueForKey:@"averageUserRating"];
        app_size = [[res objectForKey:@"results"] valueForKey:@"fileSizeBytes"];
        app_screenshot_iphone = [[res objectForKey:@"results"] valueForKey:@"screenshotUrls"];
        app_screenshot_ipad = [[res objectForKey:@"results"] valueForKey:@"ipadScreenshotUrls"];
        
        // Data is now saved locally, so lets load
        // it into the UITableView to be presented
        // to the user and stop the activity indicator.
        [active stopAnimating];
        
        
        //NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [app_table reloadData];
            [ProgressHUD dismiss];
        });
    }];
    [dataTask resume];
    
    
    
    
    
    
    
    
}


-(void)refresh2 {
    
    // Show the user the data is loading.
    //[active startAnimating];
    
    
    // Setup the JSON url and download the data on request.
    NSString *link2 = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=us&entity=software", DEV_NAME2];
    NSURLRequest *theRequest2 = [NSURLRequest requestWithURL:[NSURL URLWithString:link2]];
    
    //NSURLConnection *arc_apps =[[NSURLConnection alloc] initWithRequest:theRequest2 delegate:self];
    
    NSURLSession *session2 = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask2 = [session2 dataTaskWithRequest:theRequest2 completionHandler:^(NSData *data2, NSURLResponse *response2, NSError *error) {
        
        // handle basic connectivity issues here
        
        if (error) {
            //NSLog(@"dataTaskWithRequest error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
            });
            
            
            NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:@"Data loading error"
                                        message:msg
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            
            UIAlertAction *noButton = [UIAlertAction
                                       actionWithTitle:@"Dismiss"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle no, thanks button
                                           [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                       }];
            
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        // handle HTTP errors here
        
        if ([response2 isKindOfClass:[NSHTTPURLResponse class]]) {
            
            NSInteger statusCode = [(NSHTTPURLResponse *)response2 statusCode];
            
            if (statusCode != 200) {
                //NSLog(@"dataTaskWithRequest HTTP status code: %ld", (long)statusCode);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ProgressHUD dismiss];
                });
                NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
                
                UIAlertController *alert = [UIAlertController
                                            alertControllerWithTitle:@"Data loading error"
                                            message:msg
                                            preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *noButton = [UIAlertAction
                                           actionWithTitle:@"Dismiss"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button
                                               [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                           }];
                
                [alert addAction:noButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
            }
        }
        
        // otherwise, everything is probably fine and you should interpret the `data` contents
        
        responseData2 = [[NSMutableData alloc] init];
        [responseData2 setLength:0];
        [responseData2 appendData:data2];
        
        NSError *myError = nil;
        NSDictionary *res2 = [NSJSONSerialization JSONObjectWithData:responseData2 options:NSJSONReadingMutableLeaves error:&myError];
        
        // Store how many apps need to be loaded.
        result_count2 = [[res2 valueForKey:@"resultCount"] integerValue];
        
        // Store the app data - name, icon, etc...
        app_names2 = [[res2 objectForKey:@"results"] valueForKey:@"trackName" ];
        dev_names2 = [[res2 objectForKey:@"results"] valueForKey:@"sellerName"];
        app_prices2 = [[res2 objectForKey:@"results"] valueForKey:@"formattedPrice"];
        app_icons2 = [[res2 objectForKey:@"results"] valueForKey:@"artworkUrl512"];
        app_ids2 = [[res2 objectForKey:@"results"] valueForKey:@"trackId"];
        app_versions2 = [[res2 objectForKey:@"results"] valueForKey:@"version"];
        app_descriptions2 = [[res2 objectForKey:@"results"] valueForKey:@"description"];
        app_age2 = [[res2 objectForKey:@"results"] valueForKey:@"contentAdvisoryRating"];
        app_ratings2 = [[res2 objectForKey:@"results"] valueForKey:@"averageUserRating"];
        app_size2 = [[res2 objectForKey:@"results"] valueForKey:@"fileSizeBytes"];
        app_screenshot_iphone2 = [[res2 objectForKey:@"results"] valueForKey:@"screenshotUrls"];
        app_screenshot_ipad2 = [[res2 objectForKey:@"results"] valueForKey:@"ipadScreenshotUrls"];
        
        // Data is now saved locally, so lets load
        // it into the UITableView to be presented
        // to the user and stop the activity indicator.
        [active stopAnimating];
        
        
        //NSLog(@"data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    }];
    [dataTask2 resume];
    
    
}


/// Data loading methods ///

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"Failed: %@", [error description]];
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Data loading error"
                                message:msg
                                preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:@"Dismiss"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle no, thanks button
                                   [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                               }];
    
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data loading error" message:msg delegate:self cancelButtonTitle:@"Dismiss"otherButtonTitles:nil];
//    [alert show];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == jon_apps) {
        [responseData setLength:0];
    } else if ( connection == arc_apps) {
        [responseData2 setLength:0];
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    if (connection == jon_apps) {
        [responseData appendData:data];
    } else if ( connection == arc_apps) {
        [responseData2 appendData:data];
    }
 
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    // Store how many apps need to be loaded.
    result_count = [[res valueForKey:@"resultCount"] integerValue];

    // Store the app data - name, icon, etc...
    app_names = [[res objectForKey:@"results"] valueForKey:@"trackName"];
    dev_names = [[res objectForKey:@"results"] valueForKey:@"sellerName"];
    app_prices = [[res objectForKey:@"results"] valueForKey:@"formattedPrice"];
    app_icons = [[res objectForKey:@"results"] valueForKey:@"artworkUrl512"];
    app_ids = [[res objectForKey:@"results"] valueForKey:@"trackId"];
    app_versions = [[res objectForKey:@"results"] valueForKey:@"version"];
    app_descriptions = [[res objectForKey:@"results"] valueForKey:@"description"];
    app_age = [[res objectForKey:@"results"] valueForKey:@"contentAdvisoryRating"];
    app_ratings = [[res objectForKey:@"results"] valueForKey:@"averageUserRating"];
    app_size = [[res objectForKey:@"results"] valueForKey:@"fileSizeBytes"];
    app_screenshot_iphone = [[res objectForKey:@"results"] valueForKey:@"screenshotUrls"];
    app_screenshot_ipad = [[res objectForKey:@"results"] valueForKey:@"ipadScreenshotUrls"];
    
    NSDictionary *res2 = [NSJSONSerialization JSONObjectWithData:responseData2 options:NSJSONReadingMutableLeaves error:&myError];
    
    // Store how many apps need to be loaded.
    result_count2 = [[res2 valueForKey:@"resultCount"] integerValue];
    
    // Store the app data - name, icon, etc...
    app_names2 = [[res2 objectForKey:@"results"] valueForKey:@"trackName"];
    dev_names2 = [[res2 objectForKey:@"results"] valueForKey:@"sellerName"];
    app_prices2 = [[res2 objectForKey:@"results"] valueForKey:@"formattedPrice"];
    app_icons2 = [[res2 objectForKey:@"results"] valueForKey:@"artworkUrl512"];
    app_ids2 = [[res2 objectForKey:@"results"] valueForKey:@"trackId"];
    app_versions2 = [[res2 objectForKey:@"results"] valueForKey:@"version"];
    app_descriptions2 = [[res2 objectForKey:@"results"] valueForKey:@"description"];
    app_age2 = [[res2 objectForKey:@"results"] valueForKey:@"contentAdvisoryRating"];
    app_ratings2 = [[res2 objectForKey:@"results"] valueForKey:@"averageUserRating"];
    app_size2 = [[res2 objectForKey:@"results"] valueForKey:@"fileSizeBytes"];
    app_screenshot_iphone2 = [[res2 objectForKey:@"results"] valueForKey:@"screenshotUrls"];
    app_screenshot_ipad2 = [[res2 objectForKey:@"results"] valueForKey:@"ipadScreenshotUrls"];
    
    
    // Data is now saved locally, so lets load
    // it into the UITableView to be presented
    // to the user and stop the activity indicator.
    [active stopAnimating];
    [app_table reloadData];
}

/// UITableView methods ///

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0)
    {
        // Check the rating, make sure it is
        // not null first and then pass it on.
        
        NSString *selectedValue = [app_names objectAtIndex:indexPath.row];
        
        NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
        NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
        
        NSString *cellValue;
        
        if ([selectedValue  isEqual: @"Animal Age Converter"]){
            cellValue = @"0";
        } else if ([selectedValue  isEqual: @"Seafood Guide"]) {
            cellValue = @"1";
        } else if ([selectedValue  isEqual: @"We're Gurus!"]) {
            cellValue = @"2";
        } else if ([selectedValue  isEqual: @"BeFit Tracker"]) {
            cellValue = @"3";
        }
        
        [[NSUserDefaults standardUserDefaults] setValue:cellValue forKey:@"cellIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"WHY %@", cellValue);
        
        NSInteger rating;
        
        if (![app_ratings[indexPath.row] isKindOfClass:[NSNull class]]) {
            rating = [app_ratings[indexPath.row] integerValue];
        }
        
        else {
            rating = 0;
        }
        
        // Open the detail view and pass the data
        // to be presented in detail to the user.
        
        // Edit the input size to MB.
        float size = [app_size[indexPath.row] integerValue];
        size = (size / 1000000);
        
        
        
        
        NSString *view_name = @"Main";
        UIStoryboard *newStoryboard = [UIStoryboard storyboardWithName:view_name bundle: nil];
        DetailView *firstvc = [newStoryboard instantiateViewControllerWithIdentifier:@"more_detailview"];
        self.data_pass = firstvc;
        
        
        // Set the data to be passed - names, links, etc...
        data_pass.input_name = [NSString stringWithFormat:@"%@", app_names[indexPath.row]];
        data_pass.input_dev_name = @"Jon Brown Designs";
        data_pass.input_price = [NSString stringWithFormat:@"%@", app_prices[indexPath.row]];
        data_pass.input_size = [NSString stringWithFormat:@"%.1fMB", size];
        data_pass.input_age = [NSString stringWithFormat:@"%@", app_age[indexPath.row]];
        data_pass.input_version = [NSString stringWithFormat:@"V%@", app_versions[indexPath.row]];
        data_pass.input_id = [NSString stringWithFormat:@"%@", app_ids[indexPath.row]];
        data_pass.input_rating = [NSString stringWithFormat:@"%ld", (long)rating];
        data_pass.input_logo_link = [NSString stringWithFormat:@"%@", app_icons[indexPath.row]];
        data_pass.input_choice = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        data_pass.input_description = [NSString stringWithFormat:@"%@", app_descriptions[indexPath.row]];
        
        // Pass the screenshot array. We will show the
        // correct image type depending on the device
        // and then what type of screenshots are available.
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            // If the device is an iPad, we will show iPad
            // size screenshots. However if the app is an iPhone
            // only app then we will have to show the iPhone
            // sized screenshots.
            
            if ([app_screenshot_ipad[indexPath.row] count] > 0) {
                data_pass.input_screenshot = app_screenshot_ipad;
            }
            
            else {
                data_pass.input_screenshot = app_screenshot_iphone;
            }
        }
        
        else {
            
            // If the device is an iPhone/iPod Touch, we will show
            // iPhone size screenshots. However if the app is an iPad
            // only app then we will have to show the iPad sized screenshots.
            
            if ([app_screenshot_iphone[indexPath.row] count] > 0) {
                data_pass.input_screenshot = app_screenshot_iphone;
            }
            
            else {
                data_pass.input_screenshot = app_screenshot_ipad;
            }
        }
        
        [self presentViewController:firstvc animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
    
    
    if (indexPath.section == 1)
    {
        
        // Check the rating, make sure it is
        // not null first and then pass it on.
        
        //NSString *selectedValue = [app_names2 objectAtIndex:indexPath.row];
        
        NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
        NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
        
        NSString *cellValue;
        
        cellValue = @"2";
        
        [[NSUserDefaults standardUserDefaults] setValue:cellValue forKey:@"cellIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"WHY %@", cellValue);
        
        NSInteger rating;
        
        if (![app_ratings2[indexPath.row] isKindOfClass:[NSNull class]]) {
            rating = [app_ratings2[indexPath.row] integerValue];
        }
        
        else {
            rating = 0;
        }
        
        // Open the detail view and pass the data
        // to be presented in detail to the user.
        
        // Edit the input size to MB.
        float size = [app_size2[indexPath.row] integerValue];
        size = (size / 1000000);
        
        
        
        
        NSString *view_name = @"Main";
        UIStoryboard *newStoryboard = [UIStoryboard storyboardWithName:view_name bundle: nil];
        DetailView *firstvc = [newStoryboard instantiateViewControllerWithIdentifier:@"more_detailview"];
        self.data_pass = firstvc;
        
        
        // Set the data to be passed - names, links, etc...
        data_pass.input_name = [NSString stringWithFormat:@"%@", app_names2[indexPath.row]];
        data_pass.input_dev_name = @"The Arc";
        data_pass.input_price = [NSString stringWithFormat:@"%@", app_prices2[indexPath.row]];
        data_pass.input_size = [NSString stringWithFormat:@"%.1fMB", size];
        data_pass.input_age = [NSString stringWithFormat:@"%@", app_age2[indexPath.row]];
        data_pass.input_version = [NSString stringWithFormat:@"V%@", app_versions2[indexPath.row]];
        data_pass.input_id = [NSString stringWithFormat:@"%@", app_ids2[indexPath.row]];
        data_pass.input_rating = [NSString stringWithFormat:@"%ld", (long)rating];
        data_pass.input_logo_link = [NSString stringWithFormat:@"%@", app_icons2[indexPath.row]];
        data_pass.input_choice = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        data_pass.input_description = [NSString stringWithFormat:@"%@", app_descriptions2[indexPath.row]];
        
        // Pass the screenshot array. We will show the
        // correct image type depending on the device
        // and then what type of screenshots are available.
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            // If the device is an iPad, we will show iPad
            // size screenshots. However if the app is an iPhone
            // only app then we will have to show the iPhone
            // sized screenshots.
            
            if ([app_screenshot_ipad2[indexPath.row] count] > 0) {
                data_pass.input_screenshot = app_screenshot_ipad2;
            }
            
            else {
                data_pass.input_screenshot = app_screenshot_iphone2;
            }
        }
        
        else {
            
            // If the device is an iPhone/iPod Touch, we will show
            // iPhone size screenshots. However if the app is an iPad
            // only app then we will have to show the iPad sized screenshots.
            
            if ([app_screenshot_iphone[indexPath.row] count] > 0) {
                data_pass.input_screenshot = app_screenshot_iphone2;
            }
            
            else {
                data_pass.input_screenshot = app_screenshot_ipad2;
            }
        }
        
        [self presentViewController:firstvc animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
        
        
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Delegate call back for cell at index path.
    NSString *CellIdentifier = [NSString stringWithFormat:@"%ld_%ld",(long)indexPath.section,(long)indexPath.row];
    CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.logo_image.image = nil;
    
    // Set the rating stars to the correct number
    // and then show the stars.
    NSInteger rating;
    
    cell.star_1.alpha = 1.0;
    cell.star_2.alpha = 1.0;
    cell.star_3.alpha = 1.0;
    cell.star_4.alpha = 1.0;
    cell.star_5.alpha = 1.0;
    
    // Set the app logo in the imageview. We will also be caching
    // the images in asynchronously so that there is no image
    // flickering issues and so the UITableView uns smoothly
    // while being scrolled.
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld", (long)indexPath.row];
    
    
    
    
    if(indexPath.section == 0) {
        // Set the labels - name, info, etc...
        cell.name_label.text = [NSString stringWithFormat:@"%@", app_names[indexPath.row]];
        cell.dev_label.text = @"Jon Brown Designs";
        
        
        if (![app_ratings[indexPath.row] isKindOfClass:[NSNull class]]) {
            
            rating = [app_ratings[indexPath.row] integerValue];
            
            for (int loop = 0; loop <= rating; loop++) {
                
                switch (loop) {
                        
                    case 1: cell.star_1.alpha = 1.0; break;
                    case 2: cell.star_2.alpha = 1.0; break;
                    case 3: cell.star_3.alpha = 1.0; break;
                    case 4: cell.star_4.alpha = 1.0; break;
                    case 5: cell.star_5.alpha = 1.0; break;
                        
                    default: break;
                }
            }
        }
        
        
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSURL *imageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@", app_icons[indexPath.row]]];
                NSData *data = [NSData dataWithContentsOfURL:imageUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImage *image = [UIImage imageWithData:data];
                    [cell.logo_image setImage:image];
                    
                    [self.cached_images setValue:image forKey:identifier];
                    cell.logo_image.image = [self.cached_images valueForKey:identifier];
                    
                    // Content has been loaded into the cell, so stop
                    // the activity indicator from spinning.
                    [cell.logo_active stopAnimating];
                });
            });
        

        
    }
    
    if(indexPath.section == 1) {
        
        if(indexPath.row == 0){
            [cell.name_label setHidden:YES];
            [cell.dev_label setHidden:YES];
            [cell.logo_image setHidden:YES];
            [cell.logo_active setHidden:YES];
            [cell.star_5 setHidden:YES];
            [cell.star_4 setHidden:YES];
            [cell.star_3 setHidden:YES];
            [cell.star_2 setHidden:YES];
            [cell.star_1 setHidden:YES];
            [cell.contentView setHidden:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(indexPath.row == 1){
            [cell.name_label setHidden:YES];
            [cell.dev_label setHidden:YES];
            [cell.logo_image setHidden:YES];
            [cell.logo_active setHidden:YES];
            [cell.star_5 setHidden:YES];
            [cell.star_4 setHidden:YES];
            [cell.star_3 setHidden:YES];
            [cell.star_2 setHidden:YES];
            [cell.star_1 setHidden:YES];
            [cell.contentView setHidden:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Set the labels - name, info, etc...
        
        cell.name_label.text = [NSString stringWithFormat:@"%@", app_names2[indexPath.row]];
        cell.dev_label.text = @"The Arc";
        
        if (![app_ratings2[indexPath.row] isKindOfClass:[NSNull class]]) {
            
            rating = [app_ratings2[indexPath.row] integerValue];
            
            for (int loop = 0; loop <= rating; loop++) {
                
                switch (loop) {
                        
                    case 1: cell.star_1.alpha = 1.0; break;
                    case 2: cell.star_2.alpha = 1.0; break;
                    case 3: cell.star_3.alpha = 1.0; break;
                    case 4: cell.star_4.alpha = 1.0; break;
                    case 5: cell.star_5.alpha = 1.0; break;
                        
                    default: break;
                }
            }
        }
        
        
        
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSURL *imageUrl =[NSURL URLWithString:[NSString stringWithFormat:@"%@", app_icons2[indexPath.row]]];
                NSData *data = [NSData dataWithContentsOfURL:imageUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImage *image = [UIImage imageWithData:data];
                    [cell.logo_image setImage:image];
                    
                    [self.cached_images setValue:image forKey:identifier];
                    cell.logo_image.image = [self.cached_images valueForKey:identifier];
                    
                    // Content has been loaded into the cell, so stop
                    // the activity indicator from spinning.
                    [cell.logo_active stopAnimating];
                });
            });
        

        
        
    }
    
    
    // Apply image boarder effects. It looks
    // much nicer with rounded corners. You can
    // also apply other effect too if you wish.
    [cell.logo_image.layer setCornerRadius:16.0];
    
    // Set the cell background colour.
    cell.backgroundColor = [UIColor whiteColor];
    
    // Set the content restraints. Keep things in place
    // otherwise the image/labels dont seem to appear in
    // the correct position on the cell.
    cell.logo_image.clipsToBounds = YES;
    cell.name_label.clipsToBounds = YES;
    cell.dev_label.clipsToBounds = YES;
    cell.star_1.clipsToBounds = YES;
    cell.star_2.clipsToBounds = YES;
    cell.star_3.clipsToBounds = YES;
    cell.star_4.clipsToBounds = YES;
    cell.star_5.clipsToBounds = YES;
    cell.logo_active.clipsToBounds = YES;
    cell.contentView.clipsToBounds = NO;
    
    return cell;
}

-(CGFloat)tableView :(UITableView *)tableView heightForRowAtIndexPath :(NSIndexPath *)indexPath {
    
    float heightForRow = 116;
    
    if(indexPath.section == 1) {
        
        if(indexPath.row == 0){
            return 0;
        }
        if(indexPath.row == 1){
            return 0;
        }
        
    }
      return heightForRow;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *) tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        return @"Our Apps";
    }
    if (section == 1)
    {
        return @"Contributed";
    }
    return @"Contributed";
}

-(NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section {
   
    if (section == 0)
    {
        return result_count;
    }
    if (section == 1)
    {
        return result_count2;
    }
    return result_count;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section==0){
        return 50.0f;
    }
    else if(section==1){
        return 50.0f;
    }
    else{
        return 50.0f;
    }
    
}

/// Other methods ///

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)  handleBack:(id)sender
{
    // pop to root view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
