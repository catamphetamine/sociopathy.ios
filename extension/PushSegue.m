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

    @interface TransitionDelegate : NSObject
    - (id) initWithScreenshot: (UIView*) screenshot;
    @end

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
        NSString* transitionType;
        
        switch ([UIApplication sharedApplication].statusBarOrientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                rotation = M_PI;
                transitionType = kCATransitionFromLeft;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                rotation = M_PI + M_PI_2;
                transitionType = kCATransitionFromBottom;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                rotation = M_PI_2;
                transitionType = kCATransitionFromTop;
                break;
                
            default:
                rotation = 0;
                transitionType = kCATransitionFromRight;
                break;
        }
        
        screenShot.transform = CGAffineTransformMakeRotation(rotation);
        
        // reposition after rotation
        CGRect frame = screenShot.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        screenShot.frame = frame;
        
        // swap the view with its screenshot
        window.rootViewController = destination;
        [window addSubview:screenShot];
        [source.view removeFromSuperview];
        
        CATransition* transition = [CATransition animation];
        
        transition.duration = animationDuration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = transitionType;
        transition.delegate = [[TransitionDelegate alloc] initWithScreenshot:screenShot];
        
        [window addSubview:destination.view];
        
        [screenShot.window.layer addAnimation:transition forKey:nil];

        /*
        const BOOL animationsEnabled = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        {
            CGRect frame = destination.view.frame;
            frame.origin.x += source.view.bounds.size.width;
            destination.view.frame = frame;
        }
        [UIView setAnimationsEnabled:animationsEnabled];
        
        [UIView animateWithDuration:animationDuration
                         animations:^
        {
            destination.view.frame = originalFrame;
            CGRect frame = screenShot.frame;
            frame.origin.x -= screenShot.bounds.size.width;
            screenShot.frame = frame;
        }
        completion:^(BOOL finished)
        {
            [screenShot removeFromSuperview];
        }];
        */
        
        /*
        CATransition* transition = [CATransition animation];
        
        
        transition.duration = animationDuration;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        
        switch ([UIApplication sharedApplication].statusBarOrientation)
        {
            case UIInterfaceOrientationPortraitUpsideDown:
                transition.subtype = kCATransitionFromLeft;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                transition.subtype = kCATransitionFromBottom;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                transition.subtype = kCATransitionFromTop;
                break;
                
            default:
                transition.subtype = kCATransitionFromRight;
                break;
        }
            
        [source.view.window.layer addAnimation:transition forKey:nil];
        
        [source presentViewController:destination animated:NO completion:nil];
        */
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

    @implementation TransitionDelegate
    {
        UIView* screenshot;
    }

    - (id) initWithScreenshot: (UIView*) screenshot
    {
        if (self = [super init])
        {
            self->screenshot = screenshot;
        }
        return self;
    }

    - (void) animationDidStop: (CAAnimation*) theAnimation
                     finished: (BOOL) flag
    {
        [screenshot removeFromSuperview];
    }
    @end
