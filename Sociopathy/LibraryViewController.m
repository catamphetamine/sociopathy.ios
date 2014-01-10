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
#import "LibraryCell.h"
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
    __weak IBOutlet UITableView* tableView;
    
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
    
    // UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    tableView.contentInset = UIEdgeInsetsMake(10, 10, 10, 0);
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self fetchContent];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self insetOnTopAndBottom:tableView];
}

- (void) fetchContent
{
    NSURL* url = [appDelegate.url libraryCategoryContent:_category];
    
    [[[ServerCommunication alloc] initWithSession:appDelegate.session delegate:self] communicate:url method:nil parameters:nil];
}

- (void) communicationFailed: (NSError*) error
                     message: (NSString*) errorMessage
{
    [progressIndicator stopAnimating];

    [self showError:errorMessage];
}

- (void) whenServerResponds: (NSDictionary*) data
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
    
}

- (void) serverResponds: (NSDictionary*) data
{
    [tableView reloadData];
    
    tableView.hidden = NO;
    [progressIndicator stopAnimating];
}

- (void) showError: (NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:message delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Error. Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 2;
}

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
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

/*
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
*/

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
    
    NSLog(@"%f", tableView.bounds.size.width);
    NSLog(@"%f", tableView.bounds.size.height);
    
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

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    LibraryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LibraryCell"
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
                        // if loaded image and still visible
                        if (image && [[tableView indexPathsForVisibleRows] containsObject:indexPath])
                        {
                            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
                }
            }
            else
            {
                cell.icon.image = [UIImage imageNamed:@"no library category icon"];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.label.text = [category title];
            cell.label.numberOfLines = 1;
            break;
        }
            
        case LibrarySection_Articles:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
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
        NSArray* selectedCellsPaths = tableView.indexPathsForSelectedRows;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        return selectedCellPath.section == LibrarySection_Articles;
    }
    
    if ([identifier isEqualToString:@"enterCategory"])
    {
        NSArray* selectedCellsPaths = tableView.indexPathsForSelectedRows;
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
        NSArray* selectedCellsPaths = tableView.indexPathsForSelectedRows;
        NSIndexPath* selectedCellPath = [selectedCellsPaths objectAtIndex:0];
        
        LibraryArticleViewController* articleController = (LibraryArticleViewController*) segue.destinationViewController;
        articleController.article = [articles objectAtIndex:selectedCellPath.row];
    }
    
    if ([segue.identifier isEqualToString:@"enterCategory"])
    {
        NSArray* selectedCellsPaths = tableView.indexPathsForSelectedRows;
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
