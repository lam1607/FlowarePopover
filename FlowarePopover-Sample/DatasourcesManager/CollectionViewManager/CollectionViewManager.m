//
//  CollectionViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "CollectionViewManager.h"

#import "CollectionViewRowProtocols.h"

@interface CollectionViewManager () {
    NSMutableArray<id<CollectionViewRowProtocols>> *_rows;
    NSMutableArray<NSString *> *_registeredRowIdentifiers;
    NSCache *_cachedItemSizes;
}

/// @property
///
@property (nonatomic, weak, readwrite) NSCollectionView *collectionView;

@end

@implementation CollectionViewManager

#pragma mark - Initialize

- (instancetype)initWithCollectionView:(NSCollectionView *)collectionView {
    if (self = [super init]) {
        _rows = [[NSMutableArray alloc] init];
        _registeredRowIdentifiers = [[NSMutableArray alloc] init];
        _cachedItemSizes = [[NSCache alloc] init];
        
        _collectionView = collectionView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (NSCollectionView *)collectionView {
    return _collectionView;
}

#pragma mark - Local methods

- (void)registerForRow:(id<CollectionViewRowProtocols>)row atIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = row.reuseIdentifier;
    
    if ([_registeredRowIdentifiers containsObject:reuseIdentifier] == NO) {
        [_registeredRowIdentifiers addObject:reuseIdentifier];
    }
    
    if ([self.collectionView makeItemWithIdentifier:reuseIdentifier forIndexPath:indexPath] == nil) {
        [self.collectionView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(row.cellType) bundle:nil] forItemWithIdentifier:reuseIdentifier];
    }
}

#pragma mark - OutlineViewManager methods

- (void)addRow:(id<CollectionViewRowProtocols>)row {
    if ([_rows containsObject:row] == NO) {
        [_rows addObject:row];
    }
}

- (void)addRow:(id<CollectionViewRowProtocols>)row atIndex:(NSInteger)index {
    if ([_rows containsObject:row] == NO) {
        [_rows insertObject:row atIndex:index];
    }
}

- (void)removeRow:(id<CollectionViewRowProtocols>)row {
    if ([_rows containsObject:row] == NO) {
        [_rows removeObject:row];
    }
}

- (void)removeRowAtIndex:(NSInteger)index {
    if ((index != NSNotFound) && (index >= 0 && index < _rows.count)) {
        [_rows removeObjectAtIndex:index];
    }
}

- (void)reloadData {
    [_cachedItemSizes removeAllObjects];
    
    [self.collectionView reloadData];
}

#pragma mark - NSCollectionViewDataSource, NSCollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _rows.count;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_rows.count > 0) {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:sizeForItemAtIndexPath:)]) {
            if ([_cachedItemSizes objectForKey:@(indexPath.item)] == nil) {
                NSSize itemSize = [self.protocols collectionViewManager:self sizeForItemAtIndexPath:indexPath];
                
                [_cachedItemSizes setObject:[NSValue valueWithSize:itemSize] forKey:@(indexPath.item)];
            }
            
            return [[_cachedItemSizes objectForKey:@(indexPath.item)] sizeValue];
        }
    }
    
    id<CollectionViewRowProtocols> rowView = [_rows objectAtIndex:indexPath.item];
    
    return rowView.estimatedItemSize;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    id<CollectionViewRowProtocols> rowView = [_rows objectAtIndex:indexPath.item];
    
    [self registerForRow:rowView atIndexPath:indexPath];
    
    NSCollectionViewItem *viewItem = [collectionView makeItemWithIdentifier:rowView.reuseIdentifier forIndexPath:indexPath];
    
    if ([viewItem conformsToProtocol:@protocol(ViewRowProtocols)] && [rowView respondsToSelector:@selector(configure:atIndex:)]) {
        [rowView configure:(id<ViewRowProtocols>)viewItem atIndex:indexPath.item];
    }
    
    return viewItem;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:didSelectItems:atIndexPaths:)]) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *indexPath in indexPaths) {
            id<CollectionViewRowProtocols> rowView = [_rows objectAtIndex:indexPath.item];
            
            [items addObject:rowView];
        }
        
        [self.protocols collectionViewManager:self didSelectItems:items atIndexPaths:indexPaths];
    }
}

@end
