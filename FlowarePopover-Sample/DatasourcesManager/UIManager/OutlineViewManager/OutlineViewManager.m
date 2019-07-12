//
//  OutlineViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "OutlineViewManager.h"

#import "ItemCellViewProtocols.h"

#import "DataProvider.h"
#import "ListSupplierProtocol.h"

@interface OutlineViewManager ()
{
    __weak NSOutlineView *_outlineView;
    __weak DataProvider *_provider;
    
    NSMutableArray<NSUserInterfaceItemIdentifier> *_registeredIdentifiers;
    NSCache *_cachedRowHeights;
}

/// @property
///

@end

@implementation OutlineViewManager

#pragma mark - Initialize

- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView source:(id<OutlineViewManagerProtocols>)source provider:(DataProvider *)provider
{
    if (self = [super init])
    {
        if ([outlineView isKindOfClass:[NSOutlineView class]] && [source conformsToProtocol:@protocol(OutlineViewManagerProtocols)] && [provider isKindOfClass:[DataProvider class]])
        {
            _provider = provider;
            _protocols = source;
            _registeredIdentifiers = [[NSMutableArray alloc] init];
            _cachedRowHeights = [[NSCache alloc] init];
            
            _outlineView = outlineView;
            _outlineView.delegate = self;
            _outlineView.dataSource = self;
            
            [_outlineView setTarget:self];
            [_outlineView setAction:@selector(outlineViewDidSelectItem)];
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
    _outlineView = nil;
    _provider = nil;
    
    [_registeredIdentifiers removeAllObjects];
    _registeredIdentifiers = nil;
    
    [_cachedRowHeights removeAllObjects];
    _cachedRowHeights = nil;
}

#pragma mark - Getter/Setter

- (NSOutlineView *)outlineView
{
    return _outlineView;
}

#pragma mark - Local methods

- (void)registerForRowItemWithIdentifier:(NSUserInterfaceItemIdentifier)identifier
{
    @try
    {
        if (![_registeredIdentifiers containsObject:identifier])
        {
            [_registeredIdentifiers addObject:identifier];
            
            [_outlineView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(NSClassFromString(identifier)) bundle:nil] forIdentifier:identifier];
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
    [_cachedRowHeights removeAllObjects];
    
    [self.outlineView reloadData];
}

#pragma mark - NSOutlineViewDataSource

/**
 * Returns the number of child items encompassed by a given item. The outlineView:numberOfChildrenOfItem: method is called very frequently, so it must be efficient.
 */
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    @try
    {
        if (item == nil)
        {
            return _provider.dataSource.count;
        }
        
        if ([(id<ListSupplierProtocol>)item respondsToSelector:@selector(lsp_childs)])
        {
            return [(id<ListSupplierProtocol>)item lsp_childs].count;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return 0;
}

/**
 * Returns the child item at the specified index of a given item.
 */
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    @try
    {
        if (item == nil)
        {
            return [_provider.dataSource objectAtIndex:index];
        }
        
        if ([(id<ListSupplierProtocol>)item respondsToSelector:@selector(lsp_childs)])
        {
            return [[(id<ListSupplierProtocol>)item lsp_childs] objectAtIndex:index];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

/**
 * Returns a Boolean value that indicates whether the a given item is expandable. This method may be called quite often, so it must be efficient.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:isItemExpandable:)])
        {
            return [self.protocols outlineViewManager:self isItemExpandable:(id<ListSupplierProtocol>)item];
        }
        
        if ([(id<ListSupplierProtocol>)item respondsToSelector:@selector(lsp_childs)])
        {
            return [(id<ListSupplierProtocol>)item lsp_childs].count > 0;
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

#pragma mark - NSOutlineViewDelegate UI

/**
 * Return the view used to display the specified item and column.
 */
- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    @try
    {
        id<ListSupplierProtocol> object = (id<ListSupplierProtocol>)item;
        NSInteger row = [outlineView rowForItem:object];
        NSUserInterfaceItemIdentifier identifier;
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:makeViewWithIdentifierForItem:)])
        {
            identifier = [self.protocols outlineViewManager:self makeViewWithIdentifierForItem:object];
        }
        else
        {
            NSLog(@"%s-[%d] [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, [NSThread callStackSymbols]);
            
            NSAssert(false, @"%s-[%d] failed", __PRETTY_FUNCTION__, __LINE__);
        }
        
        [self registerForRowItemWithIdentifier:identifier];
        
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:identifier owner:self];
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemView:willLoadData:forRow:)])
        {
            [self.protocols outlineViewManager:self itemView:cell willLoadData:object forRow:row];
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
 * Return a custom NSTableRowView for a particular item.
 */
- (nullable NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:rowViewForItem:)])
        {
            return [self.protocols outlineViewManager:self rowViewForItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return nil;
}

/**
 * This delegate method can be used to know when a new 'rowView' has been added to the table. At this point, you can choose to add in extra views, or modify any properties on 'rowView'.
 */
- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    @try
    {
        id<ListSupplierProtocol> object = (id<ListSupplierProtocol>)[outlineView itemAtRow:row];
        
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:heightOfView:forRow:byItem:)])
        {
            NSValue *itemValue = [NSValue valueWithNonretainedObject:object];
            
            if ([_cachedRowHeights objectForKey:itemValue] == nil)
            {
                CGFloat rowHeight = [self.protocols outlineViewManager:self heightOfView:[rowView.subviews firstObject] forRow:row byItem:object];
                
                [_cachedRowHeights setObject:@(rowHeight) forKey:itemValue];
                
                // Notify to the NSOutlineView reloads cell height
                [outlineView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * This delegate method can be used to know when 'rowView' has been removed from the table. The removed 'rowView' may be reused by the table so any additionally inserted views should be removed at this point. A 'row' parameter is included. 'row' will be '-1' for rows that are being deleted from the table and no longer have a valid row, otherwise it will be the valid row that is being removed due to it being moved off screen.
 */
- (void)outlineView:(NSOutlineView *)outlineView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:didRemoveView:forRow:byItem:)])
        {
            id<ListSupplierProtocol> object = (id<ListSupplierProtocol>)[outlineView itemAtRow:row];
            
            [self.protocols outlineViewManager:self didRemoveView:[rowView.subviews firstObject] forRow:row byItem:object];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Informs the delegate that the cell specified by the column and item will be displayed.
 */
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
}

