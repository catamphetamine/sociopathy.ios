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
#import "LibraryCategoryCell.h"
#import "LibraryArticleCell.h"
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

@interface LibraryViewController ()
@end

@implementation LibraryViewController
{
    __weak AppDelegate* appDelegate;
    
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak IBOutlet UITableView* tableView;
    
    NSMutableArray* categories;
    NSMutableArray* articles;
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
    
    if (_category)
    {
        self.title = _category.title;
    }
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self fetchContent];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static LibraryArticleCell* categorySizingCell;
    static LibraryArticleCell* articleSizingCell;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        categorySizingCell = (LibraryCategoryCell*)[tableView dequeueReusableCellWithIdentifier: @"LibraryCategoryCell"];
        articleSizingCell = (LibraryArticleCell*)[tableView dequeueReusableCellWithIdentifier: @"LibraryArticleCell"];
    });
    
    long row = [indexPath row];
    
    switch (indexPath.section)
    {
        case LibrarySection_Categories:
        {
            return categorySizingCell.bounds.size.height;
        }
        
        case LibrarySection_Articles:
        {
            [articleSizingCell article:[articles objectAtIndex:row]];
            
            // force layout
            [articleSizingCell setNeedsLayout];
            [articleSizingCell layoutIfNeeded];
            
            // get the fitting size
            CGSize fittingSize = [articleSizingCell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
            //NSLog( @"fittingSize: %@", NSStringFromCGSize( fittingSize ));
            
            return fittingSize.height;
        }
    }

    return 0;
}

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
    switch (section)
    {
        case LibrarySection_Categories:
        {
            return 5;
        }
            
        case LibrarySection_Articles:
        {
            return 5;
        }
    }
    
    return 0;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    return headerView;
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

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    long row = [indexPath row];
    
    switch (indexPath.section)
    {
        case LibrarySection_Categories:
        {
            LibraryCategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LibraryCategoryCell"
                                                                        forIndexPath:indexPath];
            
            LibraryCategory* category = [categories objectAtIndex:row];
            
            [cell category:category];
            
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
            
            return cell;
        }
            
        case LibrarySection_Articles:
        {
            LibraryArticleCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LibraryArticleCell"
                                                                       forIndexPath:indexPath];
            
            [cell article:[articles objectAtIndex:row]];
            return cell;
        }
    }
    
    return nil;
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
