//
//  ComicsPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "ComicsPresenter.h"

#import "ComicsViewProtocols.h"
#import "ComicRepositoryProtocols.h"

#import "Comic.h"

@interface ComicsPresenter ()
{
    NSMutableArray<Comic *> *_comics;
}

/// @property
///

@end

@implementation ComicsPresenter

#pragma mark - Local methods

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData
{
    if ([self.repository conformsToProtocol:@protocol(ComicRepositoryProtocols)])
    {
        _comics = [[NSMutableArray alloc] init];
        
        __block typeof(self) wself = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSArray<Comic *> *comics = [(id<ComicRepositoryProtocols>)self.repository fetchComics];
            
            [comics enumerateObjectsUsingBlock:^(Comic *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx % 5 == 0)
                {
                    obj.subItems = [[NSMutableArray alloc] init];
                    [self->_comics addObject:obj];
                }
                else
                {
                    Comic *comic = [self->_comics lastObject];
                    
                    obj.parentItem = comic;
                    
                    [comic.subItems addObject:obj];
                }
            }];
            
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
    _comics = nil;
}

- (NSArray<Comic *> *)data
{
    return _comics;
}

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass
{
    return [Comic class];
}

/// Drag/Drop handler
///
- (void)dropObject:(id)object forRow:(NSInteger)row target:(id<ListSupplierProtocol>)target completion:(void(^)(BOOL finished))complete
{
}

#pragma mark - DataProviderProtocols implementation

- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)_comics;
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
