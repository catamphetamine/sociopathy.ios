//
//  ChatMessage.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

@interface ChatMessage : NSObject

@property(nonatomic) NSString* id;
@property(nonatomic) NSString* content;
@property(nonatomic) NSDate* date;

@property(nonatomic) User* author;

- (id) initWithJSON: (NSDictionary*) data;

@end
