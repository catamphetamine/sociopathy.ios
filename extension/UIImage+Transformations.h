//
//  UIImage+Transformations.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

//  Created by Hardy Macia on 7/1/09.

#import <Foundation/Foundation.h>

@interface UIImage (Transformations)
- (UIImage*) imageAtRect:(CGRect)rect;
- (UIImage*) imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage*) imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage*) imageByScalingToSize:(CGSize)targetSize;
- (UIImage*) imageRotatedByRadians:(CGFloat)radians;
- (UIImage*) imageRotatedByDegrees:(CGFloat)degrees;
@end
