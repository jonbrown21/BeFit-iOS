//
//  UserFoodRecords+CoreDataProperties.h
//  BeFit iOS
//
//  Created by Satinder Singh on 2/27/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "UserFoodRecords+CoreDataClass.h"
#import "Food.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserFoodRecords (CoreDataProperties)

+ (NSFetchRequest<UserFoodRecords *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *date;
@property (nullable, nonatomic, copy) NSNumber *servings;
@property (nullable, nonatomic, retain) NSSet<Food *> *foodIntake;

@end

@interface UserFoodRecords (CoreDataGeneratedAccessors)

- (void)addFoodIntakeObject:(Food *)value;
- (void)removeFoodIntakeObject:(Food *)value;
- (void)addFoodIntake:(NSSet<Food *> *)values;
- (void)removeFoodIntake:(NSSet<Food *> *)values;

@end

NS_ASSUME_NONNULL_END
