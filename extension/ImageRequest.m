//
//  ImageRequest.m
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

#import "ImageRequest.h"

static NSMutableDictionary *_inflight;
static NSCache *_imageCache;

@implementation ImageRequest
{
    UITableView* tableView;
    NSIndexPath* indexPath;
}

- (instancetype) initWithURL: (NSURL*) URL
                   tableView: (UITableView*) tableView
                   indexPath: (NSIndexPath*) indexPath
{
    if (self = [super initWithURL:URL])
    {
        self->tableView = tableView;
        self->indexPath = indexPath;
    }
    return self;
}

- (NSMutableDictionary*) inflight
{
    if (!_inflight)
    {
        _inflight = [NSMutableDictionary dictionary];
    }
    return _inflight;
}

- (NSCache*) imageCache
{
    if (!_imageCache)
    {
        _imageCache = [[NSCache alloc] init];
        _imageCache.countLimit = kIMAGE_REQUEST_CACHE_LIMIT;
    }
    return _imageCache;
}

- (UIImage*) cachedResult
{
    return [self.imageCache objectForKey:self];
}

- (BOOL) available
{
    return [self cachedResult] != nil;
}

- (void) load
{
    [self startWithCompletion:^(UIImage* image, NSError* error)
    {
        if (image && [[tableView indexPathsForVisibleRows] containsObject:indexPath])
        {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
}

- (void) startWithCompletion: (CompletionBlock) completion
{
    UIImage* image = [self cachedResult];
    if (image)
        return completion(image, nil);
    
    NSMutableArray* inflightCompletionBlocks = [self.inflight objectForKey:self];
    if (inflightCompletionBlocks)
    {
        // a matching request is in flight, keep the completion block to run when we're finished
        [inflightCompletionBlocks addObject:completion];
    }
    else
    {
        [self.inflight setObject:[NSMutableArray arrayWithObject:completion] forKey:self];
        
        [NSURLConnection sendAsynchronousRequest:self queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error)
        {
            if (error)
            {
                [self.inflight removeObjectForKey:self];
                return completion(nil, error);
            }
            
            // build an image, cache the result and run completion blocks for this request
            UIImage* image = [UIImage imageWithData:data];
            [self.imageCache setObject:image forKey:self];
            
            NSMutableArray* completionBlocks = [self.inflight objectForKey:self];
            [self.inflight removeObjectForKey:self];
            
            for (CompletionBlock action in completionBlocks)
            {
                action(image, nil);
            }
        }];
    }
}
@end
