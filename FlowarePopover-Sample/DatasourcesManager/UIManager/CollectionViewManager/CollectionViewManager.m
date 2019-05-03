//
//  CollectionViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "CollectionViewManager.h"

#import "ItemCellViewProtocols.h"

#import "DataProvider.h"
#import "ListSupplierProtocol.h"

@interface CollectionViewManager ()
{
    __weak NSCollectionView *_collectionView;
    __weak DataProvider *_provider;
    
    NSMutableArray<NSUserInterfaceItemIdentifier> *_registeredIdentifiers;
    NSCache *_cachedItemSizes;
}

/// @property
///

@end

@implementation CollectionViewManager

#pragma mark - Initialize

- (instancetype)initWithCollectionView:(NSCollectionView *)collectionView source:(id<CollectionViewManagerProtocols>)source provider:(DataProvider *)provider
{
    if (self = [super init])
    {
        if ([collectionView isKindOfClass:[NSCollectionView class]] && [source conformsToProtocol:@protocol(CollectionViewManagerProtocols)] && [provider isKindOfClass:[DataProvider class]])
        {
            _provider = provider;
            _protocols = source;
            _registeredIdentifiers = [[NSMutableArray alloc] init];
            _cachedItemSizes = [[NSCache alloc] init];
            
            _collectionView = collectionView;
            _collectionView.delegate = self;
            _collectionView.dataSource = self;
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
    _collectionView = nil;
    _provider = nil;
    
    [_registeredIdentifiers removeAllObjects];
    _registeredIdentifiers = nil;
    
    [_cachedItemSizes removeAllObjects];
    _cachedItemSizes = nil;
}

#pragma mark - Getter/Setter

- (NSCollectionView *)collectionView
{
    return _collectionView;
}

#pragma mark - Local methods

- (void)registerForRowItemWithIdentifier:(NSUserInterfaceItemIdentifier)identifier
{
    @try
    {
        if (![_registeredIdentifiers containsObject:identifier])
        {
            [_registeredIdentifiers addObject:identifier];
            
            [_collectionView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(NSClassFromString(identifier)) bundle:nil] forItemWithIdentifier:identifier];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

#pragma mark - OutlineViewManager methods

- (void)reloadData
{
    [_cachedItemSizes removeAllObjects];
    
    [self.collectionView reloadData];
}

#pragma mark - NSCollectionViewDataSource

/**
 * Asks the data source for the number of items in the specified section.
 */
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    @try
    {
        if ([_provider numberOfSections] == 1)
        {
            return _provider.dataSource.count;
        }
        
        if ([[_provider.dataSource objectAtIndex:section] respondsToSelector:@selector(lsp_childs)])
        {
            return [[_provider.dataSource objectAtIndex:section] lsp_childs].count;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return 0;
}

/**
 * Asks the data source to provide an NSCollectionViewItem for the specified represented object.
 
 Your implementation of this method is responsible for creating, configuring, and returning the appropriate item for the given represented object.  You do this by sending -makeItemWithIdentifier:forIndexPath: method to the collection view and passing the identifier that corresponds to the item type you want.  Upon receiving the item, you should set any properties that correspond to the data of the corresponding model object, perform any additional needed configuration, and return the item.
 
 You do not need to set the location of the item's view inside the collection view’s bounds. The collection view sets the location of each item automatically using the layout attributes provided by its layout object.
 
 This method must always return a valid item instance.
 */
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        id<ListSupplierProtocol> object = [_provider objectForItemAtIndexPath:indexPath];
        NSUserInterfaceItemIdentifier identifier;
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:makeItemWithIdentifierForItem:atIndexPath:)])
        {
            identifier = [self.protocols collectionViewManager:self makeItemWithIdentifierForItem:object atIndexPath:indexPath];
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
        
        [self registerForRowItemWithIdentifier:identifier];
        
        NSCollectionViewItem *itemView = [collectionView makeItemWithIdentifier:identifier forIndexPath:indexPath];
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:itemView:willLoadData:forIndexPath:)])
        {
            [self.protocols collectionViewManager:self itemView:itemView willLoadData:object forIndexPath:indexPath];
        }
        else if ([itemView conformsToProtocol:@protocol(ItemCellViewProtocols)] && [(id<ItemCellViewProtocols>)itemView respondsToSelector:@selector(itemCellView:updateWithData:atIndexPath:)])
        {
            [(id<ItemCellViewProtocols>)itemView itemCellView:(id<ItemCellViewProtocols>)itemView updateWithData:object atIndexPath:indexPath];
        }
        
        return itemView;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

