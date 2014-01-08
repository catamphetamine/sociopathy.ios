//
//  ChatMessageCell.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMessageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIWebView *content;
@property (weak, nonatomic) IBOutlet UILabel *when;

@end
