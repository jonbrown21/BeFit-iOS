//
//  UserFoodRecords+CoreDataProperties.m
//  BeFit iOS
//
//  Created by Satinder Singh on 2/27/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "UserFoodRecords+CoreDataProperties.h"

@implementation UserFoodRecords (CoreDataProperties)

+ (NSFetchRequest<UserFoodRecords *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"UserFoodRecords"];
}

@dynamic date;
@dynamic servings;
@dynamic foodIntake;

@end
