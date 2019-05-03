//
//  AbstractPresenter.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractPresenter.h"

#import "AbstractData.h"

@interface AbstractPresenter ()
{
    NotificationService *_notification;
    DataProvider *_provider;
    NSImage *_image;
}

/// @property
///

@end

@implementation AbstractPresenter

@synthesize view;
@synthesize repository;

#pragma mark - Initialize

- (instancetype)init
{
    if (self = [super init])
    {
        _notification = [[NotificationService alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_notification removeNotificationObserver:self keyPath:self.description];
    _notification = nil;
}

#pragma mark - AbstractPresenterProtocols implementation

- (void)attachView:(id<AbstractViewProtocols>)view
{
    if ([view conformsToProtocol:@protocol(AbstractViewProtocols)])
    {
        self.view = view;
    }
    else
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)attachView:(id<AbstractViewProtocols>)view repository:(id<AbstractRepositoryProtocols>)repository
{
    if ([view conformsToProtocol:@protocol(AbstractViewProtocols)] && [repository conformsToProtocol:@protocol(AbstractRepositoryProtocols)])
    {
        self.view = view;
        self.repository = repository;
    }
    else
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)detachView
{
    self.view = nil;
}

- (void)detachViewRepository
{
    self.view = nil;
    self.repository = nil;
}

/// Methods
///
- (void)registerNotificationObservers
{
    [_notification registerNotificationObserver:self keyPath:self.description];
}

- (void)setupProvider
{
    _provider = [[DataProvider alloc] initProviderForOwner:self];
}

- (DataProvider *)provider
{
    if (_provider == nil)
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
    
    return _provider;
}

- (NSImage *)fetchedImage
{
    return _image;
}

- (void)fetchImageFromData:(AbstractData *)obj
{
    __block AbstractData *object = obj;
    __block typeof(_image) wimage = _image;
    
    __weak typeof(self) wself = self;
    
    if ([obj getImageForURL:obj.imageUrl] == nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [wself.repository fetchImageFromUrl:[NSURL URLWithString:object.imageUrl] completion:^(NSImage *image) {
                wimage = image;
                
                [object setImage:image forURL:object.imageUrl];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wself.view updateViewImage];
                });
            }];
        });
    }
    else
    {
        _image = [obj getImageForURL:obj.imageUrl];
        [self.view updateViewImage];
    }
}