/**
 * Returns a Boolean value that indicates whether the outline view should allow editing of a given item in a given table column.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldEditTableColumn:item:)])
        {
            return [self.protocols outlineViewManager:self shouldEditTableColumn:tableColumn item:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

/**
 * Optional - Tool Tip support
 When the user pauses over a cell, the value returned from this method will be displayed in a tooltip.  'point' represents the current mouse location in view coordinates.  If you don't want a tooltip at that location, return an empty string.  On entry, 'rect' represents the proposed active area of the tooltip.  By default, rect is computed as [cell drawingRectForBounds:cellFrame].  To control the default active area, you can modify the 'rect' parameter.
 */
- (NSString *)outlineView:(NSOutlineView *)outlineView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn item:(id)item mouseLocation:(NSPoint)mouseLocation
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:toolTipForCell:rect:tableColumn:item:mouseLocation:)])
        {
            NSString *toolTip = [self.protocols outlineViewManager:self toolTipForCell:cell rect:rect tableColumn:tableColumn item:(id<ListSupplierProtocol>)item mouseLocation:mouseLocation];
            
            return ([toolTip isKindOfClass:[NSString class]]) ? toolTip : @"";
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return @"";
}

/**
 * Optional - Variable Row Heights
 Implement this method to support a table with varying row heights. The height returned by this method should not include intercell spacing and must be greater than zero. Performance Considerations: For large tables in particular, you should make sure that this method is efficient. NSTableView may cache the values this method returns, but this should NOT be depended on, as all values may not be cached. To signal a row height change, call -noteHeightOfRowsWithIndexesChanged:. For a given row, the same row height should always be returned until -noteHeightOfRowsWithIndexesChanged: is called, otherwise unpredicable results will happen. NSTableView automatically invalidates its entire row height cache in -reloadData, and -noteNumberOfRowsChanged.
 */
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    @try
    {
        id<ListSupplierProtocol> object = (id<ListSupplierProtocol>)item;
        NSValue *itemValue = [NSValue valueWithNonretainedObject:object];
        
        if ([[_cachedRowHeights objectForKey:itemValue] isKindOfClass:[NSNumber class]])
        {
            return [((NSNumber *)[_cachedRowHeights objectForKey:itemValue]) doubleValue];
        }
        else
        {
            if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:heightOfRowByItem:)])
            {
                return [self.protocols outlineViewManager:self heightOfRowByItem:object];
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
 * Optional - Expansion ToolTip support
 Implement this method and return NO to prevent an expansion tooltip from appearing for a particular cell at 'item' in 'tableColumn'. See NSCell.h for more information on expansion tool tips.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowCellExpansionForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}

