//
//  FLOViewPopup.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

#import "FLOPopoverService.h"

@interface FLOViewPopup : NSResponder <FLOPopoverService>

@property (nonatomic, assign, readonly) NSRect frame;
@property (nonatomic, assign, readonly, getter = isShown) BOOL shown;

/**
 * The positioning frame that used in displaying function. (only available for given frame displaying).
 */
@property (nonatomic, assign, readonly) NSRect initialPositioningRect;


@property (nonatomic, assign) BOOL alwaysOnTop;
@property (nonatomic, assign) BOOL shouldShowArrow;
@property (nonatomic, assign) NSSize arrowSize;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL animatedForwarding;
@property (nonatomic, assign) BOOL staysInApplicationRect;
@property (nonatomic, assign) BOOL updatesFrameWhileShowing;
@property (nonatomic, assign) BOOL shouldRegisterSuperviewObservers;
@property (nonatomic, assign) BOOL shouldChangeSizeWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;
@property (nonatomic, assign) BOOL closesWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenNotBelongToApplicationFrame;

/**
 * Make the popover movable.
 */
@property (nonatomic, assign) BOOL isMovable;

/**
 * Make the popover detach from its parent window.
 */
@property (nonatomic, assign) BOOL isDetachable;

/**
 * Set tag for the popover.
 */
@property (nonatomic, assign) NSInteger tag;

/**
 * Make transition animation by moving frame of the popover instead of using CALayer.
 */
@property (nonatomic, assign) BOOL animatedByMovingFrame;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) BOOL needAutoresizingMask;

@end
