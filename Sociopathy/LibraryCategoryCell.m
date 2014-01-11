
//
//  LibraryCollectionViewCell.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryCategoryCell.h"

@implementation LibraryCategoryCell

/*
 or this: self.contentView.bounds = CGRectMake(0, 0, 99999, 99999);
 
 - (id) initWithCoder: (NSCoder*) decoder
 {
 if (self = [super initWithCoder:decoder])
 {
 // fixes the "Unable to simultaneously satisfy constraints" bug arising from the table view cell default height
 self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
 
 UIView* contentView = self.contentView;
 
 NSDictionary* views = NSDictionaryOfVariableBindings(contentView);
 
 [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:views]];
 
 [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:views]];
 }
 return self;
 }
*/

- (void) category: (LibraryCategory*) category
{
    static UIColor* iconBorderColor;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        iconBorderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    });

    [self.icon.layer setBorderColor:[iconBorderColor CGColor]];
    [self.icon.layer setBorderWidth:1.0];
    
    self.icon.image = [UIImage imageNamed:@"no library category icon"];
    
    self.title.text = [category title];
}
@end
