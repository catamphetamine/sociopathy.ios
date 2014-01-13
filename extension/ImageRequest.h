//
//  ImageRequest.h
//  Sociopathy
//
//  Created by Admin on 08.01.14.
//  Copyright (c) 2014 kuchumovn. All rights reserved.
//

// http://stackoverflow.com/questions/15799432/poor-uicollectionview-scrolling-performance-with-uiimage

// can be improved with collectionView:didEndDisplayingCell:forItemAtIndexPath:
// and tableView:didEndDisplayingCell:forRowAtIndexPath:

// This class keeps track of in-flight instances, creating only one NSURLConnection for
// multiple matching requests (requests with matching URLs).  It also uses NSCache to cache
// retrieved images.  Set the cache count limit with the macro in this file.

#define kIMAGE_REQUEST_CACHE_LIMIT  100
typedef void (^CompletionBlock) (UIImage *, NSError *);

@interface ImageRequest : NSMutableURLRequest

- (instancetype) initWithURL: (NSURL*) URL
                   tableView: (UITableView*) tableView
                   indexPath: (NSIndexPath*) indexPath;
- (UIImage *)cachedResult;
- (void)startWithCompletion:(CompletionBlock)completion;
- (BOOL) available;
- (void) load;

@end