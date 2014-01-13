//
//  ChatMessageCell.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ChatMessage.h"
#import "ChatViewController.h"

@interface ChatMessageCell : UITableViewCell <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* avatar;
@property (weak, nonatomic) IBOutlet UIWebView* content;
@property (weak, nonatomic) IBOutlet UILabel* when;

@property (weak, nonatomic) ChatViewController* chatViewController;

@property (nonatomic) CGFloat height;

- (void) message: (ChatMessage*) message;
@end
