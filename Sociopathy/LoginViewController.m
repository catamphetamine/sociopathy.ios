//
//  ViewController.m
//  Sociopathy
//
//  Created by Admin on 26.12.13.
//  Copyright (c) 2013 kuchumovn. All rights reserved.
//

#import "LoginViewController.h"
#import "UITextField+Tools.h"
#import "NSDictionary+HttpTools.h"
#import "NSError+Tools.h"
#import "NSString+Tools.h"

#import "AppDelegate.h"

@interface LoginViewController ()
@property (nonatomic, strong) NSURLSession* session;
@end

typedef enum LoginErrorCode
{
    LoginError_HttpConnectionError = 1,
    LoginError_HttpResponseError = 2,
    LoginError_JsonError = 3,
    LoginError_ServerError = 4
}
LoginErrorCode;

@implementation LoginViewController
{
    __weak IBOutlet UIImageView* logoIcon;
    __weak IBOutlet UIImageView* logoText;
    
    __weak IBOutlet UITextField* login;
    __weak IBOutlet UITextField* password;
    
    __weak IBOutlet UIButton *loginButton;
    __weak IBOutlet UIActivityIndicatorView *loginProgressIndicator;
    
    __weak IBOutlet UILabel *errorMessage;
    
    UIColor* borderColor;
    UIColor* placeholderColor;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
        //activeBorderColor = [UIColor colorWithRed:0.878 green:0 blue:0.133 alpha:1.0];
        placeholderColor = [UIColor colorWithRed:0.118 green:0.118 blue:0.118 alpha:1.0];
        
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
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
    
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [logoIcon setTranslatesAutoresizingMaskIntoConstraints:NO];
    [logoText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [login setTranslatesAutoresizingMaskIntoConstraints:NO];
    [password setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loginProgressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    [errorMessage setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    loginProgressIndicator.hidden = YES;
    loginProgressIndicator.alpha = 0;
    
    errorMessage.hidden = YES;
    errorMessage.alpha = 0;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(logoIcon, logoText, login, password, loginButton, loginProgressIndicator, errorMessage);
    
    // center logo icon horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoIcon
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center logo text horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoText
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center login horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:login
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center password horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center login button horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center login button progress horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginProgressIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center login vertically and shift it upward
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:login
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:-5.0]];
    
    // set login width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:login
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:190.0]];
    
    // set login height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:login
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:36.0]];
    
    // set password width
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:login
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // set password height
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:login
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // place logo text above login
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoText
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:login
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-30.0]];
    
    // place logo icon above logo text
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoIcon
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:logoText
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:-40.0]];
    
    // place password under login
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:password
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:login
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    // place login button under password
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:password
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:15.0]];
    
    // place login button indicator at the same point as the login button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginProgressIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:loginButton
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // place error message under login button
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:errorMessage
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:loginButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:10.0]];
    
    [errorMessage setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [errorMessage setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    NSLayoutConstraint* errorMessageHeight = [NSLayoutConstraint constraintWithItem:errorMessage
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:0
                                                                         multiplier:0
                                                                           constant:1];
    
    errorMessageHeight.priority = 300;
    
    [errorMessage addConstraint:errorMessageHeight];
    
    /*
    [errorMessage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[errorMessage(20@300)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(errorMessage)]];
    */
    
    // size error message
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[errorMessage]-(10)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation) toOrientation
                                 duration:(NSTimeInterval) duration
{
    if (toOrientation == UIInterfaceOrientationPortrait ||
        toOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        logoIcon.hidden = NO;
    }
    else
    {
        if (toOrientation == UIInterfaceOrientationLandscapeLeft ||
            toOrientation == UIInterfaceOrientationLandscapeRight)
        {
            logoIcon.hidden = YES;
        }
    }
}

- (void) loginFailed: (NSError*) error
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        NSLog(@"%@", error);
        
        NSString* message;
        
        if ([error.localizedDescription isEqualToString:@"user not found"])
        {
            message = [NSString localizedStringWithFormat:NSLocalizedString(@"Login. User %@ doesn't exist", nil), [login.text trim]];
        }
        else if ([error.localizedDescription isEqualToString:@"incorrect password"])
        {
            message = NSLocalizedString(@"Login. Wrong password", nil);
        }
        else if (error.code == LoginError_HttpConnectionError || error.code == LoginError_HttpResponseError)
        {
            message = NSLocalizedString(@"Login. Connection to the server failed", nil);
        }
        else if (error.code == LoginError_JsonError || error.code == LoginError_ServerError)
        {
            message = NSLocalizedString(@"Login. Server error", nil);
        }
        
        /*
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:message delegate:self cancelButtonTitle:@"Ясно" otherButtonTitles: nil];
        
        [alert show];
        */
        
        [self showError:message];
    
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [loginProgressIndicator.layer removeAllAnimations];
        [UIView animateWithDuration:0.1
                         animations:^{ loginProgressIndicator.alpha = 0; }
                         completion:^(BOOL finished)
        {
            [loginProgressIndicator stopAnimating];
            loginProgressIndicator.hidden = YES;
            
            loginButton.hidden = NO;
            loginButton.userInteractionEnabled = YES;
            
            [loginButton.layer removeAllAnimations];
            [UIView animateWithDuration:0.3 animations:^{ loginButton.alpha = 1.0; }];
        }];
    });
}

