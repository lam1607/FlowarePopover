//
//  DataProvider.m
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "DataProvider.h"

#import "ListSupplierProtocol.h"

@interface DataProvider ()
{
    __weak NSMutableArray<id<ListSupplierProtocol>> *_dataSource;
    __weak id _owner;
    
    BOOL _numberOfSectionsUpdated;
    NSInteger _numberOfSections;
}

@end

@implementation DataProvider

#pragma mark - Initialize

- (instancetype)initProviderForOwner:(id _Nonnull)owner
{
    if (self = [super init])
    {
        if ([owner isKindOfClass:[NSObject class]])
        {
            _owner = owner;
            _numberOfSections = 0;
            _numberOfSectionsUpdated = NO;
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
    }
    
    return self;
}

- (void)dealloc
{
    _dataSource = nil;
    _owner = nil;
}

#pragma mark - Getter/Setter

- (NSArray<id<ListSupplierProtocol>> *)dataSource
{
    return _dataSource;
}

- (id)owner
{
    return _owner;
}

#pragma mark - Local methods

- (BOOL)removeObject:(id<ListSupplierProtocol>)object fromArray:(NSMutableArray<id<ListSupplierProtocol>> *)array
{
    BOOL successful = NO;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@", object];
    NSArray *objects = [array filteredArrayUsingPredicate:predicate];
    
    if (objects.count > 0)
    {
        [array removeObject:[objects firstObject]];
        
        successful = YES;
    }
    else
    {
        if ([self isKindOfTreeDataSource])
        {
            for (id<ListSupplierProtocol> item in array)
            {
                if ([item respondsToSelector:@selector(lsp_childs)] && ([item lsp_childs].count > 0))
                {
                    if ([self removeObject:object fromArray:[item lsp_childs]])
                    {
                        successful = YES;
                        
                        return successful;
                    }
                }
            }
        }
    }
    
    return successful;
}

#pragma mark - DataProvider methods

- (void)buildDataSource
{
    if (_owner && [_owner conformsToProtocol:@protocol(DataProviderProtocols)] && [_owner respondsToSelector:@selector(dataSourceForProvider:)])
    {
        _numberOfSectionsUpdated = YES;
        
        [self clearDataSource];
        
        _dataSource = [_owner dataSourceForProvider:self];
    }
    else
    {
        NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
        
        NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)clearDataSource
{
    _dataSource = nil;
}

- (NSInteger)numberOfSections
{
    if (_numberOfSectionsUpdated == NO) return _numberOfSections;
    
    _numberOfSectionsUpdated = NO;
    
    if (_owner && [_owner respondsToSelector:@selector(numberOfSectionsForProvider:)])
    {
        return [_owner numberOfSectionsForProvider:self];
    }
    
    _numberOfSections = (_dataSource.count > 0) ? _dataSource.count : 1;
    
    for (id<ListSupplierProtocol> object in _dataSource)
    {
        if ([(id<ListSupplierProtocol>)object respondsToSelector:@selector(lsp_childs)] && ([(id<ListSupplierProtocol>)object lsp_childs].count > 0))
        {
            break;
        }
        
        if (object == [_dataSource lastObject])
        {
            _numberOfSections = 1;
        }
    }
    
    return _numberOfSections;
}

- (BOOL)isKindOfTreeDataSource
{
    return ([self numberOfSections] > 1);
}

/// Supplier object obtaining
///
- (id<ListSupplierProtocol>)objectForRow:(NSInteger)row
{
    @try
    {
        if (row >= 0 && row < _dataSource.count)
        {
            return [_dataSource objectAtIndex:row];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

- (NSArray<id<ListSupplierProtocol>> *)objectsForRowIndexes:(NSIndexSet *)rowIndexes
{
    @try
    {
        return [_dataSource objectsAtIndexes:rowIndexes];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

- (id<ListSupplierProtocol>)objectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        id<ListSupplierProtocol> item;
        
        if ([self isKindOfTreeDataSource])
        {
            if ([[_dataSource objectAtIndex:indexPath.section] respondsToSelector:@selector(lsp_childs)])
            {
                NSArray *childs = [[_dataSource objectAtIndex:indexPath.section] lsp_childs];
                
                if (indexPath.item >= 0 && indexPath.item < childs.count)
                {
                    item = [childs objectAtIndex:indexPath.item];
                }
            }
        }
        else
        {
            if (indexPath.item >= 0 && indexPath.item < _dataSource.count)
            {
                item = [_dataSource objectAtIndex:indexPath.item];
            }
        }
        
        return item;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

- (NSArray<id<ListSupplierProtocol>> *)objectsForItemAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSMutableArray<id<ListSupplierProtocol>> *objects = [[NSMutableArray alloc] init];
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        id<ListSupplierProtocol> item = [self objectForItemAtIndexPath:indexPath];
        
        if (item)
        {
            [objects addObject:item];
        }
    }
    
    return objects;
}

/// Supplier object handler
///
- (BOOL)insertObject:(id<ListSupplierProtocol>)object
{
    @try
    {
        [_dataSource addObject:object];
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)insertObjects:(NSArray<id<ListSupplierProtocol>> *)objects
{
    @try
    {
        [_dataSource addObjectsFromArray:objects];
        
        return YES;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)insertObject:(id<ListSupplierProtocol>)object forRow:(NSInteger)row
{
    @try
    {
        if (row >= 0 && row <= _dataSource.count)
        {
            if (row == _dataSource.count)
            {
                [_dataSource addObject:object];
            }
            else
            {
                [_dataSource insertObject:object atIndex:row];
            }
            
            return YES;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)insertObjects:(NSArray<id<ListSupplierProtocol>> *)objects forRow:(NSInteger)row
{
    @try
    {
        if (row >= 0 && row <= _dataSource.count)
        {
            NSArray<id<ListSupplierProtocol>> *reverseObjects = [[objects reverseObjectEnumerator] allObjects];
            BOOL successful = NO;
            
            for (id<ListSupplierProtocol> object in reverseObjects)
            {
                successful = [self insertObject:object forRow:row];
                
                if (successful)
                {
                    ++row;
                }
            }
            
            return YES;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObject:(id<ListSupplierProtocol>)object
{
    @try
    {
        return [self removeObject:object fromArray:_dataSource];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObjects:(NSArray<id<ListSupplierProtocol>> *)objects
{
    @try
    {
        BOOL successful;
        
        for (id<ListSupplierProtocol> object in objects)
        {
            successful = [self removeObject:object fromArray:_dataSource];
        }
        
        return successful;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObjectForRow:(NSInteger)row
{
    @try
    {
        id<ListSupplierProtocol> object = [self objectForRow:row];
        
        return [self removeObject:object];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObjectsForRowIndexes:(NSIndexSet *)rowIndexes
{
    @try
    {
        NSArray<id<ListSupplierProtocol>> *objects = [self objectsForRowIndexes:rowIndexes];
        
        return [self removeObjects:objects];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObjectAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        id<ListSupplierProtocol> object = [self objectForItemAtIndexPath:indexPath];
        
        return [self removeObject:object];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

- (BOOL)removeObjectsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        NSArray<id<ListSupplierProtocol>> *objects = [self objectsForItemAtIndexPaths:indexPaths];
        
        return [self removeObjects:objects];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

@end
