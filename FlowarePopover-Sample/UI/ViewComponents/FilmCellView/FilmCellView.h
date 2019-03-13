//
//  FilmCellView.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FilmCellViewProtocols.h"

#import "ItemCellViewProtocols.h"

@interface FilmCellView : NSCollectionViewItem <FilmCellViewProtocols, ItemCellViewProtocols>

/// Methods
///
- (CGFloat)getViewItemHeight;

@end
