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

static int kChatMessagesPerPage = 18;

@implementation Url
{
    NSString* httpPrefix;
    NSString* backendPrefix;
    NSString* userSpacePrefix;
    
    NSNumber* chatMessagesPerPage;
}

- (id) initWithAppDelegate: (AppDelegate*) appDelegate
{
    if (self = [super init])
    {
        httpPrefix = [@"http://" stringByAppendingString:appDelegate.settings[@"domain"]];
        backendPrefix = appDelegate.settings[@"backendPrefix"];
        userSpacePrefix = appDelegate.settings[@"userSpacePrefix"];
        
        chatMessagesPerPage = [NSNumber numberWithInt:kChatMessagesPerPage];
    }
    return self;
}

- (NSURL*) withPath: (NSString*) path
           prefixes: (NSArray*) prefixes
         parameters: (NSDictionary*) parameters
{
    NSMutableString* url = [NSMutableString new];
    
    for (NSString* prefix in prefixes)
    {
        [url appendString:prefix];
    }
    
    [url appendString:path];
    
    url = [[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    if (parameters)
    {
        [url appendString:@"?"];
        [url appendString:[parameters httpParameters]];
    }
    
    return [NSURL URLWithString:[httpPrefix stringByAppendingString:url]];
}

- (NSURL*) chatMessages
{
    return [self withPath:@"/болталка/сообщения" prefixes:@[backendPrefix, userSpacePrefix] parameters:@
    {
        @"сколько": [chatMessagesPerPage stringValue],
        @"разметка": @"html",
        @"первый_раз": @"true"
    }];
}

- (NSURL*) libraryArticleMarkup: (LibraryArticle*) article
{
    return [self withPath:@"/читальня/заметка" prefixes:@[backendPrefix] parameters:@
    {
        @"_id": article.id,
        @"разметка": @"html"
    }];
}

- (NSURL*) libraryCategoryContent: (LibraryCategory*) category
{
    NSMutableDictionary* parameters = [NSMutableDictionary new];
    
    if (category)
    {
        [parameters setObject:category.id forKey:@"_id"];
    }
    
    return [self withPath:@"/читальня/раздел" prefixes:@[backendPrefix] parameters:parameters];
}

- (NSURL*) libraryCategoryTinyIcon: (LibraryCategory*) category
{
    if (!category.icon_version)
        return nil;

    NSMutableString* path = [NSMutableString new];
    
    [path appendString:@"/загруженное/читальня/разделы/"];
    [path appendString:category.id];
    [path appendString:@"/крошечная обложка.jpg"];
    
    return [self withPath:path prefixes:nil parameters:@
    {
        @"version": [category.icon_version stringValue]
    }];
}

- (NSURL*) smallerAvatar: (User*) user
{
    if (!user.avatar_version)
        return nil;
    
    NSMutableString* path = [NSMutableString new];
    
    [path appendString:@"/загруженное/люди/"];
    [path appendString:user.identifier];
    [path appendString:@"/картинка/чуть меньше.jpg"];
    
    return [self withPath:path prefixes:nil parameters:@
    {
        @"version": [user.avatar_version stringValue]
    }];
}
@end
