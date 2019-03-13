//
//  ItemCellViewProtocols.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 3/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef ItemCellViewProtocols_h
#define ItemCellViewProtocols_h

#import <Foundation/Foundation.h>

@protocol ListSupplierProtocol;

@protocol ItemCellViewProtocols <NSObject>

@optional
- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndex:(NSInteger)index;
- (void)itemCellView:(id<ItemCellViewProtocols>)itemCellView updateWithData:(id<ListSupplierProtocol> _Nonnull)data atIndexPath:(NSIndexPath *)indexPath;

@end

#endif /* ItemCellViewProtocols_h */
