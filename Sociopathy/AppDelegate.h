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

typedef enum RemoteApiErrors
{
    RemoteApiError_HttpConnectionError = 1,
    RemoteApiError_HttpResponseError = 2,
    RemoteApiError_JsonError = 3,
    RemoteApiError_ServerError = 4
}
RemoteApiErrors;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow* window;
@property (nonatomic) NSDictionary* settings;
@property (nonatomic) NSDictionary* urls;
@property (nonatomic) NSURLSession* session;
@property (nonatomic) Url* url;
@property (nonatomic) BOOL iPad;
@property (nonatomic) BOOL iPhone;

- (NSString*) remoteApiErrorMessage: (NSError*) error;

@end
