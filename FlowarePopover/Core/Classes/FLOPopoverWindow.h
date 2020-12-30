//
//  FLOPopoverWindow.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol FLOPopoverProtocols;

@interface FLOPopoverWindow : NSWindow

@property (nonatomic, weak, readonly) id<FLOPopoverProtocols> responder;

@property (nonatomic, assign) BOOL canBecomeKey;
@property (nonatomic, assign) NSInteger tag;

/// Determine whether the popover can be interacted.
@property (nonatomic, assign) BOOL userInteractionEnable;

/// The dim color of disable view when the popover interaction is disabled.
@property (nonatomic, strong) NSColor *disabledColor;

/// This property is used out side of this scope for handling
/// whether the popover floats or not when application resigns active.
@property (nonatomic, assign) BOOL floatsWhenAppResignsActive;

- (void)setResponder:(id<FLOPopoverProtocols>)responder;

/// Invalidate the popover shadow in case of changing position of popover arrow
/// or other case the popover shadow not updated when popover moves.
- (void)invalidateShadow;

@end
