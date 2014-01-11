//
//  LibraryArticleCell.h
//  Sociopathy
//
//  Created by Admin on 11.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LibraryArticle.h"

@interface LibraryArticleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* title;
- (void) article: (LibraryArticle*) article;
- (NSArray*) multilineLabels;
@end
