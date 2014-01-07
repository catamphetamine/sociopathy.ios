//
//  MainViewController.m
//  Sociopathy
//
//  Created by Admin on 04.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "TabBarViewController.h"

#import "UITabBarController+TabBarItemIconEnhancer.h"

@interface TabBarViewController ()
@end

@implementation TabBarViewController
{
    __weak IBOutlet UITabBar* tabBar;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // make tab bar icon colors better
    
    [self enhanceTabBarIcons:@[@"tab bar archive icon", @"tab bar chat icon"]];
        
    // layout
    
    [tabBar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    /*
    NSDictionary *views = NSDictionaryOfVariableBindings(tabBar);
    
    // place the tab bar on the bottom
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tabBar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
   
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tabBar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
     */
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
