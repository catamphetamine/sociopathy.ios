//
//  ServerCommunication.h
//  Sociopathy
//
//  Created by Admin on 09.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ServerCommunicationDelegate <NSObject>
- (void) serverResponds: (NSDictionary*) data;
- (void) communicationFailed: (NSError*) error
                     message: (NSString*) errorMessage;
@optional
- (void) whenServerResponds: (NSDictionary*) data;
- (NSString*) communicationErrorMessage: (NSError*) error;
@end

@interface ServerCommunication : NSObject
- (id) initWithSession: (NSURLSession*) session
              delegate: (id <ServerCommunicationDelegate>) delegate;
- (void) communicate: (NSURL*) url
              method: (NSString*) method
          parameters: (NSDictionary*) parameters;

@end