/**
 * Optional - Custom tracking support
 It is possible to control the ability to track a cell or not. Normally, only selectable or selected cells can be tracked. If you implement this method, cells which are not selectable or selected can be tracked, and vice-versa. For instance, this allows you to have an NSButtonCell in a table which does not change the selection, but can still be clicked on and tracked.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}

/**
 * Optional - Group rows.
 Implement this method and return YES to indicate a particular row should have the "group row" style drawn for that row. If the cell in that row is an NSTextFieldCell and contains only a stringValue, the "group row" style attributes will automatically be applied for that cell.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:isGroupItem:)])
        {
            return [self.protocols outlineViewManager:self isGroupItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

/**
 * Optional - Controlling expanding/collapsing of items.
 Called when the outlineView is about to expand 'item'. Implementations of this method should be fast. This method may be called multiple times if a given 'item' has children that are also being expanded. If NO is returned, 'item' will not be expanded, nor will its children (even if -[outlineView expandItem:item expandChildren:YES] is called).
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldExpandItem:)])
        {
            return [self.protocols outlineViewManager:self shouldExpandItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return YES;
}

/**
 * Optional - Controlling expanding/collapsing of items.
 Called when the outlineView is about to collapse 'item'. Implementations of this method should be fast. If NO is returned, 'item' will not be collapsed, nor will its children (even if -[outlineView collapseItem:item collapseChildren:YES] is called).
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldCollapseItem:)])
        {
            return [self.protocols outlineViewManager:self shouldCollapseItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return YES;
}

/**
 * Optional - OutlineCell (disclosure triangle button cell)
 Implement this method to customize the "outline cell" used for the disclosure triangle button. customization of the "outline cell" used for the disclosure triangle button. For instance, you can cause the button cell to always use a "dark" triangle by changing the cell's backgroundStyle with: [cell setBackgroundStyle:NSBackgroundStyleLight]
 */
- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:willDisplayOutlineCell:forTableColumn:item:)])
        {
            [self.protocols outlineViewManager:self willDisplayOutlineCell:cell forTableColumn:tableColumn item:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    [cell setTransparent:YES];
}

/**
 * Optional - Hiding the outline cell (disclosure triangle)
 Allows the delegate to decide if the outline cell (disclosure triangle) for 'item' should be displayed or not. This method will only be called for expandable rows. If 'NO' is returned,  -[outlineView frameOfOutlineCellAtRow:] will return NSZeroRect, causing the outline cell to be hidden. In addition, if 'NO' is returned, the row will not be collapsable by keyboard shortcuts.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldShowOutlineCellForItem:)])
        {
            return [self.protocols outlineViewManager:self shouldShowOutlineCellForItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return YES;
}

#pragma mark - NSOutlineViewDelegate Selection

/**
 * Returns a Boolean value that indicates whether the outline view should change its selection.
 */
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:selectionShouldChangeInOutlineView:)])
    {
        return [self.protocols outlineViewManager:self selectionShouldChangeInOutlineView:outlineView];
    }
    
    return YES;
}

/**
 * Sent to the delegate whenever the mouse button is clicked in outlineView while the cursor is in a column header tableColumn.
 */
- (void)outlineView:(NSOutlineView *)outlineView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:mouseDownInHeaderOfTableColumn:)])
    {
        [self.protocols outlineViewManager:self mouseDownInHeaderOfTableColumn:tableColumn];
    }
}

/**
 * Returns a Boolean value that indicates whether the outline view should select a given table column.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldSelectTableColumn:)])
    {
        return [self.protocols outlineViewManager:self shouldSelectTableColumn:tableColumn];
    }
    
    return YES;
}

/**
 * Sent at the time the mouse button subsequently goes up in outlineView and tableColumn has been “clicked” without having been dragged anywhere.
 */
- (void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:didClickTableColumn:)])
    {
        [self.protocols outlineViewManager:self didClickTableColumn:tableColumn];
    }
}

