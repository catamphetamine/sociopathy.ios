//
//  ChatMessageCell.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "ChatMessageCell.h"

@implementation ChatMessageCell

- (id) initWithCoder: (NSCoder*) aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    }
    return self;
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    
    // empty the web view
    [self.content stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.content.hidden = YES;
}

- (void) webViewDidFinishLoad: (UIWebView*) webView
{
    [webView sizeToFit];
    webView.hidden = NO;
}

- (void) dealloc
{
    self.content.delegate = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
