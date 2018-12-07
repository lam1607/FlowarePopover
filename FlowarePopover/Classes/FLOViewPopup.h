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
 * Make Popover window key as possible when mouse entered to popover.
 * @note Becareful when using this property. If you have some views also implemented the
 * [mouseEntered:], [mouseExited:] methods. It might lead some unexpected behaviours.
 */
@property (nonatomic, assign) BOOL makeKeyWindowOnMouseEvents;

/**
 * Make the popover movable.
 */
@property (nonatomic, assign) BOOL isMovable;

/**
 * Make the popover detach from its parent window.
 */
@property (nonatomic, assign) BOOL isDetachable;

@end
