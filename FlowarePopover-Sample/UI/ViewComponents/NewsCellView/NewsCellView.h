//
//  NewsCellView.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "NewsCellViewProtocols.h"

#import "ItemCellViewProtocols.h"

@interface NewsCellView : NSTableCellView <NewsCellViewProtocols, ItemCellViewProtocols>

/// @property
///

/// Methods
///
- (CGFloat)getCellHeight;

@end
