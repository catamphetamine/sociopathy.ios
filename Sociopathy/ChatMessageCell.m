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

- (void) webViewDidFinishLoad: (UIWebView*) webView
{
    [webView sizeToFit];
    
    /*
    CGRect frame = webView.frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    */
    
    //[webView setFrame:CGRectMake(webView.frame.origin.x, webView.frame.origin.y, 300.0, webView.frame.size.height)];
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
