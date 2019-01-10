//
//  CollectionViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CollectionViewManager;
@protocol CollectionViewRowProtocols;

@protocol CollectionViewManagerProtocols <NSObject>

@optional
- (NSSize)collectionViewManager:(CollectionViewManager *)manager sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionViewManager:(CollectionViewManager *)manager didSelectItems:(NSArray<id<CollectionViewRowProtocols>> *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

@end

@interface CollectionViewManager : NSObject <NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout>

/// Protocols
///
@property (nonatomic, weak) id<CollectionViewManagerProtocols> protocols;

/// @property
///
@property (nonatomic, weak, readonly) NSCollectionView *collectionView;

/// Initializes
///
- (instancetype)initWithCollectionView:(NSCollectionView *)collectionView;

/// OutlineViewManager methods
///
- (void)addRow:(id<CollectionViewRowProtocols>)row;
- (void)addRow:(id<CollectionViewRowProtocols>)row atIndex:(NSInteger)index;
- (void)removeRow:(id<CollectionViewRowProtocols>)row;
- (void)removeRowAtIndex:(NSInteger)index;

- (void)reloadData;

@end
