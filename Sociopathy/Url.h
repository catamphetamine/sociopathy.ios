//
//  Url.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibraryCategory.h"
#import "LibraryArticle.h"
#import "User.h"

@class AppDelegate;

@interface Url : NSObject

- (id) initWithAppDelegate: (AppDelegate*) appDelegate;
- (NSURL*) libraryCategoryContent: (LibraryCategory*) category;
- (NSURL*) libraryCategoryTinyIcon: (LibraryCategory*) category;
- (NSURL*) libraryArticleMarkup: (LibraryArticle*) article;
- (NSURL*) chatMessages;
- (NSURL*) smallerAvatar: (User*) user;
- (NSURL*) login;
- (NSURL*) logout;
@end
