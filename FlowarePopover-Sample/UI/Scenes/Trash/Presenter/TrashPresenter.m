//
//  TrashPresenter.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/11/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TrashPresenter.h"

#import "TrashViewProtocols.h"

#import "AbstractData.h"

#import "Notification.h"

@interface TrashPresenter ()
{
    NSMutableArray<AbstractData *> *_trashData;
}

/// @property
///

@end

@implementation TrashPresenter

#pragma mark - Local methods

- (BOOL)addObjectToTrash:(AbstractData *)object
{
    if ([object isKindOfClass:[AbstractData class]])
    {
        return [[self provider] insertObject:object];
    }
    
    return NO;
}

- (BOOL)addObjectToTrash:(AbstractData *)object forRow:(NSInteger)row
{
    @try
    {
        if ([object isKindOfClass:[AbstractData class]])
        {
            return [[self provider] insertObject:object forRow:row];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)addObjectsToTrash:(NSArray<AbstractData *> *)objects
{
    @try
    {
        @autoreleasepool
        {
            NSMutableArray *trashedObjects = [[NSMutableArray alloc] init];
            
            for (AbstractData *obj in objects)
            {
                if ([obj isKindOfClass:[AbstractData class]])
                {
                    [trashedObjects addObject:obj];
                }
                else
                {
                    NSLog(@"%s-[%d] exception - reason = \"Trashed object %@ has different type from standard type!\', [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, obj, [NSThread callStackSymbols]);
                }
            }
            
            if (trashedObjects.count > 0)
            {
                return [[self provider] insertObjects:trashedObjects];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)addObjectsToTrash:(NSArray<AbstractData *> *)objects forRow:(NSInteger)row
{
    @try
    {
        @autoreleasepool
        {
            NSMutableArray *trashedObjects = [[NSMutableArray alloc] init];
            
            for (AbstractData *obj in objects)
            {
                if ([obj isKindOfClass:[AbstractData class]])
                {
                    [trashedObjects addObject:obj];
                }
                else
                {
                    NSLog(@"%s-[%d] exception - reason = \"Trashed object %@ has different type from standard type!\', [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, obj, [NSThread callStackSymbols]);
                }
            }
            
            if (trashedObjects.count > 0)
            {
                return [[self provider] insertObjects:trashedObjects forRow:row];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (void)handleTrashObject:(id)object completion:(void(^)(id trashedObject))complete
{
    BOOL successful = [self addObjectToTrash:(AbstractData *)object];
    
    if (successful && complete)
    {
        complete(object);
    }
}

- (void)handleTrashObject:(id)object forRow:(NSInteger)row completion:(void(^)(id trashedObject))complete
{
    BOOL successful = [self addObjectToTrash:(AbstractData *)object forRow:row];
    
    if (successful && complete)
    {
        complete(object);
    }
}

- (void)handleTrashObjects:(NSArray *)objects completion:(void(^)(NSArray *trashedObjects))complete
{
    BOOL successful = [self addObjectsToTrash:objects];
    
    if (successful && complete)
    {
        complete(objects);
    }
}

- (void)handleTrashObjects:(NSArray *)objects forRow:(NSInteger)row completion:(void(^)(NSArray *trashedObjects))complete
{
    BOOL successful = [self addObjectsToTrash:objects forRow:row];
    
    if (successful && complete)
    {
        complete(objects);
    }
}

- (void)reloadData
{
    if ([self provider].dataSource == nil)
    {
        [[self provider] buildDataSource];
    }
    
    if ([self provider].dataSource.count > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view reloadViewData];
        });
    }
}

#pragma mark - AbstractPresenterProtocols implementation

- (void)fetchData
{
    if (_trashData == nil)
    {
        _trashData = [[NSMutableArray alloc] init];
    }
    
    [[self provider] buildDataSource];
}

- (void)clearData
{
    _trashData = nil;
}

- (NSArray<AbstractData *> *)data
{
    return _trashData;
}

/// Find object that the represented item is mapped to.
///
- (Class)targetObjectClass
{
    return [AbstractData class];
}

/// Drag/Drop handler
///

#pragma mark - TrashPresenterProtocols implementation

- (void)trashObject:(id)object notify:(BOOL)notify
{
    __weak typeof(self) wself = self;
    
    if ([object isKindOfClass:[NSArray class]])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [wself handleTrashObjects:(NSArray *)object completion:^(NSArray *trashedObjects) {
                if (notify)
                {
                    [Notification postNotificationName:dataChangeNotification.trashNotification object:trashedObjects];
                }
                
                [wself reloadData];
            }];
        });
    }
    else if ([object isKindOfClass:[AbstractData class]])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [wself handleTrashObject:object completion:^(id trashedObject) {
                if (notify)
                {
                    [Notification postNotificationName:dataChangeNotification.trashNotification object:trashedObject];
                }
                
                [wself reloadData];
            }];
        });
    }
}

- (void)trashObject:(id)object forRow:(NSInteger)row notify:(BOOL)notify
{
    __weak typeof(self) wself = self;
    
    if ([object isKindOfClass:[NSArray class]])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [wself handleTrashObjects:(NSArray *)object forRow:row completion:^(NSArray *trashedObjects) {
                if (notify)
                {
                    [Notification postNotificationName:dataChangeNotification.trashNotification object:trashedObjects];
                }
                
                [wself reloadData];
            }];
        });
    }
    else if ([object isKindOfClass:[AbstractData class]])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [wself handleTrashObject:object forRow:row completion:^(id trashedObject) {
                if (notify)
                {
                    [Notification postNotificationName:dataChangeNotification.trashNotification object:trashedObject];
                }
                
                [wself reloadData];
            }];
        });
    }
}

#pragma mark - DataProviderProtocols implementation

- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider
{
    return (NSMutableArray<id<ListSupplierProtocol>> *)_trashData;
}

@end
