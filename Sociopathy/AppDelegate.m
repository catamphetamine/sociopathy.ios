//
//  AppDelegate.m
//  Sociopathy
//
//  Created by Admin on 26.12.13.
//  Copyright (c) 2013 kuchumovn. All rights reserved.
//

// making universal app:
//
// 1. copy the iPhone storyboard
// 2. targetRuntime="iOS.CocoaTouch" -> targetRuntime="iOS.CocoaTouch.iPad"
// 3. width="320" -> width="768"
// 4. height="568" -> height="1024"
// 5. <simulatedScreenMetrics key="destination" type="retina4"/> -> <simulatedScreenMetrics key="destination"/>

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions
{
    // tab bar font
    UIFont* font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f];
    
    // make tab bar text more readable
    [[UITabBarItem appearance] setTitleTextAttributes:@
    {
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1]
    }
                                             forState:UIControlStateNormal];
    
    // make tab bar text tintable when selected
    [[UITabBarItem appearance] setTitleTextAttributes:@
    {
        NSFontAttributeName:font,
        NSForegroundColorAttributeName:[UITabBar new].tintColor
    }
                                             forState:UIControlStateSelected];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    _settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    NSDictionary* urls = @
    {
        @"login": @"вход",
        @"logout": @"выход",
        
        @"get library section content": @"читальня/раздел",
    };
    
    _urls = [NSMutableDictionary new];
    
    NSString* httpPrefix = [@"http://" stringByAppendingString:_settings[@"domain"]];
    for (NSString* key in urls)
    {
        NSString* newValue = [httpPrefix stringByAppendingString:[[@"/приложение/" stringByAppendingString:[urls objectForKey:key]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	    [_urls setValue:newValue forKey:key];
    }
    
    _url = [[Url alloc] initWithAppDelegate:self];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config];
    
    // Override point for customization after application launch.
    return YES;
}

- (NSString*) remoteApiErrorMessage: (NSError*) error
{
    if (error.code == RemoteApiError_HttpConnectionError || error.code == RemoteApiError_HttpResponseError)
    {
        return NSLocalizedString(@"Remote Api. Connection to the server failed", nil);
    }
    
    if (error.code == RemoteApiError_JsonError || error.code == RemoteApiError_ServerError)
    {
        return NSLocalizedString(@"Remote Api. Server error", nil);
    }
    
    return NSLocalizedString(@"Remote Api. Generic error", nil);
}
							
- (void) applicationWillResignActive: (UIApplication*) application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void) applicationDidEnterBackground: (UIApplication*) application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void) applicationWillEnterForeground: (UIApplication*) application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void) applicationDidBecomeActive: (UIApplication*) application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void) applicationWillTerminate: (UIApplication*) application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
