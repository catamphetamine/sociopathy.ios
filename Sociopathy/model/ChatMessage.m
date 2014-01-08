//
//  ChatMessage.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

- (id) initWithJSON: (NSDictionary*) data
{
    if (self = [super init])
    {
        self.id = data[@"_id"];
        self.content = data[@"сообщение"];
        
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        self.date = [dateFormatter dateFromString:data[@"когда"]];
        
        self.author = [[User alloc] initWithJSON:data[@"отправитель"]];
    }
    return self;
}
@end