/**
 * Optional - Return YES if 'item' should be selected and 'NO' if it should not. For better performance, and greater control, it is recommended that you use outlineView:selectionIndexesForProposedSelection:.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:shouldSelectItem:)])
        {
            return [self.protocols outlineViewManager:self shouldSelectItem:(id<ListSupplierProtocol>)item];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return YES;
}

/**
 * Optional - Return a set of new indexes to select when the user changes the selection with the keyboard or mouse. If implemented, this method will be called instead of outlineView:shouldSelectItem:. This method may be called multiple times with one new index added to the existing selection to find out if a particular index can be selected when the user is extending the selection with the keyboard or mouse. Note that 'proposedSelectionIndexes' will contain the entire newly suggested selection, and you can return the existing selection to avoid changing the selection.
 */
//- (NSIndexSet *)outlineView:(NSOutlineView *)outlineView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
//{
//    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:selectionIndexesForProposedSelection:)])
//    {
//        return [self.protocols outlineViewManager:self selectionIndexesForProposedSelection:proposedSelectionIndexes];
//    }
//
//    return proposedSelectionIndexes;
//}

- (void)outlineViewDidSelectItem
{
    @try
    {
        NSInteger row = [self.outlineView clickedRow];
        id<ListSupplierProtocol> object;
        
        if ((row != -1) && (row != NSNotFound))
        {
            object = (id<ListSupplierProtocol>)[self.outlineView itemAtRow:row];
        }
        
        if ((object != nil) && (self.protocols != nil))
        {
            BOOL isSelectable = [self.outlineView.delegate outlineView:self.outlineView shouldSelectItem:object];
            
            if (isSelectable && [self.protocols respondsToSelector:@selector(outlineViewManager:didSelectItem:forRow:)])
            {
                [self.protocols outlineViewManager:self didSelectItem:object forRow:row];
            }
            else if (!isSelectable && [self.protocols respondsToSelector:@selector(outlineViewManager:didSelectUnselectableItem:forRow:)])
            {
                // For some cases, we want this delegate to perform some special stuffs.
                [self.protocols outlineViewManager:self didSelectUnselectableItem:object forRow:row];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

#pragma mark - NSOutlineViewDataSource Drag/Drop

/**
 * Sent at the time the mouse button goes up in outlineView and tableColumn has been dragged during the time the mouse button was down.
 */
- (void)outlineView:(NSOutlineView *)outlineView didDragTableColumn:(NSTableColumn *)tableColumn
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:didDragTableColumn:)])
    {
        [self.protocols outlineViewManager:self didDragTableColumn:tableColumn];
    }
}

/**
 * Dragging Source Support - Required for multi-image dragging. Implement this method to allow the table to be an NSDraggingSource that supports multiple item dragging. Return a custom object that implements NSPasteboardWriting (or simply use NSPasteboardItem). Return nil to prevent a particular item from being dragged. If this method is implemented, then outlineView:writeItems:toPasteboard: will not be called.
 */
//- (nullable id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
//{
//    @try
//    {
//        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:pasteboardWriterForItem:)])
//        {
//            return [self.protocols outlineViewManager:self pasteboardWriterForItem:item];
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
 * Dragging Source Support - Optional. Implement this method know when the dragging session is about to begin and to potentially modify the dragging session. 'draggedItems' is an array of items that we dragged, excluding items that were not dragged due to outlineView:pasteboardWriterForItem: returning nil. This array will directly match the pasteboard writer array used to begin the dragging session with [NSView beginDraggingSessionWithItems:event:source]. Hence, the order is deterministic, and can be used in -outlineView:acceptDrop:item:childIndex: when enumerating the NSDraggingInfo's pasteboard classes.
 */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:draggingSession:willBeginAtPoint:forItems:)])
        {
            [self.protocols outlineViewManager:self draggingSession:session willBeginAtPoint:screenPoint forItems:draggedItems];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

/**
 * Dragging Source Support - Optional. Implement this method know when the dragging session has ended. This delegate method can be used to know when the dragging source operation ended at a specific location, such as the trash (by checking for an operation of NSDragOperationDelete).
 */
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:draggingSession:endedAtPoint:operation:)])
    {
        [self.protocols outlineViewManager:self draggingSession:session endedAtPoint:screenPoint operation:operation];
    }
}

