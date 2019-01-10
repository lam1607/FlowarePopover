//
//  OutlineViewRowProtocols.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef OutlineViewRowProtocols_h
#define OutlineViewRowProtocols_h

#import "ViewRowProtocols.h"

#import "AbstractViewRowProtocols.h"

@class OutlineViewRow;

@protocol OutlineViewRowProtocols <AbstractViewRowProtocols>

@optional

/// @property
///
@property (nonatomic, assign, readonly) BOOL hasChildren;
@property (nonatomic, strong) NSMutableArray<OutlineViewRow *> *childRows;

/// Methods
///

@end

#endif /* OutlineViewRowProtocols_h */
