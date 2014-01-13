//
//  ChatViewController.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerCommunication.h"

#import "DynamicRowHeightTableViewController.h"

@interface ChatViewController : DynamicRowHeightTableViewController <UITableViewDataSource, UITableViewDelegate, ServerCommunicationDelegate>
@end
