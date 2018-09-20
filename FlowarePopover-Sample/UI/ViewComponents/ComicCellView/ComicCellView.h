//
//  ComicCellView.h
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 9/18/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Comic;

@interface ComicCellView : NSTableCellView

- (void)updateUIWithData:(Comic *)comic;

@end
