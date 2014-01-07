//
//  Url.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "Url.h"

#import "LibraryCategory.h"
#import "AppDelegate.h"

@implementation Url

- (id) initWithAppDelegate: (AppDelegate*) appDelegate
{
    if (self = [super init])
    {
        self.appDelegate = appDelegate;
    }
    return self;
}

- (NSURL*) libraryCategoryTinyIconUrl: (LibraryCategory*) category
{
    NSMutableString* url = [NSMutableString new];
    
    NSString* httpPrefix = [@"http://" stringByAppendingString:_appDelegate.settings[@"domain"]];
    
    [url appendString:httpPrefix];
    [url appendString:@"/"];
     
    [url appendString:@"загруженное/читальня/разделы/"];
    [url appendString:category.id];
    [url appendString:@"/крошечная обложка.jpg"];
    
    url = [[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [url appendString:@"?version="];
    [url appendString:[category.icon_version stringValue]];
     
    return [NSURL URLWithString:[url copy]];
}

@end
