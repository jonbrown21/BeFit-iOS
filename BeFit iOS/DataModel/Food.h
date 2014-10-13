//
//  Food.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FoodList;

@interface Food : NSManagedObject
{
    NSString *uppercaseFirstLetterOfName;
}
@property (nonatomic, retain) NSNumber * sugars;
@property (nonatomic, retain) NSNumber * sodium;
@property (nonatomic, retain) NSNumber * saturatedFat;
@property (nonatomic, retain) NSNumber * selectedServing;
@property (nonatomic, retain) NSNumber * dietaryFiber;
@property (nonatomic, retain) NSNumber * monosaturatedFat;
@property (nonatomic, retain) NSNumber * vitaminA;
@property (nonatomic, retain) NSNumber * calories;
@property (nonatomic, retain) NSNumber * servingWeight2;
@property (nonatomic, retain) NSNumber * vitaminE;
@property (nonatomic, retain) NSString * servingDescription2;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * calcium;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSNumber * polyFat;
@property (nonatomic, retain) NSNumber * servingWeight1;
@property (nonatomic, retain) NSNumber * protein;
@property (nonatomic, retain) NSNumber * cholesteral;
@property (nonatomic, retain) NSString * servingDescription1;
@property (nonatomic, retain) NSNumber * vitaminC;
@property (nonatomic, retain) NSNumber * iron;
@property (nonatomic, retain) NSNumber * userDefined;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * carbs;
@property (nonatomic, retain) NSSet *foodListsBelongTo;
@end

@interface Food (CoreDataGeneratedAccessors)

- (void)addFoodListsBelongToObject:(FoodList *)value;
- (void)removeFoodListsBelongToObject:(FoodList *)value;
- (void)addFoodListsBelongTo:(NSSet *)values;
- (void)removeFoodListsBelongTo:(NSSet *)values;

@end