- (void) loginSucceeded: (NSDictionary*) data
{
    dispatch_async(dispatch_get_main_queue(),^
    {
        NSLog(@"%@", data);

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        [loginProgressIndicator.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.3
                         animations:^{ loginProgressIndicator.alpha = 0; }
                         completion:^(BOOL finished)
        {
            loginProgressIndicator.hidden = YES;
            [loginProgressIndicator stopAnimating];
        }];
    });
}

- (void) showError: (NSString*) message
{
    errorMessage.text = message;
    
    if (errorMessage.hidden)
    {
        loginProgressIndicator.alpha = 0;
        errorMessage.hidden = NO;
    }
    
    if (errorMessage.alpha != 1.0)
    {
        [errorMessage.layer removeAllAnimations];
        
        [UIView animateWithDuration:0.2 animations:^{ errorMessage.alpha = 1.0; }];
    }
}

- (void) hideError
{
    if (errorMessage.hidden)
    {
        return;
    }
    
    [errorMessage.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.1
                     animations:^{ errorMessage.alpha = 0; }
                     completion:^(BOOL finished)
    {
        errorMessage.hidden = YES;
    }];
}

- (IBAction) performLogin: (id) sender
{
    if ([[login.text trim] length] == 0)
    {
        return [self showError:NSLocalizedString(@"Login. Enter the username", nil)];
    }
    
    if ([[password.text trim] length] == 0)
    {
        return [self showError:NSLocalizedString(@"Login. Enter the password", nil)];
    }
    
    [loginButton.layer removeAllAnimations];
    
    loginButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
                     animations:^{ loginButton.alpha = 0; }
                     completion:^(BOOL finished)
    {
        loginButton.hidden = YES;
    }];
    
    loginProgressIndicator.hidden = NO;
    [loginProgressIndicator.layer removeAllAnimations];
    [UIView animateWithDuration:0.3 animations:^{ loginProgressIndicator.alpha = 1.0; }];
    
    [loginProgressIndicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSURL* url = [NSURL URLWithString:appDelegate.urls[@"login"]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary* loginCredentials = @
    {
        @"имя": [login.text trim],
        @"пароль": [password.text trim]
    };

    __weak typeof(self) controller = self;
    
    NSURLSessionUploadTask* checkCredentials = [_session
                                          uploadTaskWithRequest:request
                                          fromData:[loginCredentials postParameters]
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error)
    {
        if (error)
        {
            return [controller loginFailed:[NSError error:error.localizedDescription code:LoginError_HttpConnectionError domain:@"login"]];
        }
    
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
        if (httpResponse.statusCode != 200)
        {
            return [controller loginFailed:[NSError error:[NSString stringWithFormat:@"(%d)", httpResponse.statusCode] code:LoginError_HttpResponseError domain:@"login"]];
        }
    
        NSError* jsonError;
        
        NSDictionary* json =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:&jsonError];
        
        if (jsonError)
        {
            return [controller loginFailed:[NSError error:jsonError.localizedDescription code:LoginError_JsonError domain:@"login"]];
        }
        
        if (json[@"error"])
        {
            return [controller loginFailed:[NSError error:json[@"error"] code:LoginError_ServerError domain:@"login"]];
        }
        
        [controller loginSucceeded:json];
    }];
    
    [checkCredentials resume];
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
