//
//  CollectionViewRowProtocols.h
//  DatasourceDemo
//
//  Created by Lam Nguyen on 1/5/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#ifndef CollectionViewRowProtocols_h
#define CollectionViewRowProtocols_h

#import "ViewRowProtocols.h"

#import "AbstractViewRowProtocols.h"

@protocol CollectionViewRowProtocols <AbstractViewRowProtocols>

@optional

/// @property
///
@property (nonatomic, assign) NSSize estimatedItemSize;

/// Methods
///

@end

#endif /* CollectionViewRowProtocols_h */
