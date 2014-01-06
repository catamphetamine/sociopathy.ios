//
//  PushSegue.m
//  Sociopathy
//
//  Created by Admin on 06.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

// http://stackoverflow.com/questions/18966545/storyboard-custom-segue-tranition-for-dismissing-a-uiviewcontroller

#import "PushSegue.h"

@implementation PushSegue
- (void) perform
{
    UIViewController* fromController = (UIViewController*) self.sourceViewController;
    UIViewController* toController = (UIViewController*) self.destinationViewController;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    
    [fromController.view.window.layer addAnimation:transition forKey:nil];
    
    [fromController presentViewController:toController animated:NO completion:nil];
}
@end
