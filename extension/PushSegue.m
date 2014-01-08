//
//  PushSegue.m
//  Sociopathy
//
//  Created by Admin on 06.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

// http://stackoverflow.com/questions/18966545/storyboard-custom-segue-tranition-for-dismissing-a-uiviewcontroller

// http://stackoverflow.com/questions/17375441/push-segue-animation-without-uinavigationcontroller/20965349

#import "PushSegue.h"

@implementation PushSegue
- (void) perform
{
    UIViewController* source = (UIViewController*) self.sourceViewController;
    UIViewController* destination = (UIViewController*) self.destinationViewController;
    
    const BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    float animationDuration = iPad ? 0.5 : 0.3;
    
    // Swap the snapshot out for the source view controller
    UIWindow* window = source.view.window;
    UIImageView* screenShot = screenShotOfView(source.view);
    
    // accord to device orientation
    
    float rotation;
    
    CGRect originalFrame = destination.view.frame;
    CGRect destinationFrame = destination.view.frame;
    
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotation = M_PI;
            destinationFrame.origin.x -= source.view.bounds.size.width;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            rotation = M_PI + M_PI_2;
            destinationFrame.origin.y -= source.view.bounds.size.width;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            rotation = M_PI_2;
            destinationFrame.origin.y += source.view.bounds.size.width;
            break;
            
        default:
            rotation = 0;
            destinationFrame.origin.x += source.view.bounds.size.width;
            break;
    }
    
    screenShot.transform = CGAffineTransformMakeRotation(rotation);
    
    // reposition after rotation
    CGRect screenshotFrame = screenShot.frame;
    screenshotFrame.origin.x = 0;
    screenshotFrame.origin.y = 0;
    screenShot.frame = screenshotFrame;
    
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            screenshotFrame.origin.x += screenShot.bounds.size.width;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
            screenshotFrame.origin.y += screenShot.bounds.size.width;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            screenshotFrame.origin.y -= screenShot.bounds.size.width;
            break;
            
        default:
            screenshotFrame.origin.x -= screenShot.bounds.size.width;
            break;
    }
    
    // swap the view with its screenshot
    window.rootViewController = destination;
    [window addSubview:screenShot];
    [source.view removeFromSuperview];
    
    const BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    {
        destination.view.frame = destinationFrame;
    }
    [UIView setAnimationsEnabled:animationsEnabled];
    
    [UIView animateWithDuration:animationDuration
                     animations:^
    {
        destination.view.frame = originalFrame;
        screenShot.frame = screenshotFrame;
    }
                     completion:^(BOOL finished)
    {
        [screenShot removeFromSuperview];
    }];
}

static UIImageView* screenShotOfView(UIView* view)
{
    // Create a snapshot for animation
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:context];
    UIImageView* screenShot = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    
    UIGraphicsEndImageContext();
    
    return screenShot;
}
@end
