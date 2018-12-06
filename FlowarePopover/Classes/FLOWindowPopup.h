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

@property (nonatomic, assign, readonly) NSRect frame;
@property (nonatomic, assign, readonly, getter = isShown) BOOL shown;


@property (nonatomic, assign) BOOL alwaysOnTop;
@property (nonatomic, assign) BOOL shouldShowArrow;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL animatedForwarding;
@property (nonatomic, assign) BOOL staysInApplicationRect;
@property (nonatomic, assign) BOOL updatesFrameWhileShowing;
@property (nonatomic, assign) BOOL shouldRegisterSuperviewObservers;
@property (nonatomic, assign) BOOL shouldChangeSizeWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;
@property (nonatomic, assign) BOOL closesWhenApplicationResizes;

/**
 * Make the popover movable.
 */
@property (nonatomic, assign) BOOL isMovable;

/**
 * Make the popover detach from its parent window.
 */
@property (nonatomic, assign) BOOL isDetachable;

/**
 * Make the popover become key window. Only apply for FLOWindowPopover type.
 */
@property (nonatomic, assign) BOOL canBecomeKey;

/**
 * Set tag for the popover window. Only apply for FLOWindowPopover type.
 */
@property (nonatomic, assign) NSInteger tag;

#pragma mark - Display

/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level;

@end
