//
//  ListSupplierProtocol.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 3/13/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef ListSupplierProtocol_h
#define ListSupplierProtocol_h

#import <Foundation/Foundation.h>

@protocol ListSupplierProtocol <NSObject>

@optional
- (__unsafe_unretained id<ListSupplierProtocol>)lsp_parent;
- (__unsafe_unretained NSMutableArray<id<ListSupplierProtocol>> *)lsp_childs;

@end

#endif /* ListSupplierProtocol_h */
