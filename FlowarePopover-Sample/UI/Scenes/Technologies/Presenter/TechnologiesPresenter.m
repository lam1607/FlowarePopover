//
//  TechnologiesPresenter.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologiesPresenter.h"

#import "TechnologiesViewProtocols.h"
#import "TechnologyRepositoryProtocols.h"

#import "Technology.h"

@interface TechnologiesPresenter ()
{
    NSArray<Technology *> *_technologies;
}

/// @property
///

@end

@implementation TechnologiesPresenter

#pragma mark - Local methods

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData
{
    if ([self.repository conformsToProtocol:@protocol(TechnologyRepositoryProtocols)])
    {
        __block typeof(self) wself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self->_technologies = [(id<TechnologyRepositoryProtocols>)self.repository fetchTechnologies];
            
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
    _technologies = nil;
}

- (NSArray<Technology *> *)data
{
    return _technologies;
}

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass
{
    return [Technology class];
}

#pragma mark - DataProviderProtocols implementation

- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)_technologies;
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