/**
 * Asks the data source for the number of sections in the collection view.
 */
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return [_provider numberOfSections];
}

/**
 * Asks the data source to provide a view for the specified supplementary element.
 
 Your implementation of this method is responsible for creating, configuring, and returning an appropriate view.  You do this by sending -makeSupplementaryViewOfKind:withIdentifier:forIndexPath: to the collection view and passing the identifier that corresponds to the supplementary view type you want.  Upon receiving the view, you should set any desired appearance properties, perform any additional needed configuration, and return the item.
 
 You do not need to set the location of the view inside the collection view’s bounds. The collection view sets the location of each supplementary view automatically using the layout attributes provided by its layout object.
 
 This method must always return a valid view.
 */
- (NSView *)collectionView:(NSCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSCollectionViewSupplementaryElementKind)kind atIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        if ([_provider isKindOfTreeDataSource])
        {
            if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:viewForSupplementaryElementOfKind:forItem:atIndexPath:)])
            {
                return [self.protocols collectionViewManager:self viewForSupplementaryElementOfKind:kind forItem:[_provider objectForRow:indexPath.section] atIndexPath:indexPath];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

#pragma mark - NSCollectionViewDelegateFlowLayout

/**
 * Asks the delegate for the size of the specified item.
 */
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        id<ListSupplierProtocol> object = [_provider objectForItemAtIndexPath:indexPath];
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:sizeForItem:atIndexPath:)])
        {
            NSValue *itemValue = [NSValue valueWithNonretainedObject:object];
            
            if ([_cachedItemSizes objectForKey:itemValue] == nil)
            {
                NSSize itemSize = [self.protocols collectionViewManager:self layout:collectionViewLayout sizeForItem:object atIndexPath:indexPath];
                
                [_cachedItemSizes setObject:[NSValue valueWithSize:itemSize] forKey:itemValue];
            }
            
            return [[_cachedItemSizes objectForKey:itemValue] sizeValue];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NSZeroSize;
}

/**
 * Asks the delegate for the margins to apply to content in the specified section.
 */
- (NSEdgeInsets)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:insetForSectionAtIndex:)])
    {
        return [self.protocols collectionViewManager:self layout:collectionViewLayout insetForSectionAtIndex:section];
    }
    
    return NSEdgeInsetsZero;
}

/**
 * Asks the delegate for the spacing between successive rows or columns of a section.
 */
- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:minimumLineSpacingForSectionAtIndex:)])
    {
        return [self.protocols collectionViewManager:self layout:collectionViewLayout minimumLineSpacingForSectionAtIndex:section];
    }
    
    return 0.0;
}

/**
 * Asks the delegate for the spacing between successive items of a single row or column.
 */
- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:minimumInteritemSpacingForSectionAtIndex:)])
    {
        return [self.protocols collectionViewManager:self layout:collectionViewLayout minimumInteritemSpacingForSectionAtIndex:section];
    }
    
    return 0.0;
}

/**
 * Asks the delegate for the size of the header view in the specified section.
 */
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([_provider isKindOfTreeDataSource])
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:referenceSizeForHeaderItem:inSection:)])
        {
            return [self.protocols collectionViewManager:self layout:collectionViewLayout referenceSizeForHeaderItem:[_provider objectForRow:section] inSection:section];
        }
    }
    
    return NSZeroSize;
}

/**
 * Asks the delegate for the size of the footer view in the specified section.
 */
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([_provider isKindOfTreeDataSource])
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:layout:referenceSizeForFooterItem:inSection:)])
        {
            return [self.protocols collectionViewManager:self layout:collectionViewLayout referenceSizeForFooterItem:[_provider objectForRow:section] inSection:section];
        }
    }
    
    return NSZeroSize;
}

#pragma mark - NSCollectionViewDelegate Selection

/**
 * Asks the delegate to approve the pending highlighting of the specified items
 */
- (NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldChangeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toHighlightState:(NSCollectionViewItemHighlightState)highlightState
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:shouldChangeItems:atIndexPaths:toHighlightState:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            return [self.protocols collectionViewManager:self shouldChangeItems:items atIndexPaths:indexPaths toHighlightState:highlightState];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return indexPaths;
}

/**
 * Sent during interactive selection or dragging, to inform the delegate that the CollectionView has changed the "highlightState" property of the items at the specified "indexPaths" to the specified "highlightState".
 */
