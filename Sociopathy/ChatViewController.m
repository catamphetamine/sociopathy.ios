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
    
    UIColor* avatarBorderColor;
    
    NSMutableArray* messages;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        
        avatarBorderColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
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
    
    [cell.avatar.layer setBorderColor:[avatarBorderColor CGColor]];
    [cell.avatar.layer setBorderWidth:1.0];
    
    NSURL* url = [appDelegate.url smallerAvatar:message.author];
    
    if (url)
    {
        ImageRequest* request = [[ImageRequest alloc] initWithURL:url];
        
        UIImage* image = [request cachedResult];
        
        if (image)
        {
            cell.avatar.image = image;
        }
        else
        {
            [request startWithCompletion:^(UIImage* image, NSError* error)
             {
                 if (image && [[tableView indexPathsForVisibleRows] containsObject:indexPath])
                 {
                     [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                 }
             }];
        }
    }
    else
    {
        cell.avatar.image = [UIImage imageNamed:@"no avatar"];
    }
    
    cell.content.scrollView.scrollEnabled = NO;
    cell.content.scrollView.bounces = NO;
    
    [cell.content loadHTMLString:message.content baseURL:nil];
    cell.content.delegate = cell;
    
    // переделать на нормальную давность типа: минутой ранее, часом ранее и т.п.
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"dd.MM\nHH:mm"];
    
    cell.when.text = [dateFormatter stringFromDate:message.date];
    
    return cell;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
