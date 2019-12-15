//
//  DataProviderProtocols.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 3/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef DataProviderProtocols_h
#define DataProviderProtocols_h

@protocol ListSupplierProtocol;

@protocol DataProviderProtocols <NSObject>

@optional
/// @property
///
@property (nonatomic, weak, readonly) NSArray<id<ListSupplierProtocol>> *dataSource;
@property (nonatomic, weak, readonly) id owner;

/// Methods
///
- (NSMutableArray<id<ListSupplierProtocol>> *)dataSourceForProvider:(id<DataProviderProtocols>)provider;
- (NSInteger)numberOfSectionsForProvider:(id<DataProviderProtocols>)provider;

@end

#endif /* DataProviderProtocols_h */
