//
//  FLOWindowPopup.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

#import "FLOPopoverService.h"

@interface FLOWindowPopup : NSResponder <FLOPopoverService>

@property (nonatomic, readonly, getter = isShown) BOOL shown;

@property (nonatomic, assign) BOOL alwaysOnTop;
@property (nonatomic, assign) BOOL shouldShowArrow;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL animatedForwarding;
@property (nonatomic, assign) BOOL shouldChangeFrameWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;
@property (nonatomic, assign) BOOL closesWhenApplicationResizes;

/**
 * Make the popover movable.
 */
@property (nonatomic, assign) BOOL popoverMovable;

/**
 * Make the popover detach from its parent window. Only apply for FLOWindowPopover type.
 */
@property (nonatomic, assign) BOOL popoverShouldDetach;

/**
 * Make the popover become key window. Only apply for FLOWindowPopover type.
 */
@property (nonatomic, assign) BOOL canBecomeKey;

#pragma mark - Display

/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level;

@end
