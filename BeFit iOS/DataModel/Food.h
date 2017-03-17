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

-(BOOL)hideServing;


-(NSString *)calciumValue;
-(NSString *)calciumValuePerc;
-(NSString *)caloriesFromFatValue;
-(NSString *)carbsPercent;
-(NSString *)carbsValue;
-(NSString *)cholesterolPercent;
-(NSString *)cholesterolValue;
-(NSString *)dietaryFiberPercent;
-(NSString *)dietaryFiberValue;
-(NSString *)ironValue;
-(NSString *)ironValuePerc;
-(NSString *)monounsaturatedFatValue;
-(NSString *)monoFatValuePerc;
-(NSString *)nameValue;
-(NSString *)polyunsaturatedFatValue;
-(NSString *)proteinValue;
-(NSString *)proteinValuePerc;
-(NSString *)saturatedFatPercent;
-(NSString *)saturatedFatValue;
-(NSString *)servingAmount1Value;
-(NSString *)servingAmount2Value;
-(NSString *)servingAmountValue;
-(NSString *)sodiumPercent;
-(NSString *)sodiumValue;
-(NSString *)sugarsValue;
-(NSString *)sugarsValuePerc;
-(NSString *)totalFatPercent;
-(NSString *)totalFatValue;
-(NSString *)vitaminAValue;
-(NSString *)vitaminCValue;
-(NSString *)vitaminCValuePerc;
-(NSString *)totalValuePerc;
-(NSString *)vitaminAValuePerc;
-(NSString *)vitaminEValuePerc;


-(NSString *)transFatValue;
-(NSString *)viteValue;
-(NSString *)calfromFatValuePerc;
-(NSString *)caloriesStringValue;
-(NSString *)polyFatValuePerc;

-(void)addFoodListsBelongTo:(NSSet *)values;
-(void)addFoodListsBelongToObject:(FoodList *)value;
-(void)removeFoodListsBelongTo:(NSSet *)values;
-(void)removeFoodListsBelongToObject:(FoodList *)value;
-(void)setCalValue:(NSString *)calToUse;
-(void)setIndexOfServingBeingDisplayed: (int) indexToSet;
-(void)setNameValue:(NSString *)nameToUse;

-(double)selectedServingWeightAsDouble;
-(double)calciumValueAsDouble;
-(double)ironValueAsDouble;
-(double)monounsaturatedFatValueAsDouble;
-(double)polyunsaturatedFatValueAsDouble;
-(double)saturatedFatValueAsDouble;
-(double)totalFatValueAsDouble;
-(double)vitaminAValueAsDouble;
-(double)vitaminCValueAsDouble;
-(double)vitaminEValueAsDouble;

-(float)calfromFatValuePercFloat;
-(float)caloriesFloatValuePerc;
-(float)saturatedFatPercentFloat;
-(float)totalFatPercentfloat;
-(float)monoSaturatedFatPercentFloat;
-(float)cholPercentFloat;

-(int)servingWeight1Value;
-(int)indexOfServingBeingDisplayed;

-(long)calFromDiet;
-(long)caloriesLongValue;
-(long)carbsValueAsLong;
-(long)cholesterolValueAsLong;
-(long)dietaryFiberValueAsLong;
-(long)proteinValueAsLong;
-(long)quantityLongValue;
-(long)ratingLongValue;
-(long)sodiumValueAsLong;
-(long)sugarsValueAsLong;



@end
