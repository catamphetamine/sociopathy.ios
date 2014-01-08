//
//  User.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic) NSString* id;
@property(nonatomic) NSString* name;
@property(nonatomic) NSString* identifier;
@property(nonatomic) NSString* gender;
@property(nonatomic) NSNumber* avatar_version;

- (id) initWithJSON: (NSDictionary*) data;
@end
