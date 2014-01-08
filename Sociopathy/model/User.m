//
//  User.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithJSON: (NSDictionary*) data
{
    if (self = [super init])
    {
        self.id = data[@"_id"];
        self.identifier = data[@"id"];
        self.name = data[@"имя"];
        self.gender = data[@"пол"];
        self.avatar_version = data[@"avatar_version"];
    }
    return self;
}
@end
