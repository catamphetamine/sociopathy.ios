//
//  ArticleViewController.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LibraryArticle.h"
#import "ServerCommunication.h"

@interface LibraryArticleViewController : UIViewController <UIWebViewDelegate, ServerCommunicationDelegate>
@property(nonatomic) LibraryArticle* article;
@end
