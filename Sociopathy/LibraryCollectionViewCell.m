
//
//  LibraryCollectionViewCell.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryCollectionViewCell.h"

@implementation LibraryCollectionViewCell

- (id )initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        //[self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        /*
        [_icon setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_label setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        NSDictionary* views = NSDictionaryOfVariableBindings(_icon, _label);
        
        NSDictionary* metrics = @{ @"sideMargin": @5.0 };
         
        UIView* collectionView = [self.window viewWithTag:100];
         
        // set login width
        [collectionView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:collectionView
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1
                                                            constant:0.0]];
        
        
        [collectionView addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:collectionView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1
                                                                    constant:0.0]];
         
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideMargin-[_icon]-sideMargin-[_label]-sideMargin-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
         */
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
