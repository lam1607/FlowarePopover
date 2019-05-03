//
//  TableViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TableViewManager;
@class DataProvider;
@protocol ListSupplierProtocol;

@protocol TableViewManagerProtocols <NSObject>

@optional
#pragma mark - UI

/**
 * Asks the delegate for the item identifier of the specified row.
 */
- (NSUserInterfaceItemIdentifier)tableViewManager:(TableViewManager *)manager makeViewWithIdentifierForRow:(NSInteger)row byItem:(id)item;

/**
 * Tells the delegate that a specified cell of row will load its data.
 */
- (void)tableViewManager:(TableViewManager *)manager itemView:(NSTableCellView *)itemView willLoadData:(id<ListSupplierProtocol> _Nonnull)data forRow:(NSInteger)row;

/**
 * Asks the delegate for a view to display the specified row.
 */
- (NSTableRowView *)tableViewManager:(TableViewManager *)manager rowViewForRow:(NSInteger)row byItem:(id)item;

/**
 * Tells the delegate that a row view was removed from the table at the specified row.
 */
- (void)tableViewManager:(TableViewManager *)manager didRemoveView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate for the estimated height of item at the specified row.
 */
- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate for the height of view with item at the specified row.
 */
- (CGFloat)tableViewManager:(TableViewManager *)manager heightOfView:(NSTableCellView *)view forRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate whether the specified item at row is in group.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager isGroupRow:(NSInteger)row byItem:(id)item;

#pragma mark - Selection

/**
 * Asks the delegate if the user is allowed to change the selection.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager selectionShouldChangeInTableView:(NSTableView *)tableView;

/**
 * Tells the delegate that the mouse button was clicked in the specified table column’s header.
 */
- (void)tableViewManager:(TableViewManager *)manager mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn;

/**
 * Asks the delegate whether the specified table column can be selected.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn;

/**
 * Tells the delegate that the mouse button was clicked in the specified table column, but the column was not dragged.
 */
- (void)tableViewManager:(TableViewManager *)manager didClickTableColumn:(NSTableColumn *)tableColumn;

/**
 * Asks the delegate if the table view should allow selection of the specified row.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager shouldSelectRow:(NSInteger)row byItem:(id)item;

/**
 * Asks the delegate to accept or reject the proposed selection.
 */
//- (void)tableViewManager:(TableViewManager *)manager selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes;

/**
 * Tells the delegate that an item is selected at the specified row.
 */
- (void)tableViewManager:(TableViewManager *)manager didSelectItem:(id)item forRow:(NSInteger)row;

/**
 * Tells the delegate that an unselectable item is selected at the specified row.
 */
- (void)tableViewManager:(TableViewManager *)manager didSelectUnselectableItem:(id)item forRow:(NSInteger)row;

#pragma mark - Drag/Drop

/**
 * Tells the delegate that the specified table column was dragged.
 */
- (void)tableViewManager:(TableViewManager *)manager didDragTableColumn:(NSTableColumn *)tableColumn;

/**
 * Called to allow the table to support multiple item dragging.
 If this method is implemented, then tableView:writeRowsWithIndexes:toPasteboard: will not be called.
 */
//- (nullable id<NSPasteboardWriting>)tableViewManager:(TableViewManager *)manager pasteboardWriterForRow:(NSInteger)row byItem:(id)item;

/**
 * Tells the delegate that a dragging session will begin.
 */
- (void)tableViewManager:(TableViewManager *)manager draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes items:(NSArray *)items;

/**
 * Tells the delegate that a dragging session has ended.
 */
- (void)tableViewManager:(TableViewManager *)manager draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation;

/**
 * Tells the delegate to allow the table to update dragging items as they are dragged over a view.
 */
- (void)tableViewManager:(TableViewManager *)manager updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo;

/**
 * Returns a Boolean value that indicates whether a drag operation is allowed.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager writeRowsWithIndexes:(NSIndexSet *)rowIndexes items:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard;

/**
 * Ask the delegate for a valid drop target.
 */
- (NSDragOperation)tableViewManager:(TableViewManager *)manager validateDrop:(id<NSDraggingInfo>)draggingInfo proposedItem:(nullable id)item proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation;

/**
 * This method is called when the mouse is released over an NSTableView that previously decided to allow a drop via the validateDrop method.
 */
- (BOOL)tableViewManager:(TableViewManager *)manager acceptDrop:(id<NSDraggingInfo>)draggingInfo item:(nullable id)item row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation;

#pragma mark - Notifications

/**
 * Tells the delegate that the table view’s selection has changed.
 */
- (void)tableViewManager:(TableViewManager *)manager selectionDidChange:(NSNotification *)notification;

/**
 * Tells the delegate that a table column was moved by user action.
 */
- (void)tableViewManager:(TableViewManager *)manager columnDidMove:(NSNotification *)notification;

/**
 * Tells the delegate that a table column was resized.
 */
- (void)tableViewManager:(TableViewManager *)manager columnDidResize:(NSNotification *)notification;

/**
 * Tells the delegate that the table view’s selection is in the process of changing.
 */
- (void)tableViewManager:(TableViewManager *)manager selectionIsChanging:(NSNotification *)notification;

@end

@interface TableViewManager : NSObject <NSTableViewDataSource, NSTableViewDelegate>

/// Protocols
///
@property (nonatomic, weak) id<TableViewManagerProtocols> protocols;

/// @property
///
@property (nonatomic, weak, readonly) NSTableView *tableView;

/// Initializes
///
- (instancetype)initWithTableView:(NSTableView * _Nonnull)tableView source:(id<TableViewManagerProtocols>)source provider:(DataProvider * _Nonnull)provider;

/// TableViewManager methods
///
- (void)reloadData;

@end
