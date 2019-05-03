//
//  OutlineViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OutlineViewManager;
@class DataProvider;
@protocol ListSupplierProtocol;

@protocol OutlineViewManagerProtocols <NSObject>

@optional
#pragma mark - UI

/**
 * Asks the delegate for the identifier of the specified item.
 */
- (NSUserInterfaceItemIdentifier)outlineViewManager:(OutlineViewManager *)manager makeViewWithIdentifierForItem:(id)item;

/**
 * Tells the delegate that a specified cell of row will load its data.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager itemView:(NSTableCellView *)itemView willLoadData:(id<ListSupplierProtocol> _Nonnull)data forRow:(NSInteger)row;

/**
 * Returns a Boolean value that indicates whether the a given item is expandable. This method may be called quite often, so it must be efficient.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager isItemExpandable:(id)item;

/**
 * Asks the delegate for a view to display the specified item.
 */
- (NSTableRowView *)outlineViewManager:(OutlineViewManager *)manager rowViewForItem:(id)item;

/**
 * Tells the delegate that a row view was removed from the outline view at the specified row.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager didRemoveView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate that whether the outline view should allow editing of a given item in a given table column.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item;

/**
 * Asks the delegate whether the outline view should display tooltip for cell of column for item at specified location.
 */
- (NSString *)outlineViewManager:(OutlineViewManager *)manager toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation;

/**
 * Asks the delegate for the estimated height of specified item.
 */
- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightOfRowByItem:(id)item;

/**
 * Asks the delegate for the height of view with item at the specified row.
 */
- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightOfView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate whether a specified item should be drawn in the “group row” style.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager isGroupItem:(id)item;

/**
 * Asks the delegate whether the outline view should expand a given item.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldExpandItem:(id)item;

/**
 * Asks the delegate whether the outline view should collapse a given item.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldCollapseItem:(id)item;

/**
 * Informs the delegate that an outline view is about to display a cell used to draw the expansion symbol.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager willDisplayOutlineCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item;

/**
 * Ask the delegate whether the specified item should display the outline cell (the disclosure triangle).
 * @note NEVER return NO for this delegate, unless the [collapseItem:] method of NSOutlineView will never be called.
 * If we want to remove the disclosure triangle button, we should create the custom class of NSOutlineView.
 * @header Example:
 * @code
 *  - (NSRect)frameOfOutlineCellAtRow:(NSInteger)row
 *  {
 *      return NSZeroRect;
 *  }
 * @endcode
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldShowOutlineCellForItem:(id)item;

#pragma mark - Selection

/**
 * Asks the delegate that whether the outline view should change its selection.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView;

/**
 * Tells the delegate that the mouse button was clicked in the specified table column’s header.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;

/**
 * Asks the delegate whether the outline view should select a given table column.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn;

/**
 * Tells the delegate that the mouse button was clicked in the specified table column, but the column was not dragged.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager didClickTableColumn:(NSTableColumn *)tableColumn;

/**
 * Asks the delegate if the outline view should allow selection of the specified item.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager shouldSelectItem:(id)item;

/**
 * Asks the delegate to accept or reject the proposed selection.
 */
//- (NSIndexSet *)outlineViewManager:(OutlineViewManager *)manager selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes;

/**
 * Tells the delegate that an item is selected at the specified row.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager didSelectItem:(id)item forRow:(NSInteger)row;

/**
 * Tells the delegate that an unselectable item is selected at the specified row.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager didSelectUnselectableItem:(id)item forRow:(NSInteger)row;

#pragma mark - Drag/Drop

/**
 * Tells the delegate that the specified table column was dragged.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager didDragTableColumn:(NSTableColumn *)tableColumn;

/**
 * Ask the delegate to enable the table to be an NSDraggingSource that supports dragging multiple items.
 */
//- (nullable id<NSPasteboardWriting>)outlineViewManager:(OutlineViewManager *)manager pasteboardWriterForItem:(id)item;

/**
 * Tells the delegate that a dragging session will begin.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems;

/**
 * Tells the delegate that a dragging session has ended.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation;

/**
 * Returns a Boolean value that indicates whether a drag operation is allowed.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard;

/**
 * Tells the delegate to enable the table to update dragging items as they are dragged over the view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo;

/**
 * Used by an outline view to determine a valid drop target.
 */
- (NSDragOperation)outlineViewManager:(OutlineViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index;

/**
 * Returns a Boolean value that indicates whether a drop operation was successful.
 */
- (BOOL)outlineViewManager:(OutlineViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item childIndex:(NSInteger)index;

#pragma mark - Notifications

/**
 * Invoked when the selection did change notification is posted—that is, immediately after the outline view’s selection has changed.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager selectionDidChange:(NSNotification *)notification;

/**
 * Invoked whenever the user moves a column in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager columnDidMove:(NSNotification *)notification;

/**
 * Invoked whenever the user resizes a column in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager columnDidResize:(NSNotification *)notification;

/**
 * Invoked when notification is posted—that is, whenever the outline view’s selection changes.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager selectionIsChanging:(NSNotification *)notification;

/**
 * Invoked when notification is posted—that is, whenever the user is about to expand an item in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager itemWillExpand:(NSNotification *)notification;

/**
 * Invoked when notification is posted—that is, whenever the user expands an item in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager itemDidExpand:(NSNotification *)notification;

/**
 * Invoked when notification is posted—that is, whenever the user is about to collapse an item in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager itemWillCollapse:(NSNotification *)notification;

/**
 * Invoked when the did collapse notification is posted—that is, whenever the user collapses an item in the outline view.
 */
- (void)outlineViewManager:(OutlineViewManager *)manager itemDidCollapse:(NSNotification *)notification;

@end

@interface OutlineViewManager : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>

/// Protocols
///
@property (nonatomic, weak) id<OutlineViewManagerProtocols> protocols;

/// @property
///
@property (nonatomic, weak, readonly) NSOutlineView *outlineView;

/// Initializes
///
- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView source:(id<OutlineViewManagerProtocols>)source provider:(DataProvider *)provider;

/// OutlineViewManager methods
///
- (void)reloadData;

@end
