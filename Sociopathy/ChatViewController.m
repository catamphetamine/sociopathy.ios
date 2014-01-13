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
    
    // quick fix
    // without this line, table view cell's subviews heights will be reset to the ones from Interface Builder
    // can be improved by caching UIWebViews while calling [tableView reloadData]
    [tableView reloadData];
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
    
    return [self getHeightForRowId:message.id minimumHeight:minimumHeight];
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
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UIView*) tableView: (UITableView*) tableView viewForFooterInSection: (NSInteger) section
{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [headerView setBackgroundColor:[UIColor clearColor]];
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
    
    [self calculateRowHeightIfNeeded:message.id];
    
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

- (UITableView*) tableView
{
    return tableView;
}

- (UIActivityIndicatorView*) busyIndicator
{
    return progressIndicator;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
