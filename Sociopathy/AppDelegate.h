//
//  AppDelegate.h
//  Sociopathy
//
//  Created by Admin on 26.12.13.
//  Copyright (c) 2013 kuchumovn. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Url.h"
#import "NSError+Tools.h"

typedef void (^ActionBlock)(void);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow* window;
@property (nonatomic) NSDictionary* settings;
@property (nonatomic) NSURLSession* session;
@property (nonatomic) Url* url;
@property (nonatomic) BOOL iPad;
@property (nonatomic) BOOL iPhone;
@property (nonatomic) NSString* device;

- (NSString*) remoteApiErrorMessage: (NSError*) error;

@end
