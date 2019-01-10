//
//  TechnologyCellView.h
//  FlowarePopover-Sample
//
//  Created by Lam Nguyen on 1/10/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TechnologyCellViewProtocols.h"

#import "ViewRowProtocols.h"

@interface TechnologyCellView : NSTableCellView <TechnologyCellViewProtocols, ViewRowProtocols>

/// Methods
///
- (CGFloat)getCellHeight;

@end
