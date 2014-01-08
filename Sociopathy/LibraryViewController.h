//
//  LibraryViewController.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryCategory.h"

@interface LibraryViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic) LibraryCategory* category;
@end
