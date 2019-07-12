//
//  TableViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TableViewManager.h"

#import "ItemCellViewProtocols.h"

#import "DataProvider.h"
#import "ListSupplierProtocol.h"

@interface TableViewManager ()
{
    __weak NSTableView *_tableView;
    __weak DataProvider *_provider;
    
    NSMutableArray<NSUserInterfaceItemIdentifier> *_registeredIdentifiers;
    NSCache *_cachedRowHeights;
}

/// @property
///

@end

@implementation TableViewManager

#pragma mark - Initialize

- (instancetype)initWithTableView:(NSTableView * _Nonnull)tableView source:(id<TableViewManagerProtocols>)source provider:(DataProvider * _Nonnull)provider
{
    if (self = [super init])
    {
        if ([tableView isKindOfClass:[NSTableView class]] && [source conformsToProtocol:@protocol(TableViewManagerProtocols)] && [provider isKindOfClass:[DataProvider class]])
        {
            _provider = provider;
            _protocols = source;
            _registeredIdentifiers = [[NSMutableArray alloc] init];
            _cachedRowHeights = [[NSCache alloc] init];
            
            _tableView = tableView;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            
            [_tableView setTarget:self];
            [_tableView setAction:@selector(tableViewDidSelectItem)];
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
    _tableView = nil;
    _provider = nil;
    
    [_registeredIdentifiers removeAllObjects];
    _registeredIdentifiers = nil;
    
    [_cachedRowHeights removeAllObjects];
    _cachedRowHeights = nil;
}

#pragma mark - Getter/Setter

- (NSTableView *)tableView
{
    return _tableView;
}

#pragma mark - Local methods

- (void)registerForRowItemWithIdentifier:(NSUserInterfaceItemIdentifier)identifier
{
    @try
    {
        if (![_registeredIdentifiers containsObject:identifier])
        {
            [_registeredIdentifiers addObject:identifier];
            
            [_tableView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(NSClassFromString(identifier)) bundle:nil] forIdentifier:identifier];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

#pragma mark - TableViewManager methods

- (void)reloadData
{
    [_cachedRowHeights removeAllObjects];
    
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

/**
 * Returns the number of records managed for aTableView by the data source object.
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _provider.dataSource.count;
}

#pragma mark - NSTableViewDelegate UI

/**
 * View Based TableView:
 Non-bindings: This method is required if you wish to turn on the use of NSViews instead of NSCells. The implementation of this method will usually call -[tableView makeViewWithIdentifier:[tableColumn identifier] owner:self] in order to reuse a previous view, or automatically unarchive an associated prototype view for that identifier. The -frame of the returned view is not important, and it will be automatically set by the table. 'tableColumn' will be nil if the row is a group row. Returning nil is acceptable, and a view will not be shown at that location. The view's properties should be properly set up before returning the result.
 
 Bindings: This method is optional if at least one identifier has been associated with the TableView at design time. If this method is not implemented, the table will automatically call -[self makeViewWithIdentifier:[tableColumn identifier] owner:[tableView delegate]] to attempt to reuse a previous view, or automatically unarchive an associated prototype view. If the method is implemented, the developer can setup properties that aren't using bindings.
 
 The autoresizingMask of the returned view will automatically be set to NSViewHeightSizable to resize properly on row height changes.
 */
- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    @try
    {
        id<ListSupplierProtocol> object = [_provider objectForRow:row];
        
        NSUserInterfaceItemIdentifier identifier;
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:makeViewWithIdentifierForRow:byItem:)])
        {
            identifier = [self.protocols tableViewManager:self makeViewWithIdentifierForRow:row byItem:object];
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
        
        [self registerForRowItemWithIdentifier:identifier];
        
        NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:itemView:willLoadData:forRow:)])
        {
            [self.protocols tableViewManager:self itemView:cell willLoadData:object forRow:row];
        }
        else if ([cell conformsToProtocol:@protocol(ItemCellViewProtocols)] && [(id<ItemCellViewProtocols>)cell respondsToSelector:@selector(itemCellView:updateWithData:atIndex:)])
        {
            [(id<ItemCellViewProtocols>)cell itemCellView:(id<ItemCellViewProtocols>)cell updateWithData:object atIndex:row];
        }
        
        return cell;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

/**
 * View Based TableView: The delegate can optionally implement this method to return a custom NSTableRowView for a particular 'row'. The reuse queue can be used in the same way as documented in tableView:viewForTableColumn:row:. The returned view will have attributes properly set to it before it is added to the tableView. Returning nil is acceptable. If nil is returned, or this method isn't implemented, a regular NSTableRowView will be created and used.
 */
- (nullable NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:rowViewForRow:byItem:)])
        {
            id<ListSupplierProtocol> object = [_provider objectForRow:row];
            
            return [self.protocols tableViewManager:self rowViewForRow:row byItem:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

/**
 * View Based TableView: Optional: This delegate method can be used to know when a new 'rowView' has been added to the table. At this point, you can choose to add in extra views, or modify any properties on 'rowView'.
 */
- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:heightOfView:forRow:byItem:)])
        {
            id<ListSupplierProtocol> object = [_provider objectForRow:row];
            NSValue *itemValue = [NSValue valueWithNonretainedObject:object];
            
            if ([_cachedRowHeights objectForKey:itemValue] == nil)
            {
                CGFloat rowHeight = [self.protocols tableViewManager:self heightOfView:[rowView.subviews firstObject] forRow:row byItem:object];
                
                [_cachedRowHeights setObject:@(rowHeight) forKey:itemValue];
                
                // Notify to the NSTableView reloads cell height
                [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * View Based TableView: Optional: This delegate method can be used to know when 'rowView' has been removed from the table. The removed 'rowView' may be reused by the table so any additionally inserted views should be removed at this point. A 'row' parameter is included. 'row' will be '-1' for rows that are being deleted from the table and no longer have a valid row, otherwise it will be the valid row that is being removed due to it being moved off screen.
 */
- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:didRemoveView:forRow:byItem:)])
        {
            id<ListSupplierProtocol> object = [_provider objectForRow:row];
            
            [self.protocols tableViewManager:self didRemoveView:[rowView.subviews firstObject] forRow:row byItem:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Optional - Variable Row Heights
 Implement this method to support a table with varying row heights. The height returned by this method should not include intercell spacing and must be greater than zero. Performance Considerations: For large tables in particular, you should make sure that this method is efficient. NSTableView may cache the values this method returns, but this should NOT be depended on, as all values may not be cached. To signal a row height change, call -noteHeightOfRowsWithIndexesChanged:. For a given row, the same row height should always be returned until -noteHeightOfRowsWithIndexesChanged: is called, otherwise unpredicable results will happen. NSTableView automatically invalidates its entire row height cache in -reloadData, and -noteNumberOfRowsChanged.
 */
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    @try
    {
        id<ListSupplierProtocol> object = [_provider objectForRow:row];
        NSValue *itemValue = [NSValue valueWithNonretainedObject:object];
        
        if ([[_cachedRowHeights objectForKey:itemValue] isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber *)[_cachedRowHeights objectForKey:itemValue]) doubleValue];
        }
        else
        {
            if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:heightOfRow:byItem:)])
            {
                return [self.protocols tableViewManager:self heightOfRow:row byItem:object];
            }
            else
            {
                NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
                
                NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return 0.0;
}

