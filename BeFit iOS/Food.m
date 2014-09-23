//
//  Food.m
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import "Food.h"
#import "FoodList.h"


@implementation Food

@dynamic sugars;
@dynamic sodium;
@dynamic saturatedFat;
@dynamic selectedServing;
@dynamic dietaryFiber;
@dynamic monosaturatedFat;
@dynamic vitaminA;
@dynamic calories;
@dynamic servingWeight2;
@dynamic vitaminE;
@dynamic servingDescription2;
@dynamic name;
@dynamic calcium;
@dynamic quantity;
@dynamic polyFat;
@dynamic servingWeight1;
@dynamic protein;
@dynamic cholesteral;
@dynamic servingDescription1;
@dynamic vitaminC;
@dynamic iron;
@dynamic userDefined;
@dynamic rating;
@dynamic carbs;
@dynamic foodListsBelongTo;

- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"name"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}

@end
