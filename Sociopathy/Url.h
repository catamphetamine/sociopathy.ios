//
//  Url.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibraryCategory.h"

@class AppDelegate;

@interface Url : NSObject

@property(nonatomic, weak) AppDelegate* appDelegate;
- (id) initWithAppDelegate: (AppDelegate*) appDelegate;
- (NSURL*) libraryCategoryTinyIconUrl: (LibraryCategory*) category;
@end
