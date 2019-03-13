//
//  FilmsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FilmsPresenter.h"

#import "FilmsViewProtocols.h"
#import "FilmRepositoryProtocols.h"

#import "Film.h"

@interface FilmsPresenter ()
{
    NSArray<Film *> *_films;
}

/// @property
///

@end

@implementation FilmsPresenter

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData
{
    if ([self.repository conformsToProtocol:@protocol(FilmRepositoryProtocols)])
    {
        __weak typeof(self) wself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            self->_films = [(id<FilmRepositoryProtocols>)self.repository fetchFilms];
            
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
    _films = nil;
}

- (NSArray<Film *> *)data
{
    return _films;
}

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass
{
    return [Film class];
}

#pragma mark - DataProviderProtocols implementation

- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)_films;
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
