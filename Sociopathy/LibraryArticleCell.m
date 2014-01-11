//
//  LibraryArticleCell.m
//  Sociopathy
//
//  Created by Admin on 11.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryArticleCell.h"

@implementation LibraryArticleCell
- (void) article: (LibraryArticle*) article
{
    self.title.text = [article title];
}
@end
