//
//  LibraryCollectionViewCell.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LibraryCategory.h"

@interface LibraryCategoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* title;
@property (weak, nonatomic) IBOutlet UIImageView* icon;

- (void) category: (LibraryCategory*) category;
@end
