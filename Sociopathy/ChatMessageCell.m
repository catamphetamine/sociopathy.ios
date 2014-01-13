//
//  ChatMessageCell.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "ChatMessageCell.h"

@implementation ChatMessageCell
{
    __weak ChatMessage* message;
}

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // fix the "Unable to simultaneously satisfy constraints" bug arising from the table view cell default height
        
        // http://stackoverflow.com/questions/19132908/auto-layout-constraints-issue-on-ios7-in-uitableviewcell/21072729#21072729
    }
    return self;
}

- (void) message: (ChatMessage*) message
{
    static UIColor* avatarBorderColor;
    avatarBorderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];

    [self.avatar.layer setBorderColor:[avatarBorderColor CGColor]];
    [self.avatar.layer setBorderWidth:1.0];
    
    self.avatar.image = [UIImage imageNamed:@"no avatar"];
    
    self.content.scrollView.scrollEnabled = NO;
    self.content.scrollView.bounces = NO;
    
    self->message = message;
    
    //NSLog(@"%@", message.content);
    
    self.content.hidden = YES;
    [self.content loadHTMLString:message.content baseURL:nil];
    self.content.delegate = self;
    
    // переделать на нормальную давность типа: минутой ранее, часом ранее и т.п. (NSDate+TimeAgo)
    
    static NSString* const dateFormat = @"dd.MM\nHH:mm";
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:dateFormat];
    
    self.when.text = [dateFormatter stringFromDate:message.date];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    // empty the web view
    [self.content stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.content.hidden = YES;
}

//
// http://stackoverflow.com/questions/10996028/uiwebview-when-did-a-page-really-finish-loading
// https://github.com/Buza/uiwebview-load-completion-tracker
//
- (void) webViewDidFinishLoad: (UIWebView*) webView
{
    if (![[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"])
        return;
    
    [webView sizeToFit];
    webView.hidden = NO;
    
    CGFloat height = webView.bounds.size.height;
    
    [self.chatViewController height:height forRowId:message.id];
}

- (void) dealloc
{
    self.content.delegate = nil;
}

@end
