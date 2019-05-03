//
//  CollectionViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CollectionViewManager;
@class DataProvider;
@protocol ListSupplierProtocol;

@protocol CollectionViewManagerProtocols <NSObject>

@optional
#pragma mark - UI

/**
 * Asks the delegate for the identifier of the specified item at index path.
 */
- (NSUserInterfaceItemIdentifier)collectionViewManager:(CollectionViewManager *)manager makeItemWithIdentifierForItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

/**
 * Tells the delegate that an item view at specified index path will load its data.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager itemView:(NSCollectionViewItem *)itemView willLoadData:(id<ListSupplierProtocol> _Nonnull)data forIndexPath:(NSIndexPath *)indexPath;

/**
 * Asks the delegate to provide the supplementary view at the specified location in a section of the collection view.
 */
- (NSView *)collectionViewManager:(CollectionViewManager *)manager viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind forItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

/**
 * Asks the delegate for size of the specified item at index path.
 */
- (NSSize)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

/**
 * Asks the delegate for the margins to apply to content in the specified section.
 */
- (NSEdgeInsets)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the spacing between successive rows or columns of a section.
 */
- (CGFloat)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the spacing between successive items of a single row or column.
 */
- (CGFloat)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;

/**
 * Asks the delegate for the size of the header view in the specified section.
 */
- (NSSize)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderItem:(id)item inSection:(NSInteger)section;

/**
 * Asks the delegate for the size of the footer view in the specified section.
 */
- (NSSize)collectionViewManager:(CollectionViewManager *)manager layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForFooterItem:(id)item inSection:(NSInteger)section;

#pragma mark - Selection

/**
 * Asks the delegate to approve the pending highlighting of the specified items
 */
- (NSSet<NSIndexPath *> *)collectionViewManager:(CollectionViewManager *)manager shouldChangeItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toHighlightState:(NSCollectionViewItemHighlightState)highlightState;

/**
 * Notifies the delegate that the highlight state of the specified items changed.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager didChangeItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toHighlightState:(NSCollectionViewItemHighlightState)highlightState;

/**
 * Asks the delegate to approve the pending selection of items.
 */
- (NSSet<NSIndexPath *> *)collectionViewManager:(CollectionViewManager *)manager shouldSelectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

/**
 * Asks the delegate object to approve the pending deselection of items.
 */
- (NSSet<NSIndexPath *> *)collectionViewManager:(CollectionViewManager *)manager shouldDeselectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

/**
 * Asks the delegate for the identifier of the specified item at index path.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager didSelectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

/**
 * Notifies the delegate object that one or more items were deselected.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager didDeselectItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

#pragma mark - Drag/Drop

/**
 * Asks the delegate whether a drag operation involving the specified items can begin.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager canDragItems:(NSArray *)draggedItems atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event;

/**
 * Asks the delegate whether a drag operation can place the data on the pasteboard.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager writeItems:(NSArray *)draggedItems atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toPasteboard:(NSPasteboard *)pasteboard;

/**
 * Asks the delegate for creating and returning a drag image to represent the specified items during a drag.
 */
- (NSImage *)collectionViewManager:(CollectionViewManager *)manager draggingImageForItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset;

/**
 * Asks the delegate whether a drop operation is possible at the specified location.
 */
- (NSDragOperation)collectionViewManager:(CollectionViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedIndexPath:(NSIndexPath * __nonnull * __nonnull)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation;

/**
 * Asks the delegate to incorporate the dropped content into the collection view.
 */
- (BOOL)collectionViewManager:(CollectionViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation;

/**
 * Asks the delegate to provide the pasteboard writer for the item at the specified index path.
 */
//- (nullable id<NSPasteboardWriting>)collectionViewManager:(CollectionViewManager *)manager pasteboardWriterForItem:(id)item atIndexPath:(NSIndexPath *)indexPath;

/**
 * Asks the delegate that a drag session is about to begin.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)items atIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

/**
 * Asks the delegate that a drag session ended.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation;

/**
 * Asks the delegate to update the dragging items during a drag operation.
 */
- (void)collectionViewManager:(CollectionViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo;

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
- (instancetype)initWithCollectionView:(NSCollectionView *)collectionView source:(id<CollectionViewManagerProtocols>)source provider:(DataProvider *)provider;

/// OutlineViewManager methods
///
- (void)reloadData;

@end
