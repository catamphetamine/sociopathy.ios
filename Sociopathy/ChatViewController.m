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
    __weak IBOutlet UICollectionView* collectionView;
    
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
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [self fetchContent];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self insetOnTopAndBottom:collectionView];
}

- (void) fetchContent
{
    NSURL* url = [appDelegate.url chatMessages];
    
    //NSLog(@"%@", url);
    
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
    messages = [NSMutableArray new];
    
    for (NSDictionary* messageData in data[@"сообщения"])
    {
        ChatMessage* message = [[ChatMessage alloc] initWithJSON:messageData];
        [messages addObject:message];
    }
    
    /*
    [messages sortUsingComparator:^NSComparisonResult(ChatMessage* first, ChatMessage* second)
     {
         return [first.id compare:second.id];
     }];
    */
    
    //NSLog(@"%@", messages);
    
    dispatch_async(dispatch_get_main_queue(), ^
   {
       //NSLog(@"%@", data);
       
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

- (NSInteger) collectionView: (UICollectionView*) tableView
      numberOfItemsInSection: (NSInteger) section
{
    return [messages count];
}


- (UICollectionViewCell*) collectionView: (UICollectionView*) collectionView
                  cellForItemAtIndexPath: (NSIndexPath*) indexPath
{
    ChatMessageCell* cell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:@"ChatMessageCell"
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
                 if (image && [[collectionView indexPathsForVisibleItems] containsObject:indexPath])
                 {
                     [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                 }
             }];
        }
    }
    else
    {
        cell.avatar.image = [UIImage imageNamed:@"no avatar"];
    }
    
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
