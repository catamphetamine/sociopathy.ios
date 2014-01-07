//
//  LibraryViewController.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "LibraryViewController.h"

#import "AppDelegate.h"
#import "UIView+Animator.h"
#import "NSURL+Tools.h"
#import "NSError+Tools.h"
#import "LibraryCategory.h"
#import "LibraryArticle.h"

@interface LibraryViewController ()
@end

@implementation LibraryViewController
{
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak AppDelegate* appDelegate;
    
    NSArray* categories;
    NSArray* articles;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

-
(NSString*) remoteApiErrorMessage: (NSError*) error
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

- (void) fetchSucceeded: (NSDictionary*) data
{
    NSMutableArray* categories = [[NSMutableArray alloc] init];
    NSMutableArray* articles = [[NSMutableArray alloc] init];
    
    data = data[@"раздел"];
    
    for (NSDictionary* categoryData in data[@"подразделы"])
    {
        //if (![data[@"is_dir"] boolValue])
        
        LibraryCategory* category = [[LibraryCategory alloc] initWithJSON:categoryData];
        [categories addObject:category];
    }
    
    for (NSDictionary* articleData in data[@"заметки"])
    {
        //if (![data[@"is_dir"] boolValue])
        
        LibraryArticle* category = [[LibraryArticle alloc] initWithJSON:articleData];
        [articles addObject:category];
    }
    
    [categories sortUsingComparator:^NSComparisonResult(LibraryCategory* first, LibraryCategory* second)
    {
        return [first.order compare:second.order];
    }];
    
    [articles sortUsingComparator:^NSComparisonResult(LibraryArticle* first, LibraryArticle* second)
    {
        return [first.order compare:second.order];
    }];
    
    NSLog(@"%@", categories);
    NSLog(@"%@", articles);
    
    self->categories = categories;
    self->articles = articles;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSLog(@"%@", data);
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.collectionView reloadData];
        
        [progressIndicator stopAnimating];
    });
}

- (void) showError: (NSString*) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:message delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Error. Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) viewDidLoad
{
    NSLog(@"loaded library");
    
    [super viewDidLoad];
    
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
    NSDictionary* parameters = @
    {
        @"_id": @""
    };
    
    NSURL* url = [NSURL URLWithString:appDelegate.urls[@"get library section content"] parameters:parameters];

    NSLog(@"%@", url);
    
    __weak typeof(self) controller = self;
    
    NSURLSessionDataTask* fetchContent = [appDelegate.session
                                                  dataTaskWithURL:url
                                                completionHandler:^(NSData *data,
                                                                    NSURLResponse *response,
                                                                    NSError *error)
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
        
        [controller fetchSucceeded:json];
    }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [fetchContent resume];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
