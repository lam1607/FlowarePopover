//
//  DataProvider.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "DataProviderProtocols.h"

@protocol ListSupplierProtocol;

@interface DataProvider : NSObject <DataProviderProtocols>

/// @property
///

/// Initializes
///
- (instancetype)initProviderForOwner:(id _Nonnull)owner;

/// DataProvider methods
///
- (void)buildDataSource;
- (void)clearDataSource;
- (NSInteger)numberOfSections;
- (BOOL)isKindOfTreeDataSource;

/// Supplier object obtaining
///
- (id<ListSupplierProtocol>)objectForRow:(NSInteger)row;
- (NSArray<id<ListSupplierProtocol>> *)objectsForRowIndexes:(NSIndexSet *)rowIndexes;
- (id<ListSupplierProtocol>)objectForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray<id<ListSupplierProtocol>> *)objectsForItemAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

/// Supplier object handler
///
- (BOOL)insertObject:(id<ListSupplierProtocol>)object;
- (BOOL)insertObjects:(NSArray<id<ListSupplierProtocol>> *)objects;
- (BOOL)insertObject:(id<ListSupplierProtocol>)object forRow:(NSInteger)row;
- (BOOL)insertObjects:(NSArray<id<ListSupplierProtocol>> *)objects forRow:(NSInteger)row;

- (BOOL)removeObject:(id<ListSupplierProtocol>)object;
- (BOOL)removeObjects:(NSArray<id<ListSupplierProtocol>> *)objects;
- (BOOL)removeObjectForRow:(NSInteger)row;
- (BOOL)removeObjectsForRowIndexes:(NSIndexSet *)rowIndexes;
- (BOOL)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)removeObjectsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths;

@end