/// Find object that the represented item is mapped to.
///
- (id<ListSupplierProtocol>)findObjectForRepresentedItem:(AbstractData *)representedItem
{
    id<ListSupplierProtocol> object;
    
    @try
    {
        if ([self respondsToSelector:@selector(targetObjectClass)])
        {
            if ([representedItem isKindOfClass:[self targetObjectClass]])
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.imageUrl MATCHES[c] %@", representedItem.imageUrl];
                NSArray *objects = [[self provider].dataSource filteredArrayUsingPredicate:predicate];
                
                if (objects.count > 0)
                {
                    object = [objects firstObject];
                }
                else
                {
                    if ([[self provider] isKindOfTreeDataSource])
                    {
                        for (id<ListSupplierProtocol> item in [self provider].dataSource)
                        {
                            if ([(id<ListSupplierProtocol>)item respondsToSelector:@selector(lsp_childs)])
                            {
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.imageUrl MATCHES[c] %@", representedItem.imageUrl];
                                NSArray *objects = [[(id<ListSupplierProtocol>)item lsp_childs] filteredArrayUsingPredicate:predicate];
                                
                                if (objects.count > 0)
                                {
                                    object = [objects firstObject];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return object;
}

- (NSArray<id<ListSupplierProtocol>> *)findObjectsForRepresentedItems:(NSArray *)items
{
    @autoreleasepool
    {
        NSMutableArray *objects = [[NSMutableArray alloc] init];
        
        if ([self respondsToSelector:@selector(targetObjectClass)])
        {
            for (id item in items)
            {
                if ([item isKindOfClass:[self targetObjectClass]])
                {
                    id<ListSupplierProtocol> object = [self findObjectForRepresentedItem:(AbstractData *)item];
                    
                    if (object)
                    {
                        [objects addObject:object];
                    }
                }
            }
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
        
        return objects;
    }
}

- (NSArray<id<ListSupplierProtocol>> *)findObjectsForItem:(id)item
{
    if ([item isKindOfClass:[AbstractData class]])
    {
        if ([self respondsToSelector:@selector(targetObjectClass)])
        {
            if ([item isKindOfClass:[self targetObjectClass]])
            {
                id<ListSupplierProtocol> object = [self findObjectForRepresentedItem:(AbstractData *)item];
                
                if (object)
                {
                    return @[object];
                }
            }
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
    }
    else if ([item isKindOfClass:[NSArray class]])
    {
        NSArray *objects = [self findObjectsForRepresentedItems:(NSArray *)item];
        
        return objects;
    }
    
    return nil;
}

/// Drag/Drop handler
///
- (BOOL)couldDropObject:(id)object
{
    if ([object isKindOfClass:[AbstractData class]])
    {
        if ([self respondsToSelector:@selector(targetObjectClass)])
        {
            if ([object isKindOfClass:[self targetObjectClass]])
            {
                return YES;
            }
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        return [self couldDropObjects:(NSArray *)object];
    }
    
    return NO;
}

- (BOOL)couldDropObjects:(NSArray *)objects
{
    for (id object in objects)
    {
        if ([object isKindOfClass:[self targetObjectClass]] == NO)
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)dropObject:(id)object forRow:(NSInteger)row target:(id<ListSupplierProtocol>)target completion:(void(^)(BOOL finished))complete
{
    if ([[self provider] isKindOfTreeDataSource])
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, @"This function is only applied for normal list datasource", [NSThread callStackSymbols]);
        return;
    }
    
    __block NSInteger brow = row;
    __block typeof(target) btarget = target;
    
    __weak typeof(self) wself = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL isOverItemDrop = (btarget != nil) && (brow == -1);
        
        if (isOverItemDrop)
        {
            brow = [[wself provider].dataSource indexOfObject:btarget];
        }
        else
        {
            btarget = [[wself provider].dataSource objectAtIndex:((brow >= [self provider].dataSource.count) ? (brow - 1) : brow)];
        }
        
        if (brow == ([wself provider].dataSource.count - 1))
        {
            --brow;
        }
        
        NSArray *objects = [wself findObjectsForItem:object];
        BOOL successful = NO;
        
        if (objects.count > 0)
        {
            BOOL dropAtLast = brow > [[wself provider].dataSource indexOfObject:btarget];
            
            successful = [[self provider] removeObjects:objects];
            
            if (successful)
            {
                NSInteger targetRow = [[wself provider].dataSource indexOfObject:btarget];
                brow = dropAtLast ? (targetRow + 1) : targetRow;
                
                successful = [[wself provider] insertObjects:objects forRow:brow];
                
                if (successful)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [wself.view reloadViewData];
                        
                        if (complete)
                        {
                            complete(successful);
                        }
                    });
                    
                    return;
                }
            }
        }
        
        if (complete)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(successful);
            });
        }
    });
}

/// Notification observers handler
///
- (void)handleNotificationObserversObjectInserted:(id)object
{
}

- (void)handleNotificationObserversObjectUpdated:(id)object
{
    NSArray *objects = [self findObjectsForItem:object];
    
    if (objects.count > 0)
    {
    }
}

- (void)handleNotificationObserversObjectDeleted:(id)object
{
    NSArray *objects = [self findObjectsForItem:object];
    
    if (objects.count > 0)
    {
    }
}

- (void)handleNotificationObserversObjectTrashed:(id)object
{
    NSArray *objects = [self findObjectsForItem:object];
    
    if (objects.count > 0)
    {
        BOOL successful = [[self provider] removeObjects:objects];
        
        if (successful)
        {
            [self.view reloadViewData];
        }
    }
}

@end
