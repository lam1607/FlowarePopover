//
//  OutlineViewManager.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/4/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OutlineViewManager;
@protocol OutlineViewRowProtocols;

@protocol OutlineViewManagerProtocols <NSObject>

@optional
- (CGFloat)outlineViewManager:(OutlineViewManager *)manager heightForRow:(id<OutlineViewRowProtocols>)rowView atIndex:(NSInteger)index;
- (NSTableRowView *)outlineViewManager:(OutlineViewManager *)manager rowViewForItem:(id)item;
- (void)outlineViewManager:(OutlineViewManager *)manager didSelectRow:(id<OutlineViewRowProtocols>)rowView atIndex:(NSInteger)index;
- (void)outlineViewManager:(OutlineViewManager *)manager itemDidExpand:(NSNotification *)notification;
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
- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView;

/// OutlineViewManager methods
///
- (void)addRow:(id<OutlineViewRowProtocols>)row;
- (void)addRow:(id<OutlineViewRowProtocols>)row atIndex:(NSInteger)index;
- (void)removeRow:(id<OutlineViewRowProtocols>)row;
- (void)removeRowAtIndex:(NSInteger)index;

- (void)reloadData;

@end
