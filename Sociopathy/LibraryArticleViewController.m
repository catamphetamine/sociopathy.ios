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

@implementation LibraryArticleViewController
{
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak IBOutlet UIWebView* webView;
    __weak AppDelegate* appDelegate;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = _article.title;
    
    [progressIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    //progressIndicator.hidden = YES;
    //progressIndicator.alpha = 0;
    
    // center progress indicator horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // center progress indicator vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:progressIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self fetchContent];
}

- (void) fetchContent
{
    NSURL* url = [appDelegate.url libraryArticleMarkup:_article];
    
    //NSLog(@"%@", url);
    
    __weak typeof(self) controller = self;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString* device = appDelegate.iPhone ? @"iPhone" : @"iPad";
    [request addValue:device forHTTPHeaderField:@"Mobile-Device"];
    
    NSURLSessionDataTask* fetchContent = [appDelegate.session
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData* data,
                                                              NSURLResponse* response,
                                                              NSError* error)
      {
          if (error)
          {
              return [controller fetchFailed:[NSError error:error.localizedDescription code:RemoteApiError_HttpConnectionError]];
          }
          
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
          if (httpResponse.statusCode != 200)
          {
              return [controller fetchFailed:[NSError error:[NSString stringWithFormat:@"(%d)", httpResponse.statusCode] code:RemoteApiError_HttpResponseError]];
          }
          
          NSError* jsonError;
          
          NSDictionary* json =
          [NSJSONSerialization JSONObjectWithData:data
                                          options:NSJSONReadingAllowFragments
                                            error:&jsonError];
          
          if (jsonError)
          {
              return [controller fetchFailed:[NSError error:jsonError.localizedDescription code:RemoteApiError_JsonError]];
          }
          
          if (json[@"error"])
          {
              return [controller fetchFailed:[NSError error:json[@"error"] code:RemoteApiError_ServerError]];
          }
          
          return [controller fetchSucceeded:json[@"заметка"][@"содержимое"]];
      }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [fetchContent resume];
}

- (NSString*) remoteApiErrorMessage: (NSError*) error
{
    return [appDelegate remoteApiErrorMessage:error];
}

- (void) fetchFailed: (NSError*) error
{
    dispatch_async(dispatch_get_main_queue(), ^
   {
       //NSLog(@"%@", error);
       
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       
       [progressIndicator stopAnimating];
       
       [self showError:[self remoteApiErrorMessage:error]];
   });
}

- (void) fetchSucceeded: (NSString*) markup
{
    dispatch_async(dispatch_get_main_queue(), ^
   {
       //NSLog(@"%@", markup);
       
       [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
       
       [webView loadHTMLString:markup baseURL:nil];
       
       [progressIndicator stopAnimating];
   });
}

- (void) showError: (NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:message delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Error. Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
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
