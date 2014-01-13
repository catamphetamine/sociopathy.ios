//
//  ChatViewController.m
//  Sociopathy
//
//  Created by Admin on 07.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "ChatMessage.h"
#import "ImageRequest.h"
#import "ChatMessageCell.h"
#import "UIViewController+TopBarAndBottomBarSpacing.h"

@interface ChatViewController ()

@end

@implementation ChatViewController
{
    __weak AppDelegate* appDelegate;
    
    __weak IBOutlet UIActivityIndicatorView* progressIndicator;
    __weak IBOutlet UITableView* tableView;
    
    NSMutableArray* messages;
    
    NSMutableDictionary* rowHeightCache;
    NSMutableArray* rowHeightCacheLeft;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        rowHeightCache = [NSMutableDictionary dictionary];
        rowHeightCacheLeft = [NSMutableArray new];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
    NSURL* url = [appDelegate.url chatMessages];
    
    NSDictionary* parameters = @
    {
        @"device": appDelegate.device,
        @"view": @"chat"
    };
    
    [[[ServerCommunication alloc] initWithSession:appDelegate.session delegate:self] communicate:url method:nil parameters:parameters];
}

- (void) communicationFailed: (NSError*) error
                     message: (NSString*) errorMessage
{
    [progressIndicator stopAnimating];
   
    [self showError:errorMessage];
}

- (void) whenServerResponds: (NSDictionary*) data
{
    messages = [NSMutableArray new];
    
    for (NSDictionary* messageData in data[@"сообщения"])
    {
        ChatMessage* message = [[ChatMessage alloc] initWithJSON:messageData];
        [messages addObject:message];
    }
}
    
- (void) serverResponds: (NSDictionary*) data
{
    [tableView reloadData];
    
    //tableView.hidden = NO;
    //[progressIndicator stopAnimating];
}

- (void) showError: (NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:message delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Error. Dismiss", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
}

- (void) viewWillDisappear: (BOOL) animated
{
    NSLog(@"viewWillDisappear");
    
    [super viewWillDisappear:animated];
}

- (void) height: (CGFloat) height
     forMessage: (ChatMessage*) message
{
    rowHeightCache[message.id] = @(height);
    
    //NSLog(@"caching height %f for message %@", height, message.id);
    
    [rowHeightCacheLeft removeObject:message.id];
    
    if (rowHeightCacheLeft && rowHeightCacheLeft.count == 0)
    {
        //NSLog(@"update table view");
        
        rowHeightCacheLeft = nil;
        
        //[tableView beginUpdates];
        //[tableView endUpdates];
        
        tableView.hidden = NO;
        progressIndicator.hidden = YES;
        
        [tableView reloadData];
    }
}

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static ChatMessageCell* sizingCell;
    static CGFloat minimumHeight;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        sizingCell = (ChatMessageCell*)[tableView dequeueReusableCellWithIdentifier: @"ChatMessageCell"];
        minimumHeight = [sizingCell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize].height;
    });

    long row = [indexPath row];
    
    ChatMessage* message = [messages objectAtIndex:row];
    
    NSNumber* cachedHeight = rowHeightCache[message.id];
    
    //NSLog(@"height for row %ld is %@", row, cachedHeight);
    
    CGFloat height = minimumHeight;
    
    if (cachedHeight != nil)
    {
        if ([cachedHeight floatValue] > height)
            height = [cachedHeight floatValue];
    }
    
    return height;
}

- (CGFloat) tableView: (UITableView*) tableView heightForHeaderInSection: (NSInteger) section
{
    return 5;
}

- (CGFloat) tableView: (UITableView*) tableView heightForFooterInSection: (NSInteger) section
{
    return 5;
}

- (UIView*) tableView: (UITableView*) tableView viewForHeaderInSection: (NSInteger) section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    return headerView;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    return headerView;
}

- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return [messages count];
}

- (UITableViewCell*) tableView: (UITableView*) tableView
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    ChatMessageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChatMessageCell"
                                       forIndexPath:indexPath];
    
    long row = [indexPath row];

    ChatMessage* message = [messages objectAtIndex:row];
    
    if (rowHeightCache[message.id] == nil)
    {
        rowHeightCache[message.id] = [NSNumber numberWithInt:0];
        [rowHeightCacheLeft addObject:message.id];
    }
    
    cell.chatViewController = self;
    
    [cell message:message];
    
    NSURL* url = [appDelegate.url smallerAvatar:message.author];
    
    if (url)
    {
        ImageRequest* request = [[ImageRequest alloc] initWithURL:url tableView:tableView indexPath:indexPath];
        
        if ([request available])
            cell.avatar.image = [request cachedResult];
        else
            [request load];
    }
    
    return cell;
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation:toOrientation duration:duration];
    
    tableView.hidden = YES;
    progressIndicator.hidden = NO;
    [progressIndicator startAnimating];
    
    [rowHeightCache removeAllObjects];
    rowHeightCacheLeft = [NSMutableArray new];
    
    [tableView reloadData];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
