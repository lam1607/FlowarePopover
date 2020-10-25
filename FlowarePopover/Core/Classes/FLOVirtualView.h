//
//  FLOVirtualView.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 7/19/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

@interface FLOVirtualView : NSView

/// Describe the normal or disable state for view (receives all events instead of those below).
///
@property (nonatomic, assign, readonly) FLOVirtualViewType type;

/**
 * Initialize the FLOVirtualView with specific type.
 *
 * @param frameRect the view controller needs displayed on FLOPopover
 * @param type describe the normal or disable view (receives all events instead of those below)
 * @return FLOVirtualView instance
 */
- (instancetype)initWithFrame:(NSRect)frameRect type:(FLOVirtualViewType)type;

@end