/**
 * Dragging Source Support - Optional for single-image dragging. This method is called after it has been determined that a drag should begin, but before the drag has been started.  To refuse the drag, return NO.  To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  The drag image and other drag related information will be set up and provided by the outline view once this call returns with YES.  The items array is the list of items that will be participating in the drag.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:writeItems:toPasteboard:)])
        {
            return [self.protocols outlineViewManager:self writeItems:items toPasteboard:pasteboard];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NO;
}

/**
 * Dragging Destination Support - Required for multi-image dragging. Implement this method to allow the table to update dragging items as they are dragged over the view. Typically this will involve calling [draggingInfo enumerateDraggingItemsWithOptions:forView:classes:searchOptions:usingBlock:] and setting the draggingItem's imageComponentsProvider to a proper image based on the content. For View Based TableViews, one can use NSTableCellView's -draggingImageComponents and -draggingImageFrame.
 */
- (void)outlineView:(NSOutlineView *)outlineView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:updateDraggingItemsForDrag:)])
    {
        [self.protocols outlineViewManager:self updateDraggingItemsForDrag:draggingInfo];
    }
}

/**
 * Dragging Destination Support - This method is used by NSOutlineView to determine a valid drop target. Based on the mouse position, the outline view will suggest a proposed child 'index' for the drop to happen as a child of 'item'. This method must return a value that indicates which NSDragOperation the data source will perform. The data source may "re-target" a drop, if desired, by calling setDropItem:dropChildIndex: and returning something other than NSDragOperationNone. One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position). On Leopard linked applications, this method is called only when the drag position changes or the dragOperation changes (ie: a modifier key is pressed). Prior to Leopard, it would be called constantly in a timer, regardless of attribute changes.
 */
- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(nullable id)item proposedChildIndex:(NSInteger)index
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:validateDrop:proposedItem:proposedChildIndex:)])
        {
            return [self.protocols outlineViewManager:self validateDrop:info proposedItem:item proposedChildIndex:index];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
    
    return NSDragOperationNone;
}

/**
 * Dragging Destination Support - This method is called when the mouse is released over an outline view that previously decided to allow a drop via the validateDrop method. The data source should incorporate the data from the dragging pasteboard at this time. 'index' is the location to insert the data as a child of 'item', and are the values previously set in the validateDrop: method.
 */
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(nullable id)item childIndex:(NSInteger)index
{
    @try
    {
        if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:acceptDrop:item:childIndex:)])
        {
            return [self.protocols outlineViewManager:self acceptDrop:info item:item childIndex:index];
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
 * Invoked when the selection did change notification is posted—that is, immediately after the outline view’s selection has changed.
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:selectionDidChange:)])
    {
        [self.protocols outlineViewManager:self selectionDidChange:notification];
    }
}

/**
 * Invoked whenever the user moves a column in the outline view.
 */
- (void)outlineViewColumnDidMove:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:columnDidMove:)])
    {
        [self.protocols outlineViewManager:self columnDidMove:notification];
    }
}

/**
 * Invoked whenever the user resizes a column in the outline view.
 */
- (void)outlineViewColumnDidResize:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:columnDidResize:)])
    {
        [self.protocols outlineViewManager:self columnDidResize:notification];
    }
}

/**
 * Invoked when notification is posted—that is, whenever the outline view’s selection changes.
 */
- (void)outlineViewSelectionIsChanging:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:selectionIsChanging:)])
    {
        [self.protocols outlineViewManager:self selectionIsChanging:notification];
    }
}

/**
 * Invoked when notification is posted—that is, whenever the user is about to expand an item in the outline view.
 */
- (void)outlineViewItemWillExpand:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemWillExpand:)])
    {
        [self.protocols outlineViewManager:self itemWillExpand:notification];
    }
}

/**
 * Invoked when notification is posted—that is, whenever the user expands an item in the outline view.
 */
- (void)outlineViewItemDidExpand:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemDidExpand:)])
    {
        [self.protocols outlineViewManager:self itemDidExpand:notification];
    }
}

/**
 * Invoked when notification is posted—that is, whenever the user is about to collapse an item in the outline view.
 */
- (void)outlineViewItemWillCollapse:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemWillCollapse:)])
    {
        [self.protocols outlineViewManager:self itemWillCollapse:notification];
    }
}

/**
 * Invoked when the did collapse notification is posted—that is, whenever the user collapses an item in the outline view.
 */
- (void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemDidCollapse:)])
    {
        [self.protocols outlineViewManager:self itemDidCollapse:notification];
    }
}

@end
