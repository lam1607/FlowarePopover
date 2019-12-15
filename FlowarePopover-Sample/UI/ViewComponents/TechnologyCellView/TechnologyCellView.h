//
//  TechnologyCellView.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "TechnologyCellViewProtocols.h"

#import "ItemCellViewProtocols.h"

@interface TechnologyCellView : NSTableCellView <TechnologyCellViewProtocols, ItemCellViewProtocols>

/// @property
///

/// Methods
///
- (CGFloat)getCellHeight;

@end
