//
//  DeviceDetailViewControllerUIViewController.m
//  BeFit iOS
//
//  Created by Jon on 2/6/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "AppDelegate.h"

@interface DeviceDetailViewController ()

@end

@implementation DeviceDetailViewController
@synthesize device;


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    if ([self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter food list name" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter food list name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil] ;
//        [alert show];
        return ;
    }
    
    if ([[AppDelegate CheckForDuplicateFoodList:_nameTextField.text] count] > 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Food List already exists" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
       // [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Food List already exists" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil]show];
        return ;
    }
    
    NSInteger maxID = [self GetMaxTranslationMaxId] + 1 ;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.device) {
        // Update existing device
        [self.device setValue:self.nameTextField.text forKey:@"name"];
        [self.device setValue:[NSNumber numberWithInteger:maxID] forKey:@"orderIndex"];
        
    } else {
        // Create a new managed object
        FoodList* list = [NSEntityDescription insertNewObjectForEntityForName:@"FoodListObject" inManagedObjectContext:context];
        list.name =self.nameTextField.text;
        list.orderIndex = [NSNumber numberWithInteger:maxID] ;
        list.foods = [NSSet new];
//        [newDevice setValue:self.nameTextField.text forKey:@"name"];
//        [newDevice setValue:[NSNumber numberWithInteger:maxID] forKey:@"orderIndex"];
        
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationbar.delegate = self;
    
    if (self.device) {
        [self.nameTextField setText:[self.device valueForKey:@"name"]];
    }
    
    // Do any additional setup after loading the view.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(int)GetMaxTranslationMaxId
{
    id appDelegate =(id)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context =[appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc =[NSEntityDescription entityForName:@"FoodListObject" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"orderIndex" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    
    [request setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [[appDelegate managedObjectContext] executeFetchRequest:request error:&error];
    
    int maximumValue = 0;
    if (results.count == 1)
    {
        FoodList *result = (FoodList*)[results objectAtIndex:0];
        maximumValue =  [result.orderIndex intValue];
        NSLog(@"The max value is for request is :%d",maximumValue );
    }
    return  maximumValue;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
