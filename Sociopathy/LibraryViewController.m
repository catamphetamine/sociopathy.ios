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
#import "LibraryCollectionViewCell.h"
#import "Url.h"
#import "ImageRequest.h"
#import "ArticleViewController.h"

@interface LibraryViewController ()
@end

@implementation LibraryViewController
{
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak AppDelegate* appDelegate;
    
    NSMutableArray* categories;
    NSMutableArray* articles;
    
    UIColor* iconBorderColor;
    
    LibraryArticle* article;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        iconBorderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
    return self;
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

- (void) fetchSucceeded: (NSDictionary*) data
{
    //NSMutableArray* categories = [[NSMutableArray alloc] init];
    //NSMutableArray* articles = [[NSMutableArray alloc] init];
    
    categories = [NSMutableArray new];
    articles = [NSMutableArray new];
    
    data = data[@"раздел"];
    
    // [data[@"flag"] boolValue]
    
    for (NSDictionary* categoryData in data[@"подразделы"])
    {
        LibraryCategory* category = [[LibraryCategory alloc] initWithJSON:categoryData];
        [categories addObject:category];
    }
    
    for (NSDictionary* articleData in data[@"заметки"])
    {
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
    
    //NSLog(@"%@", categories);
    //NSLog(@"%@", articles);
    
    //self->categories = categories;
    //self->articles = articles;
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        //NSLog(@"%@", data);
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [self.collectionView reloadData];
        
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

- (void) viewDidLoad
{
    //NSLog(@"loaded library");
    
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
    
    [self collectionView].allowsMultipleSelection = NO;
    
    [self fetchContent];
}

- (void) fetchContent
{
    NSDictionary* parameters = @
    {
        //@"_id": @"51d04cc5b6f8da5c1f000001"
        @"_id": @""
    };
    
    NSURL* url = [NSURL URLWithString:appDelegate.urls[@"get library section content"] parameters:parameters];

    //NSLog(@"%@", url);
    
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

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView*) collectionView
{
    return 2;
}

- (NSInteger) collectionView: (UICollectionView*) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    switch (section)
    {
        case 0:
            return [categories count];
            
        case 1:
            return [articles count];
    }
    
    return 0;
}

- (UICollectionViewCell*) collectionView: (UICollectionView*) collectionView
                  cellForItemAtIndexPath: (NSIndexPath*) indexPath
{
    LibraryCollectionViewCell* cell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:@"LibraryCell"
                                                                   forIndexPath:indexPath];
    
    long row = [indexPath row];
    
    switch (indexPath.section)
    {
        case 0:
        {
            LibraryCategory* category = [categories objectAtIndex:row];
            
            NSURL* url = [appDelegate.url libraryCategoryTinyIconUrl:category];
            
            // note that this can be a web url or file url
            
            ImageRequest* request = [[ImageRequest alloc] initWithURL:url];
            
            UIImage* image = [request cachedResult];
            
            if (image)
            {
                cell.icon.image = image;
                [cell.icon.layer setBorderColor:[iconBorderColor CGColor]];
                [cell.icon.layer setBorderWidth:1.0];
            }
            else
            {
                [request startWithCompletion:^(UIImage* image, NSError* error)
                {
                    if (image && [[collectionView indexPathsForVisibleItems] containsObject:indexPath])
                    {
                        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                    }
                }];
            }
            
            cell.label.text = [category title];
            break;
        }
            
        case 1:
        {
            cell.label.text = [[articles objectAtIndex:row] title];
            break;
        }
    }
    
    return cell;
}

- (BOOL) shouldPerformSegueWithIdentifier: (NSString*) identifier
                                   sender: (id) sender
{
    if ([identifier isEqualToString:@"showArticle"])
    {
        NSArray* selectedCellsPaths = self.collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        return selectedCellPath.section == 1;
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue
                  sender: (id) sender
{
    if ([segue.identifier isEqualToString:@"showArticle"])
    {
        NSArray* selectedCellsPaths = self.collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        ArticleViewController* articleController = (ArticleViewController*) segue.destinationViewController;
        articleController.article = [articles objectAtIndex:selectedCellPath.row];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