- (void)collectionView:(NSCollectionView *)collectionView didChangeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toHighlightState:(NSCollectionViewItemHighlightState)highlightState
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:didChangeItems:atIndexPaths:toHighlightState:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            [self.protocols collectionViewManager:self didChangeItems:items atIndexPaths:indexPaths toHighlightState:highlightState];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Sent during interactive selection, to inform the delegate that the CollectionView would like to select the items at the specified "indexPaths".  In addition to optionally reacting to the proposed change, you can approve it (by returning "indexPaths" as-is), or selectively refuse some or all of the proposed selection changes (by returning a modified autoreleased mutableCopy of indexPaths, or an empty indexPaths instance).
 */
- (NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:shouldSelectItems:atIndexPaths:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            return [self.protocols collectionViewManager:self shouldSelectItems:items atIndexPaths:indexPaths];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return indexPaths;
}

/**
 * Sent during interactive selection, to inform the delegate that the CollectionView would like to de-select the items at the specified "indexPaths".  In addition to optionally reacting to the proposed change, you can approve it (by returning "indexPaths" as-is), or selectively refuse some or all of the proposed selection changes (by returning a modified autoreleased mutableCopy of indexPaths, or an empty indexPaths instance).
 */
- (NSSet<NSIndexPath *> *)collectionView:(NSCollectionView *)collectionView shouldDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:shouldDeselectItems:atIndexPaths:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            return [self.protocols collectionViewManager:self shouldDeselectItems:items atIndexPaths:indexPaths];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return indexPaths;
}

/**
 * Sent at the end of interactive selection, to inform the delegate that the CollectionView has selected the items at the specified "indexPaths".
 */
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:didSelectItems:atIndexPaths:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            [self.protocols collectionViewManager:self didSelectItems:items atIndexPaths:indexPaths];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Sent at the end of interactive selection, to inform the delegate that the CollectionView has de-selected the items at the specified "indexPaths".
 */
- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:didDeselectItems:atIndexPaths:)])
        {
            NSArray *items = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            [self.protocols collectionViewManager:self didDeselectItems:items atIndexPaths:indexPaths];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

#pragma mark - NSCollectionViewDelegate Drag/Drop

/**
 * The return value indicates whether the collection view can attempt to initiate a drag for the given event and items. If the delegate does not implement this method, the collection view will act as if it returned YES.
 */
- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:canDragItems:atIndexPaths:withEvent:)])
    {
        NSArray *draggedItems = [_provider objectsForItemAtIndexPaths:indexPaths];
        
        return [self.protocols collectionViewManager:self canDragItems:draggedItems atIndexPaths:indexPaths withEvent:event];
    }
    
    return NO;
}

/**
 * This method is called after it has been determined that a drag should begin, but before the drag has been started. To refuse the drag, return NO. To start the drag, declare the pasteboard types that you support with -[NSPasteboard declareTypes:owner:], place your data for the items at the given index paths on the pasteboard, and return YES from the method. The drag image and other drag related information will be set up and provided by the view once this call returns YES. You need to implement this method, or -collectionView:pasteboardWriterForItemAtIndexPath: (its more modern counterpart), for your collection view to be a drag source.  If you want to put file promises on the pasteboard, using the modern NSFilePromiseProvider API added in macOS 10.12, implement -collectionView:pasteboardWriterForItemAtIndexPath: instead of this method, and have it return an NSFilePromiseProvider.
 */
- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toPasteboard:(NSPasteboard *)pasteboard
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:writeItems:atIndexPaths:toPasteboard:)])
    {
        NSArray *writeItems = [_provider objectsForItemAtIndexPaths:indexPaths];
        
        return [self.protocols collectionViewManager:self writeItems:writeItems atIndexPaths:indexPaths toPasteboard:pasteboard];
    }
    
    return NO;
}

/**
 * Allows the delegate to construct a custom dragging image for the items being dragged. 'indexPaths' contains the (section,item) identification of the items being dragged. 'event' is a reference to the  mouse down event that began the drag. 'dragImageOffset' is an in/out parameter. This method will be called with dragImageOffset set to NSZeroPoint, but it can be modified to re-position the returned image. A dragImageOffset of NSZeroPoint will cause the image to be centered under the mouse. You can safely call -[NSCollectionView draggingImageForItemsAtIndexPaths:withEvent:offset:] from within this method. You do not need to implement this method for your collection view to be a drag source.
 */
- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:draggingImageForItems:atIndexPaths:withEvent:offset:)])
    {
        NSArray *draggedItems = [_provider objectsForItemAtIndexPaths:indexPaths];
        
        return [self.protocols collectionViewManager:self draggingImageForItems:draggedItems atIndexPaths:indexPaths withEvent:event offset:dragImageOffset];
    }
    
    return nil;
}

