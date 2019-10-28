//
//  CustomProgView.m
//  BeFit iOS
//
//  Created by Jon on 1/24/17.
//  Copyright © 2017 Jon Brown. All rights reserved.
//

#import "CustomProgView.h"

@implementation CustomProgView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize newSize = CGSizeMake(self.frame.size.width,9);
    return newSize;
}

@end
