//
//  NewsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsPresenter.h"

#import "NewsRepositoryProtocols.h"

#import "News.h"

@interface NewsPresenter ()
{
    NSArray<News *> *_news;
}

/// @property
///

@end

@implementation NewsPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData
{
    if ([self.repository conformsToProtocol:@protocol(NewsRepositoryProtocols)])
    {
        __block typeof(self) wself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self->_news = [(id<NewsRepositoryProtocols>)self.repository fetchNews];
            
            [[wself provider] buildDataSource];
            
            if ([wself provider].dataSource.count > 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.view reloadViewData];
                });
            }
        });
    }
}

- (void)clearData
{
    _news = nil;
}

- (NSArray<News *> *)data
{
    return _news;
}

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass
{
    return [News class];
}

#pragma mark - DataProviderProtocols implementation

- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)_news;
}

#pragma mark - NotificationObserversProtocols implementation

- (void)notificationObservers_objectInserted:(NSNotification *)notification
{
    DLog(@"notification = %@", notification);
    
    [self handleNotificationObserversObjectInserted:notification.object];
}

- (void)notificationObservers_objectUpdated:(NSNotification *)notification
{
    DLog(@"notification = %@", notification);
    
    [self handleNotificationObserversObjectUpdated:notification.object];
}

- (void)notificationObservers_objectDeleted:(NSNotification *)notification
{
    DLog(@"notification = %@", notification);
    
    [self handleNotificationObserversObjectDeleted:notification.object];
}

- (void)notificationObservers_objectTrashed:(NSNotification *)notification
{
    DLog(@"notification = %@", notification);
    
    [self handleNotificationObserversObjectTrashed:notification.object];
}

@end
