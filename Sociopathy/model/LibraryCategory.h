//
//  LibraryCategory.h
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryCategory : NSObject
@property(nonatomic) NSString* id;
@property(nonatomic) NSString* title;
@property(nonatomic) NSNumber* order;
@property(nonatomic) NSString* path;
@property(nonatomic) NSNumber* icon_version;

- (id) initWithJSON: (NSDictionary*) data;
@end
