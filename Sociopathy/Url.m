//
//  Url.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "Url.h"

#import "AppDelegate.h"
#import "NSDictionary+HttpTools.h"

@implementation Url
{
    NSString* httpPrefix;
    NSString* backendPrefix;
}

- (id) initWithAppDelegate: (AppDelegate*) appDelegate
{
    if (self = [super init])
    {
        httpPrefix = [@"http://" stringByAppendingString:appDelegate.settings[@"domain"]];
        backendPrefix = appDelegate.settings[@"backendPrefix"];
    }
    return self;
}

- (NSURL*) libraryArticleMarkup: (LibraryArticle*) article
{
    NSMutableString* url = [NSMutableString new];
    
    [url appendString:backendPrefix];
    [url appendString:@"/читальня/заметка/разметка"];
    
    url = [[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    NSDictionary* parameters = @
    {
        @"_id": article.id,
        @"разметка": @"html"
    };
    
    [url appendString:@"?"];
    [url appendString:[parameters httpParameters]];
    
    return [NSURL URLWithString:[httpPrefix stringByAppendingString:url]];
}

- (NSURL*) libraryCategoryTinyIcon: (LibraryCategory*) category
{
    if (!category.icon_version)
        return nil;
    
    NSMutableString* url = [NSMutableString new];
    
    [url appendString:@"/загруженное/читальня/разделы/"];
    [url appendString:category.id];
    [url appendString:@"/крошечная обложка.jpg"];
    
    url = [[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    [url appendString:@"?version="];
    [url appendString:[category.icon_version stringValue]];
     
    return [NSURL URLWithString:[httpPrefix stringByAppendingString:url]];
}

@end
