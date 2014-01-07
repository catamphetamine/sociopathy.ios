//
//  LibraryArticle.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryArticle.h"

@implementation LibraryArticle
- (id) initWithJSON: (NSDictionary*) data
{
    if (self = [super init])
    {
        self.id = data[@"_id"];
        self.title = data[@"название"];
        self.order = data[@"порядок"];
        self.path = data[@"путь"];
    }
    return self;
}
@end
