//
//  ViewController.m
//  Sociopathy
//
//  Created by Admin on 26.12.13.
//  Copyright (c) 2013 kuchumovn. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "UITextField+Tools.h"
#import "NSDictionary+HttpTools.h"
#import "NSError+Tools.h"
#import "NSString+Tools.h"
#import "UIView+Animator.h"
#import "UIButton+Animator.h"
#import "PushSegue.h"

@interface LoginViewController ()
@end

@implementation LoginViewController
{
    __weak IBOutlet UIImageView* logoIcon;
    __weak IBOutlet UIImageView* logoText;
    
    __weak IBOutlet UITextField* login;
    __weak IBOutlet UITextField* password;
    
    __weak IBOutlet UIButton *loginButton;
    __weak IBOutlet UIActivityIndicatorView *loginProgressIndicator;
    
    __weak IBOutlet UILabel *errorMessage;
    
    __weak AppDelegate* appDelegate;
    
    UIColor* borderColor;
    UIColor* placeholderColor;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        //activeBorderColor = [UIColor colorWithRed:0.878 green:0 blue:0.133 alpha:1.0];
        placeholderColor = [UIColor colorWithRed:0.118 green:0.118 blue:0.118 alpha:1.0];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [login padding:10];
    [password padding:10];
    
    login.layer.borderColor = [borderColor CGColor];
    login.layer.borderWidth = 1.0f;
    
    password.layer.borderColor = [borderColor CGColor];
    password.layer.borderWidth = 1.0f;
    
    [login setPlaceholderColor:placeholderColor];
    [password setPlaceholderColor:placeholderColor];
    
    loginProgressIndicator.hidden = YES;
    loginProgressIndicator.alpha = 0;
    
    errorMessage.hidden = YES;
    errorMessage.alpha = 0;
    
    // on iPad:
    //
    // login field center y constant += 15 pt (should dismiss this)
    // place logo text 30 pt higher
    // place error message 30 pt lower
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) toOrientation
                                 duration:(NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation:toOrientation duration:duration];
    
    if (appDelegate.iPhone)
    {
        switch (toOrientation)
        {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                logoIcon.hidden = NO;
                break;
            }
            
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
                logoIcon.hidden = YES;
                break;
            }
        }
    }
}

- (void) showError: (NSString*) message
{
    errorMessage.text = message;
    
    [errorMessage fadeIn:0.1];
}

- (void) hideError
{
    [errorMessage fadeOut:0.1];
}

- (BOOL) validateForm
{
    if ([[login.text trim] length] == 0)
    {
        [self showError:NSLocalizedString(@"Login. Enter the username", nil)];
        return NO;
    }
    
    if ([[password.text trim] length] == 0)
    {
        [self showError:NSLocalizedString(@"Login. Enter the password", nil)];
        return NO;
    }
    
    return YES;
}

- (IBAction) performLogin: (id) sender
{
    if (![self validateForm])
        return;
    
    [loginButton fadeOut:0.1 completion:^
    {
        [loginProgressIndicator startAnimating];
        [loginProgressIndicator fadeIn:0.1];
    }];
    
    NSURL* url = [NSURL URLWithString:appDelegate.urls[@"login"]];
    
    NSDictionary* loginCredentials = @
    {
        @"имя": [login.text trim],
        @"пароль": [password.text trim]
    };
    
    [[[ServerCommunication alloc] initWithSession:appDelegate.session delegate:self] communicate:url method:@"post" parameters:loginCredentials];
}

- (void) communicationFailed: (NSError*) error
                     message: (NSString*) errorMessage
{
    ActionBlock finish = ^
    {
        [self showError:errorMessage];
        [loginButton fadeIn:0.1];
    };
   
    if ([loginProgressIndicator isVisible])
    {
        [loginProgressIndicator fadeOut:0.1 completion:^
        {
            [loginProgressIndicator stopAnimating];
            
            finish();
        }];
    }
    else
    {
        finish();
    }
}

- (NSString*) communicationErrorMessage: (NSError*) error
{
    if ([error.localizedDescription isEqualToString:@"user not found"])
    {
        return [NSString localizedStringWithFormat:NSLocalizedString(@"Login. User doesn't exist", nil), [login.text trim]];
    }
    
    if ([error.localizedDescription isEqualToString:@"wrong password"])
    {
        return NSLocalizedString(@"Login. Wrong password", nil);
    }
    
    return nil;
}

- (void) serverResponds: (NSDictionary*) data
{
    if ([loginProgressIndicator isVisible])
    {
        [loginButton.layer removeAllAnimations];
        [loginProgressIndicator fadeOut:0.1 completion:^
        {
            [loginProgressIndicator stopAnimating];
        }];
    }
   
    [self performSegueWithIdentifier:@"goToMainScreenAfterLogin" sender:self];
}

- (void) updateLabelPreferredMaxLayoutWidthToCurrentWidth: (UILabel*) label
{
    label.preferredMaxLayoutWidth = [label alignmentRectForFrame:label.frame].size.width;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self updateLabelPreferredMaxLayoutWidthToCurrentWidth:errorMessage];
    
    [self.view layoutSubviews];
}

- (BOOL) textFieldShouldReturn: (UITextField*) textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan: (NSSet*) touches
            withEvent: (UIEvent*) event
{
    UITouch* touch = [[event allTouches] anyObject];
    
    [login hideInputOnFocusLoss:touch];
    [password hideInputOnFocusLoss:touch];
    
    [super touchesBegan:touches withEvent:event];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
@end
