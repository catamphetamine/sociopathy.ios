//
//  ViewController.h
//  Sociopathy
//
//  Created by Admin on 26.12.13.
//  Copyright (c) 2013 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"
#import "KeyboardAwareController.h"

@interface LoginViewController : KeyboardAwareController <UITextFieldDelegate, ServerCommunicationDelegate>

@end
