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
#import "LibraryCategory.h"
#import "LibraryArticle.h"
#import "LibraryCollectionViewCell.h"
#import "Url.h"
#import "ImageRequest.h"
#import "LibraryArticleViewController.h"
#import "UIViewController+TopBarAndBottomBarSpacing.h"

typedef enum LibrarySection
{
    LibrarySection_Categories = 0,
    LibrarySection_Articles = 1
}
LibrarySection;

static int kCategoryCellHeight = 42;

@interface LibraryViewController ()
@end

@implementation LibraryViewController
{
    __weak AppDelegate* appDelegate;
    
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak IBOutlet UICollectionView* collectionView;
    
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (_category)
    {
        self.title = _category.title;
    }
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    collectionView.allowsMultipleSelection = NO;
    
    [self fetchContent];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self insetOnTopAndBottom:collectionView];
}

- (void) fetchContent
{
    NSURL* url = [appDelegate.url libraryCategoryContent:_category];
    
    __weak typeof(self) controller = self;
    
    NSURLSessionDataTask* fetchContent = [appDelegate.session
                                          dataTaskWithURL:url
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
          
          [controller fetchSucceeded:json];
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

- (void) fetchSucceeded: (NSDictionary*) data
{
    categories = [NSMutableArray new];
    articles = [NSMutableArray new];
    
    data = data[@"раздел"];
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        [collectionView reloadData];
        
        collectionView.hidden = NO;
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

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView*) collectionView
{
    return 2;
}

- (NSInteger) collectionView: (UICollectionView*) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    switch (section)
    {
        case LibrarySection_Categories:
            return [categories count];
            
        case LibrarySection_Articles:
            return [articles count];
    }
    
    return 0;
}

- (UIEdgeInsets) collectionView: (UICollectionView*) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger) section
{
    // (top, left, bottom, right)
    
    switch (section)
    {
        case LibrarySection_Categories:
            // (top, left, bottom, right)
            return UIEdgeInsetsMake(15, 15, 0, 15);
            
        case LibrarySection_Articles:
            // (top, left, bottom, right)
            return UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat) collectionView: (UICollectionView*) collectionView
                    layout: (UICollectionViewLayout*) collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section
{
    switch (section)
    {
        case LibrarySection_Categories:
            return 7.0;
            
        case LibrarySection_Articles:
            return 0;
    }
    
    return 0;
}

/*
- (CGSize) collectionView: (UICollectionView*) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath*) indexPath
{
//    CGSize collectionViewSize = [[self collectionView].collectionViewLayout collectionViewContentSize];
    
//    return CGSizeMake(collectionViewSize.width, kCategoryCellHeight);
    
    float collectionViewWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    
    switch ([UIApplication sharedApplication].statusBarOrientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            return CGSizeMake(collectionViewWidth, kCategoryCellHeight);
        }
        
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            return CGSizeMake(collectionViewWidth, kCategoryCellHeight);
        }
    }
    
    return CGSizeMake(0, 0);
}
*/

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    /*
    NSArray* currentVisibleItems = self.collectionView.indexPathsForVisibleItems;
    currentVisibleItem = [currentVisibleItems objectAtIndex:0];
    NSLog(@"selected item = %d",currentVisibleItem.row);
    */
    
    NSLog(@"%f", collectionView.bounds.size.width);
    NSLog(@"%f", collectionView.bounds.size.height);
    
    //[[self collectionView].collectionViewLayout invalidateLayout];
}

/*
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView scrollToItemAtIndexPath:currentVisibleItem atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
*/

- (UICollectionViewCell*) collectionView: (UICollectionView*) collectionView
                  cellForItemAtIndexPath: (NSIndexPath*) indexPath
{
    LibraryCollectionViewCell* cell = [collectionView
                                         dequeueReusableCellWithReuseIdentifier:@"LibraryCell"
                                                                   forIndexPath:indexPath];
    
    long row = [indexPath row];
    
    switch (indexPath.section)
    {
        case LibrarySection_Categories:
        {
            LibraryCategory* category = [categories objectAtIndex:row];
            
            [cell.icon.layer setBorderColor:[iconBorderColor CGColor]];
            [cell.icon.layer setBorderWidth:1.0];
            
            NSURL* url = [appDelegate.url libraryCategoryTinyIcon:category];
            
            if (url)
            {
                ImageRequest* request = [[ImageRequest alloc] initWithURL:url];
                
                UIImage* image = [request cachedResult];
                
                if (image)
                {
                    cell.icon.image = image;
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
            }
            else
            {
                cell.icon.image = [UIImage imageNamed:@"no library category icon"];
            }
            
            cell.label.text = [category title];
            cell.label.numberOfLines = 1;
            break;
        }
            
        case LibrarySection_Articles:
        {
            cell.icon.image = nil;
            cell.label.text = [[articles objectAtIndex:row] title];
            cell.label.numberOfLines = 0;
            
            cell.label.preferredMaxLayoutWidth = [cell.label alignmentRectForFrame:cell.label.frame].size.width;
            
            //cell.icon.frame = CGRectMake(0, 0, 0, 0);
            
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
        NSArray* selectedCellsPaths = collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        return selectedCellPath.section == LibrarySection_Articles;
    }
    
    if ([identifier isEqualToString:@"enterCategory"])
    {
        NSArray* selectedCellsPaths = collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        if (selectedCellPath.section == LibrarySection_Articles)
        {
            [self performSegueWithIdentifier:@"showArticle" sender:sender];
        }
        
        return selectedCellPath.section == LibrarySection_Categories;
    }
    
    return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue
                  sender: (id) sender
{
    if ([segue.identifier isEqualToString:@"showArticle"])
    {
        NSArray* selectedCellsPaths = collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        LibraryArticleViewController* articleController = (LibraryArticleViewController*) segue.destinationViewController;
        articleController.article = [articles objectAtIndex:selectedCellPath.row];
    }
    
    if ([segue.identifier isEqualToString:@"enterCategory"])
    {
        NSArray* selectedCellsPaths = collectionView.indexPathsForSelectedItems;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        LibraryViewController* categoryController = (LibraryViewController*) segue.destinationViewController;
        categoryController.category = [categories objectAtIndex:selectedCellPath.row];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