/**
 * Optional - Group rows.
 Implement this method and return YES to indicate a particular row should have the "group row" style drawn for that row. If the cell in that row is an NSTextFieldCell and contains only a stringValue, the "group row" style attributes will automatically be applied for that cell. Group rows are drawn differently depending on the selectionHighlightStyle. For NSTableViewSelectionHighlightStyleRegular, there is a blue gradient background. For NSTableViewSelectionHighlightStyleSourceList, the text is light blue, and there is no background. Also see the related floatsGroupRows property.
 */
- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:isGroupRow:byItem:)])
        {
            id<ListSupplierProtocol> object = [_provider objectForRow:row];
            
            return [self.protocols tableViewManager:self isGroupRow:row byItem:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

#pragma mark - NSTableViewDelegate Selection

/**
 * Asks the delegate if the user is allowed to change the selection.
 */
- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:selectionShouldChangeInTableView:)])
    {
        return [self.protocols tableViewManager:self selectionShouldChangeInTableView:tableView];
    }
    
    return YES;
}

/**
 * Tells the delegate that the mouse button was clicked in the specified table column’s header.
 */
- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:mouseDownInHeaderOfTableColumn:)])
    {
        [self.protocols tableViewManager:self mouseDownInHeaderOfTableColumn:tableColumn];
    }
}

