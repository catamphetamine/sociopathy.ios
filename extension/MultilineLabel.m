//
//  MultilineLabel.m
//  Sociopathy
//
//  Created by Admin on 11.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "MultilineLabel.h"

@implementation MultilineLabel

- (id)init
{
    if (self = [super init])
    {
        // required to prevent Auto Layout from compressing the label (by 1 point usually) for certain constraint solutions
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired
                                          forAxis:UILayoutConstraintAxisVertical];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
 
    if (self.numberOfLines == 0)
    {
        if (self.preferredMaxLayoutWidth != self.bounds.size.width)
        {
            self.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds);
        
            [super layoutSubviews];
        }
    }
}

@end
