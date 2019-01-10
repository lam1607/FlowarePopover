//
//  NewsCellView.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/24/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NewsCellViewProtocols.h"

#import "ViewRowProtocols.h"

@interface NewsCellView : NSTableCellView <NewsCellViewProtocols, ViewRowProtocols>

/// Methods
///
- (CGFloat)getCellHeight;

@end