/**
 * Asks the delegate whether the specified table column can be selected.
 */
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:shouldSelectTableColumn:)])
    {
        return [self.protocols tableViewManager:self shouldSelectTableColumn:tableColumn];
    }
    
    return YES;
}

/**
 * Tells the delegate that the mouse button was clicked in the specified table column, but the column was not dragged.
 */
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:didClickTableColumn:)])
    {
        [self.protocols tableViewManager:self didClickTableColumn:tableColumn];
    }
}

/**
 * Optional - Return YES if 'row' should be selected and NO if it should not. For better performance and better control over the selection, you should use tableView:selectionIndexesForProposedSelection:.
 */
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:shouldSelectRow:byItem:)])
        {
            id<ListSupplierProtocol> object = [_provider objectForRow:row];
            
            return [self.protocols tableViewManager:self shouldSelectRow:row byItem:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return YES;
}

/**
 * Optional - Return a set of new indexes to select when the user changes the selection with the keyboard or mouse. If implemented, this method will be called instead of tableView:shouldSelectRow:. This method may be called multiple times with one new index added to the existing selection to find out if a particular index can be selected when the user is extending the selection with the keyboard or mouse. Note that 'proposedSelectionIndexes' will contain the entire newly suggested selection, and you can return the exsiting selection to avoid changing the selection.
 */
//- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
//{
//    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:selectionIndexesForProposedSelection:)])
//    {
//        [self.protocols tableViewManager:self selectionIndexesForProposedSelection:proposedSelectionIndexes];
//    }
//
//    return proposedSelectionIndexes;
//}

- (void)tableViewDidSelectItem
{
    @try
    {
        NSInteger row = [self.tableView clickedRow];
        id<ListSupplierProtocol> object;
        
        if ((row != -1) && (row != NSNotFound))
        {
            object = (id<ListSupplierProtocol>)[_provider objectForRow:row];
        }
        
        if ((object != nil) && (self.protocols != nil))
        {
            BOOL isSelectable = [self.tableView.delegate tableView:self.tableView shouldSelectRow:row];
            
            if (isSelectable && [self.protocols respondsToSelector:@selector(tableViewManager:didSelectItem:forRow:)])
            {
                [self.protocols tableViewManager:self didSelectItem:object forRow:row];
            }
            else if (!isSelectable && [self.protocols respondsToSelector:@selector(tableViewManager:didSelectUnselectableItem:forRow:)])
            {
                // For some cases, we want this delegate to perform some special stuffs.
                [self.protocols tableViewManager:self didSelectUnselectableItem:object forRow:row];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

#pragma mark - NSTableViewDataSource Drag/Drop

/**
 * Tells the delegate that the specified table column was dragged.
 */
- (void)tableView:(NSTableView *)tableView didDragTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:didDragTableColumn:)])
    {
        [self.protocols tableViewManager:self didDragTableColumn:tableColumn];
    }
}

/**
 * Dragging Source Support - Required for multi-image dragging. Implement this method to allow the table to be an NSDraggingSource that supports multiple item dragging. Return a custom object that implements NSPasteboardWriting (or simply use NSPasteboardItem). If this method is implemented, then tableView:writeRowsWithIndexes:toPasteboard: will not be called.
 */
//- (nullable id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
//{
//    @try
//    {
//        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:pasteboardWriterForRow:byItem:)])
//        {
//            return [self.protocols tableViewManager:self pasteboardWriterForRow:row byItem:[_provider objectForRow:row]];
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
 * Dragging Source Support - Optional. Implement this method to know when the dragging session is about to begin and to potentially modify the dragging session.'rowIndexes' are the row indexes being dragged, excluding rows that were not dragged due to tableView:pasteboardWriterForRow: returning nil. The order will directly match the pasteboard writer array used to begin the dragging session with [NSView beginDraggingSessionWithItems:event:source]. Hence, the order is deterministic, and can be used in -tableView:acceptDrop:row:dropOperation: when enumerating the NSDraggingInfo's pasteboard classes.
 */
- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:draggingSession:willBeginAtPoint:forRowIndexes:items:)])
        {
            NSArray<id<ListSupplierProtocol>> *items = [_provider objectsForRowIndexes:rowIndexes];
            
            [self.protocols tableViewManager:self draggingSession:session willBeginAtPoint:screenPoint forRowIndexes:rowIndexes items:items];
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
- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:draggingSession:endedAtPoint:operation:)])
    {
        [self.protocols tableViewManager:self draggingSession:session endedAtPoint:screenPoint operation:operation];
    }
}

