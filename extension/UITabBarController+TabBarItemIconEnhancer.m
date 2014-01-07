//
//  UIViewController+TabBarItemIconEnhancer.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "UITabBarController+TabBarItemIconEnhancer.h"

@implementation UITabBarController (TabBarItemIconEnhancer)
- (void) enhanceTabBarIcons: (NSArray*) images
{
    int index = 0;
    for (NSString* image in images)
    {
        UIViewController* tab = [self.viewControllers objectAtIndex:index];
        UITabBarItem *item = tab.tabBarItem;
        
        item.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [UIImage imageNamed:image];
        
        index++;
    }
}
@end
