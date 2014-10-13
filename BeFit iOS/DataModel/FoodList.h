//
//  FoodList.h
//  BeFit iOS
//
//  Created by Jon Brown on 9/21/14.
//  Copyright (c) 2014 Jon Brown. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Food;

@interface FoodList : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * orderIndex;
@property (nonatomic, retain) NSSet *foods;
@end

@interface FoodList (CoreDataGeneratedAccessors)

- (void)addFoodsObject:(Food *)value;
- (void)removeFoodsObject:(Food *)value;
- (void)addFoods:(NSSet *)values;
- (void)removeFoods:(NSSet *)values;

@end
