//
//  OutlineViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "OutlineViewManager.h"

#import "OutlineViewRowProtocols.h"

@interface OutlineViewManager () {
    NSMutableArray<id<OutlineViewRowProtocols>> *_rows;
    NSMutableArray<NSString *> *_registeredRowIdentifiers;
    NSCache *_cachedRowHeights;
}

/// @property
///
@property (nonatomic, weak, readwrite) NSOutlineView *outlineView;

@end

@implementation OutlineViewManager

#pragma mark - Initialize

- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView {
    if (self = [super init]) {
        _rows = [[NSMutableArray alloc] init];
        _registeredRowIdentifiers = [[NSMutableArray alloc] init];
        _cachedRowHeights = [[NSCache alloc] init];
        
        _outlineView = outlineView;
        _outlineView.delegate = self;
        _outlineView.dataSource = self;
        
        [_outlineView setTarget:self];
        [_outlineView setAction:@selector(outlineViewDidSelectItem)];
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (NSOutlineView *)outlineView {
    return _outlineView;
}

#pragma mark - Local methods

- (void)registerForRow:(id<OutlineViewRowProtocols>)row {
    NSString *reuseIdentifier = row.reuseIdentifier;
    
    if ([_registeredRowIdentifiers containsObject:reuseIdentifier] == NO) {
        [_registeredRowIdentifiers addObject:reuseIdentifier];
    }
    
    if ([self.outlineView makeViewWithIdentifier:reuseIdentifier owner:self] == nil) {
        [self.outlineView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(row.cellType) bundle:nil] forIdentifier:reuseIdentifier];
    }
}

#pragma mark - OutlineViewManager methods

- (void)addRow:(id<OutlineViewRowProtocols>)row {
    if ([_rows containsObject:row] == NO) {
        [_rows addObject:row];
    }
}

- (void)addRow:(id<OutlineViewRowProtocols>)row atIndex:(NSInteger)index {
    if ([_rows containsObject:row] == NO) {
        [_rows insertObject:row atIndex:index];
    }
}

- (void)removeRow:(id<OutlineViewRowProtocols>)row {
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
    [_cachedRowHeights removeAllObjects];
    
    [self.outlineView reloadData];
}

#pragma mark - NSOutlineViewDataSource, NSOutlineViewDelegate

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
        return ((id<OutlineViewRowProtocols>)item).childRows.count;
    }
    
    return _rows.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
        return [((id<OutlineViewRowProtocols>)item).childRows objectAtIndex:index];
    }
    
    return [_rows objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
        return ((id<OutlineViewRowProtocols>)item).childRows.count > 0;
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return NO;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
        id<OutlineViewRowProtocols> rowView = (id<OutlineViewRowProtocols>)item;
        
        if ([_cachedRowHeights objectForKey:rowView] && [[_cachedRowHeights objectForKey:rowView] isKindOfClass:[NSNumber class]]) {
            return [((NSNumber *)[_cachedRowHeights objectForKey:rowView]) doubleValue];
        }
        
        return rowView.rowHeight;
    }
    
    return 0.0;
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:heightForRow:atIndex:)]) {
        id item = [outlineView itemAtRow:row];
        
        if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
            id<OutlineViewRowProtocols> rowView = (id<OutlineViewRowProtocols>)item;
            
            if ([_cachedRowHeights objectForKey:rowView] == nil) {
                CGFloat rowHeight = [self.protocols outlineViewManager:self heightForRow:rowView atIndex:row];
                [_cachedRowHeights setObject:@(rowHeight) forKey:rowView];
                
                // Notify to the NSOutlineView reloads cell height
                [outlineView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
            }
        }
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayOutlineCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    [cell setTransparent:YES];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item {
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:rowViewForItem:)]) {
        return [self.protocols outlineViewManager:self rowViewForItem:item];
    }
    
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item {
    if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
        NSInteger row = [outlineView rowForItem:item];
        id<OutlineViewRowProtocols> rowView = (id<OutlineViewRowProtocols>)item;
        
        [self registerForRow:rowView];
        
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:rowView.reuseIdentifier owner:self];
        
        if ([cell conformsToProtocol:@protocol(ViewRowProtocols)] && [rowView respondsToSelector:@selector(configure:atIndex:)]) {
            [rowView configure:(id<ViewRowProtocols>)cell atIndex:row];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemDidExpand:)]) {
        [self.protocols outlineViewManager:self itemDidExpand:notification];
    }
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:itemDidCollapse:)]) {
        [self.protocols outlineViewManager:self itemDidCollapse:notification];
    }
}

#pragma mark - Actions

- (void)outlineViewDidSelectItem {
    if (self.protocols && [self.protocols respondsToSelector:@selector(outlineViewManager:didSelectRow:atIndex:)]) {
        NSInteger row = [self.outlineView selectedRow];
        id item = [self.outlineView itemAtRow:row];
        
        if ([item conformsToProtocol:@protocol(OutlineViewRowProtocols)]) {
            id<OutlineViewRowProtocols> rowView = (id<OutlineViewRowProtocols>)item;
            
            [self.protocols outlineViewManager:self didSelectRow:rowView atIndex:row];
        }
    }
}

@end
