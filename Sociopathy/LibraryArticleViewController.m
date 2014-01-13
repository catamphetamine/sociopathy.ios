//
//  ArticleViewController.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryArticleViewController.h"
#import "Url.h"
#import "AppDelegate.h"
#import "UIViewController+TopBarAndBottomBarSpacing.h"

@implementation LibraryArticleViewController
{
    __weak AppDelegate* appDelegate;
    
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak IBOutlet UIWebView* webView;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self insetOnTopAndBottom:webView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _article.title;
    
    [self fetchContent];
}

- (void) fetchContent
{
    NSURL* url = [appDelegate.url libraryArticleMarkup:_article];
    
    NSDictionary* parameters = @
    {
        @"device": appDelegate.device
    };
    
    [[[ServerCommunication alloc] initWithSession:appDelegate.session delegate:self] communicate:url method:nil parameters:parameters];
}

- (void) communicationFailed: (NSError*) error
                     message: (NSString*) errorMessage
{
    [progressIndicator stopAnimating];

    [self showError:errorMessage];
}

- (void) serverResponds: (NSDictionary*) data
{
    NSString* markup = data[@"заметка"][@"содержимое"];
    
    webView.delegate = self;
    [webView loadHTMLString:markup baseURL:nil];
}

- (void) showError: (NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:message delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Error. Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) webViewDidFinishLoad: (UIWebView*) webView
{
    [progressIndicator stopAnimating];
    webView.hidden = NO;
}

- (void) dealloc
{
    webView.delegate = nil;
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
