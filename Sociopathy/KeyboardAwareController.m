//
//  KeyboardAwareController.m
//  Sociopathy
//
//  Created by Admin on 13.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "KeyboardAwareController.h"

@interface KeyboardAwareController ()

@end

@implementation KeyboardAwareController
{
    CGPoint scrollPositionBeforeKeyboardAdjustments;
    
    __weak UIScrollView* scrollView;
    
    UITextField* activeField;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        scrollPositionBeforeKeyboardAdjustments = CGPointZero;
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (UIScrollView*) scrollView
{
    return (UIScrollView*) self.view;
}

- (CGFloat) keyboardPadding
{
    return 5;
}

- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) deregisterFromKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}

- (void) keyboardWillShow: (NSNotification*) notification
{
    //NSLog(@"keyboardWillShow");
    
    // force the animation from keyboardWillBeHidden: to end
    scrollView.contentOffset = scrollPositionBeforeKeyboardAdjustments;
    
    scrollPositionBeforeKeyboardAdjustments = CGPointZero;
}

// warning: i have no idea why this thing works and what does every line of this code mean
// (but it works and there is no other solution on the internets whatsoever)
// P.S. Shame on Apple for missing such a basic functionality from SDK (and many other basic features we have to hack and mess around with for days and nights)

- (void) keyboardDidShow: (NSNotification*) notification
{
    //NSLog(@"keyboardDidShow");
    
    UIWindow* window = [[[UIApplication sharedApplication] windows]objectAtIndex:0];
    UIView* mainSubviewOfWindow = window.rootViewController.view;
    
    CGRect keyboardFrameIncorrect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardFrame = [mainSubviewOfWindow convertRect:keyboardFrameIncorrect fromView:window];
    CGSize keyboardSize = keyboardFrame.size;
    
    CGRect visibleFrame = CGRectMake(0, 0, 0, 0);
    visibleFrame.origin = self.scrollView.contentOffset;
    visibleFrame.size = self.scrollView.bounds.size;
    
    CGFloat paddedKeyboardHeight = keyboardSize.height + self.keyboardPadding;
    
    //NSLog(@"visibleFrame %@", NSStringFromCGRect(visibleFrame));
    
    visibleFrame.size.height -= paddedKeyboardHeight;
    
    //NSLog(@"visibleFrame after keyboard height %@", NSStringFromCGRect(visibleFrame));
    
    if (CGRectContainsPoint(visibleFrame, activeField.frame.origin))
        return;
    
    scrollPositionBeforeKeyboardAdjustments = scrollView.contentOffset;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, activeField.frame.origin.y - visibleFrame.size.height + activeField.frame.size.height, 0);
    
    contentInsets = UIEdgeInsetsMake(0.0, 0.0, paddedKeyboardHeight, 0);
    
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    CGSize scrollContentSize = self.scrollView.bounds.size;
    scrollContentSize.height += paddedKeyboardHeight;
    self.scrollView.contentSize = scrollContentSize;
    
    //NSLog(@"scrollView %@", NSStringFromCGRect(scrollView.frame));
    //NSLog(@"activeField %@", NSStringFromCGRect(activeField.frame));
    
    //[scrollView scrollRectToVisible:activeField.frame animated:YES];
    
    CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y - visibleFrame.size.height + activeField.frame.size.height);
    
    //NSLog(@"scrollPoint %@", NSStringFromCGPoint(scrollPoint));
    
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void) keyboardWillBeHidden: (NSNotification*) notification
{
    //NSLog(@"keyboardWillBeHidden");
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    // this doesn't work when changing orientation while the keyboard is visible
    // because when keyboardDidShow: will be called right after this method the contentOffset will still be equal to the old value
    //[scrollView setContentOffset:scrollPositionBeforeKeyboardAdjustments animated:YES];
    
    [UIView animateWithDuration:.25 animations:^
    {
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        // replacement for setContentOffset:animated:
        self.scrollView.contentOffset = scrollPositionBeforeKeyboardAdjustments;
    }];
}

- (void) textFieldDidBeginEditing: (UITextField*) textField
{
    activeField = textField;
}

- (void) textFieldDidEndEditing: (UITextField*) textField
{
    activeField = nil;
}
@end
