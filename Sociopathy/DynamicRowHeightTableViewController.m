//
//  DynamicRowHeightTableViewController.m
//  Sociopathy
//
//  Created by Admin on 13.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "DynamicRowHeightTableViewController.h"

@interface DynamicRowHeightTableViewController ()

@end

@implementation DynamicRowHeightTableViewController
{
    NSMutableDictionary* rowHeightCache;
    NSMutableArray* rowHeightCacheLeft;
}

- (id) initWithCoder: (NSCoder*) decoder
{
    if (self = [super initWithCoder:decoder])
    {
        rowHeightCache = [NSMutableDictionary dictionary];
        rowHeightCacheLeft = [NSMutableArray new];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) height: (CGFloat) height
       forRowId: (NSString*) id
{
    rowHeightCache[id] = @(height);
    
    //NSLog(@"caching height %f for message %@", height, id);
    
    [rowHeightCacheLeft removeObject:id];
    
    if (rowHeightCacheLeft && rowHeightCacheLeft.count == 0)
    {
        //NSLog(@"update table view");
        
        rowHeightCacheLeft = nil;
        
        self.tableView.hidden = NO;
        
        [self.busyIndicator stopAnimating];
        self.busyIndicator.hidden = YES;
        
        // force table view to refresh row heights
        // can be improved by caching UIWebViews while calling [tableView reloadData]
        [self.tableView reloadData];
    }
}

- (CGFloat) getHeightForRowId: (NSString*) rowId
                minimumHeight: (CGFloat) minimumHeight
{
    NSNumber* cachedHeight = rowHeightCache[rowId];
    
    //NSLog(@"height for row %ld is %@", row, cachedHeight);
    
    CGFloat height = minimumHeight;
    
    if (cachedHeight != nil)
    {
        if ([cachedHeight floatValue] > height)
            height = [cachedHeight floatValue];
    }
    
    return height;
}

- (void) calculateRowHeightIfNeeded: (NSString*) rowId
{
    if (rowHeightCache[rowId] == nil)
    {
        rowHeightCache[rowId] = [NSNumber numberWithInt:0];
        [rowHeightCacheLeft addObject:rowId];
    }
}

- (UITableView*) tableView
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIActivityIndicatorView*) busyIndicator
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ method in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation:toOrientation duration:duration];
    
    // recalculate UIWebViews dimensions
    
    // cancel previous rotation web view recalculation here: can be achieved by caching UIWebViews
    
    self.tableView.hidden = YES;
    self.busyIndicator.hidden = NO;
    [self.busyIndicator startAnimating];
    
    [rowHeightCache removeAllObjects];
    rowHeightCacheLeft = [NSMutableArray new];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
