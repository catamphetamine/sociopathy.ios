//
//  LibraryViewController.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryCategory.h"
#import "ServerCommunication.h"

@interface LibraryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ServerCommunicationDelegate>

@property(nonatomic) LibraryCategory* category;
@end
