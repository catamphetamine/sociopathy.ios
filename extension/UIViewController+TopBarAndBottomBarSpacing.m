//
//  UIViewController+TopBarAndBottomBarSpacing.m
//  Sociopathy
//
//  Created by Admin on 09.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "UIViewController+TopBarAndBottomBarSpacing.h"

@implementation UIViewController (TopBarAndBottomBarSpacing)
- (void) insetOnTopAndBottom: (UIView*) subview
{
    UIEdgeInsets inset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
    
    if ([subview isKindOfClass:[UICollectionView class]])
    {
        UICollectionView* collectionView = (UICollectionView*) subview;
        collectionView.contentInset = inset;
    }
    else if ([subview isKindOfClass:[UIWebView class]])
    {
        UIWebView* webView = (UIWebView*) subview;
        webView.scrollView.contentInset = inset;
    }
}
@end
