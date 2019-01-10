//
//  TableViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TableViewManager;
@protocol TableViewRowProtocols;

@protocol TableViewManagerProtocols <NSObject>

@optional
- (CGFloat)tableViewManager:(TableViewManager *)manager heightForRow:(id<TableViewRowProtocols>)rowView atIndex:(NSInteger)index;
- (NSTableRowView *)tableViewManager:(TableViewManager *)manager rowViewForRow:(NSInteger)row;
- (void)tableViewManager:(TableViewManager *)manager didSelectRow:(id<TableViewRowProtocols>)rowView atIndex:(NSInteger)index;

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
- (instancetype)initWithTableView:(NSTableView *)tableView;

/// TableViewManager methods
///
- (void)addRow:(id<TableViewRowProtocols>)row;
- (void)addRow:(id<TableViewRowProtocols>)row atIndex:(NSInteger)index;
- (void)removeRow:(id<TableViewRowProtocols>)row;
- (void)removeRowAtIndex:(NSInteger)index;

- (void)reloadData;

@end