/**
 * Dragging Destination Support - Required for multi-image dragging. Implement this method to allow the table to update dragging items as they are dragged over the view. Typically this will involve calling [draggingInfo enumerateDraggingItemsWithOptions:forView:classes:searchOptions:usingBlock:] and setting the draggingItem's imageComponentsProvider to a proper image based on the content. For View Based TableViews, one can use NSTableCellView's -draggingImageComponents. For cell based TableViews, use NSCell's draggingImageComponentsWithFrame:inView:.
 */
- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:updateDraggingItemsForDrag:)])
    {
        [self.protocols tableViewManager:self updateDraggingItemsForDrag:draggingInfo];
    }
}

/**
 * Dragging Source Support - Optional for single-image dragging. Implement this method to support single-image dragging. Use the more modern tableView:pasteboardWriterForRow: to support multi-image dragging. This method is called after it has been determined that a drag should begin, but before the drag has been started.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the table view once this call returns with YES.  'rowIndexes' contains the row indexes that will be participating in the drag.
 */
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:writeRowsWithIndexes:items:toPasteboard:)])
        {
            NSArray<id<ListSupplierProtocol>> *items = [_provider objectsForRowIndexes:rowIndexes];
            
            return [self.protocols tableViewManager:self writeRowsWithIndexes:rowIndexes items:items toPasteboard:pboard];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

/**
 * Dragging Destination Support - This method is used by NSTableView to determine a valid drop target. Based on the mouse position, the table view will suggest a proposed drop 'row' and 'dropOperation'. This method must return a value that indicates which NSDragOperation the data source will perform. The data source may "re-target" a drop, if desired, by calling setDropRow:dropOperation: and returning something other than NSDragOperationNone. One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).
 */
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:validateDrop:proposedItem:proposedRow:proposedDropOperation:)])
        {
            return [self.protocols tableViewManager:self validateDrop:info proposedItem:[_provider objectForRow:row] proposedRow:row proposedDropOperation:dropOperation];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NSDragOperationNone;
}

/**
 * Dragging Destination Support - This method is called when the mouse is released over an NSTableView that previously decided to allow a drop via the validateDrop method. The data source should incorporate the data from the dragging pasteboard at this time. 'row' and 'dropOperation' contain the values previously set in the validateDrop: method.
 */
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:acceptDrop:item:row:dropOperation:)])
        {
            return [self.protocols tableViewManager:self acceptDrop:info item:[_provider objectForRow:row] row:row dropOperation:dropOperation];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

#pragma mark - Notifications

/**
 * Tells the delegate that the table view’s selection has changed.
 */
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:selectionDidChange:)])
    {
        [self.protocols tableViewManager:self selectionDidChange:notification];
    }
}

/**
 * Tells the delegate that a table column was moved by user action.
 */
- (void)tableViewColumnDidMove:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:columnDidMove:)])
    {
        [self.protocols tableViewManager:self columnDidMove:notification];
    }
}

/**
 * Tells the delegate that a table column was resized.
 */
- (void)tableViewColumnDidResize:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:columnDidResize:)])
    {
        [self.protocols tableViewManager:self columnDidResize:notification];
    }
}

/**
 * Tells the delegate that the table view’s selection is in the process of changing.
 */
- (void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:selectionIsChanging:)])
    {
        [self.protocols tableViewManager:self selectionIsChanging:notification];
    }
}

@end