/**
 * This method is used by the collection view to determine a valid drop target. Based on the mouse position, the collection view will suggest a proposed (section,item) index path and drop operation. These values are in/out parameters and can be changed by the delegate to retarget the drop operation. The collection view will propose NSCollectionViewDropOn when the dragging location is closer to the middle of the item than either of its edges. Otherwise, it will propose NSCollectionViewDropBefore. You may override this default behavior by changing proposedDropOperation or proposedDropIndexPath. This method must return a value that indicates which dragging operation the data source will perform. It must return something other than NSDragOperationNone to accept the drop.
 
 Note: to receive drag messages, you must first send -registerForDraggedTypes: to the collection view with the drag types you want to support (typically this is done in -awakeFromNib). You must implement this method for your collection view to be a drag destination.
 
 Multi-image drag and drop: You can set draggingFormation, animatesToDestination, numberOfValidItemsForDrop within this method.
 */
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id<NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath * __nonnull * __nonnull)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:validateDrop:proposedItem:proposedIndexPath:dropOperation:)])
    {
        return [self.protocols collectionViewManager:self validateDrop:draggingInfo proposedItem:[_provider objectForItemAtIndexPath:*proposedDropIndexPath] proposedIndexPath:proposedDropIndexPath dropOperation:proposedDropOperation];
    }
    
    return NSDragOperationNone;
}

/**
 * This method is called when the mouse is released over a collection view that previously decided to allow a drop via the above validateDrop method. At this time, the delegate should incorporate the data from the dragging pasteboard and update the collection view's contents. You must implement this method for your collection view to be a drag destination.
 
 Multi-image drag and drop: If draggingInfo.animatesToDestination is set to YES, you should enumerate and update the dragging items with the proper image components and frames so that they dragged images animate to the proper locations.
 */
- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:acceptDrop:item:indexPath:dropOperation:)])
    {
        return [self.protocols collectionViewManager:self acceptDrop:draggingInfo item:[_provider objectForItemAtIndexPath:indexPath] indexPath:indexPath dropOperation:dropOperation];
    }
    
    return NO;
}

/**
 * Dragging Source Support - Required for multi-image drag and drop. Return a custom object that implements NSPasteboardWriting (or simply use NSPasteboardItem), or nil to prevent dragging for the item. For each valid item returned, NSCollectionView will create an NSDraggingItem with the draggingFrame equal to the frame of the item view at the given index path and components from -[NSCollectionViewItem draggingItem]. If this method is implemented, then -collectionView:writeItemsAtIndexPaths:toPasteboard: and -collectionView:draggingImageForItemsAtIndexPaths:withEvent:offset: will not be called.
 */
//- (nullable id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    @try
//    {
//        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:pasteboardWriterForItem:atIndexPath:)])
//        {
//            return [self.protocols collectionViewManager:self pasteboardWriterForItem:[_provider objectForItemAtIndexPath:indexPath] atIndexPath:indexPath];
//        }
//    }
//    @catch (NSException *exception)
//    {
//        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
//    }
//
//    return nil;
//}

/**
 * Dragging Source Support - Optional. Implement this method to know when the dragging session is about to begin and to potentially modify the dragging session.
 */
- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:draggingSession:willBeginAtPoint:forItems:atIndexPaths:)])
        {
            NSArray *draggedItems = [_provider objectsForItemAtIndexPaths:indexPaths];
            
            [self.protocols collectionViewManager:self draggingSession:session willBeginAtPoint:screenPoint forItems:draggedItems atIndexPaths:indexPaths];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Dragging Source Support - Optional. Implement this method to know when the dragging session has ended. This delegate method can be used to know when the dragging source operation ended at a specific location, such as the trash (by checking for an operation of NSDragOperationDelete).
 */
- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:draggingSession:endedAtPoint:dragOperation:)])
    {
        [self.protocols collectionViewManager:self draggingSession:session endedAtPoint:screenPoint dragOperation:operation];
    }
}

/**
 * Dragging Destination Support - Required for multi-image drag and drop. Implement this method to update dragging items as they are dragged over the view. Typically this will involve calling [draggingInfo enumerateDraggingItemsWithOptions:forView:classes:searchOptions:usingBlock:] and setting the draggingItem's imageComponentsProvider to a proper image based on the NSDraggingItem's -item value.
 */
- (void)collectionView:(NSCollectionView *)collectionView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(collectionViewManager:updateDraggingItemsForDrag:)])
    {
        [self.protocols collectionViewManager:self updateDraggingItemsForDrag:draggingInfo];
    }
}

@end
