//
//  TableViewManager.m
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TableViewManager.h"

#import "TableViewRowProtocols.h"

@interface TableViewManager () {
    NSMutableArray<id<TableViewRowProtocols>> *_rows;
    NSMutableArray<NSString *> *_registeredRowIdentifiers;
    NSCache *_cachedRowHeights;
}

/// @property
///
@property (nonatomic, weak, readwrite) NSTableView *tableView;

@end

@implementation TableViewManager

#pragma mark - Initialize

- (instancetype)initWithTableView:(NSTableView *)tableView {
    if (self = [super init]) {
        _rows = [[NSMutableArray alloc] init];
        _registeredRowIdentifiers = [[NSMutableArray alloc] init];
        _cachedRowHeights = [[NSCache alloc] init];
        
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView setTarget:self];
        [_tableView setAction:@selector(tableViewDidSelectItem)];
    }
    
    return self;
}

#pragma mark - Getter/Setter

- (NSTableView *)tableView {
    return _tableView;
}

#pragma mark - Local methods

- (void)registerForRow:(id<TableViewRowProtocols>)row {
    NSString *reuseIdentifier = row.reuseIdentifier;
    
    if ([_registeredRowIdentifiers containsObject:reuseIdentifier] == NO) {
        [_registeredRowIdentifiers addObject:reuseIdentifier];
    }
    
    if ([self.tableView makeViewWithIdentifier:reuseIdentifier owner:self] == nil) {
        [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:NSStringFromClass(row.cellType) bundle:nil] forIdentifier:reuseIdentifier];
    }
}

#pragma mark - TableViewManager methods

- (void)addRow:(id<TableViewRowProtocols>)row {
    if ([_rows containsObject:row] == NO) {
        [_rows addObject:row];
    }
}

- (void)addRow:(id<TableViewRowProtocols>)row atIndex:(NSInteger)index {
    if ([_rows containsObject:row] == NO) {
        [_rows insertObject:row atIndex:index];
    }
}

- (void)removeRow:(id<TableViewRowProtocols>)row {
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
    
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource, NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _rows.count;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([_cachedRowHeights objectForKey:@(row)] && [[_cachedRowHeights objectForKey:@(row)] isKindOfClass:[NSNumber class]]) {
        return [((NSNumber *)[_cachedRowHeights objectForKey:@(row)]) doubleValue];
    }
    
    id<TableViewRowProtocols> rowView = [_rows objectAtIndex:row];
    
    return rowView.rowHeight;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:heightForRow:atIndex:)]) {
        if ([_cachedRowHeights objectForKey:@(row)] == nil) {
            CGFloat rowHeight = [self.protocols tableViewManager:self heightForRow:[_rows objectAtIndex:row] atIndex:row];
            [_cachedRowHeights setObject:@(rowHeight) forKey:@(row)];
            
            // Notify to the NSTableView reloads cell height
            [tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
        }
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:rowViewForRow:)]) {
        return [self.protocols tableViewManager:self rowViewForRow:row];
    }
    
    return nil;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    id<TableViewRowProtocols> rowView = [_rows objectAtIndex:row];
    
    [self registerForRow:rowView];
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:rowView.reuseIdentifier owner:self];
    
    if ([cell conformsToProtocol:@protocol(ViewRowProtocols)] && [rowView respondsToSelector:@selector(configure:atIndex:)]) {
        [rowView configure:(id<ViewRowProtocols>)cell atIndex:row];
    }
    
    return cell;
}

#pragma mark - Actions

- (void)tableViewDidSelectItem {
    if (self.protocols && [self.protocols respondsToSelector:@selector(tableViewManager:didSelectRow:atIndex:)]) {
        NSInteger row = [self.tableView selectedRow];
        id<TableViewRowProtocols> rowView = [_rows objectAtIndex:row];
        
        [self.protocols tableViewManager:self didSelectRow:rowView atIndex:row];
    }
}

@end
