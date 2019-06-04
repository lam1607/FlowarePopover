//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLOPopoverConstants.h"

@class FLOPopoverBackgroundView;

@interface FLOPopoverUtils : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSWindow *appMainWindow;

@property (nonatomic, strong, readonly) NSWindow *topWindow;
@property (nonatomic, strong, readonly) NSView *topView;

@property (nonatomic, assign, readonly) BOOL appMainWindowResized;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

/**
 * The target window that the popover will be added on.
 */
@property (nonatomic, strong) NSWindow *presentedWindow;
@property (nonatomic, assign) FLOPopoverStyle popoverStyle;

@property (nonatomic, assign) BOOL popoverMoved;

@property (nonatomic, assign) BOOL shouldShowArrowWithVisualEffect;
@property (nonatomic, assign) NSVisualEffectMaterial arrowVisualEffectMaterial;
@property (nonatomic, assign) NSVisualEffectBlendingMode arrowVisualEffectBlendingMode;
@property (nonatomic, assign) NSVisualEffectState arrowVisualEffectState;

@property (nonatomic, assign) BOOL staysInApplicationFrame;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationType animationType;
@property (nonatomic, assign) BOOL animatedInAppFrame;

@property (nonatomic, assign) BOOL needAutoresizingMask;

@property (nonatomic, strong) NSView *positioningAnchorView;
@property (nonatomic, strong) NSView *senderView;
@property (nonatomic, assign) FLOPopoverRelativePositionType relativePositionType;
@property (nonatomic, assign) NSRect positioningWindowFrame;
@property (nonatomic, strong) NSMutableArray<NSView *> *anchorSuperviews;

@property (nonatomic, strong) FLOPopoverBackgroundView *backgroundView;
@property (nonatomic, assign) NSRect positioningFrame;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic) NSRectEdge preferredEdge;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize originalViewSize;
@property (nonatomic, assign) CGFloat verticalMarginOutOfPopover;
@property (nonatomic, assign) BOOL containerBoundsChangedByNotification;


+ (FLOPopoverUtils *)sharedInstance;

- (void)setTopmostWindow:(NSWindow *)topmostWindow;
- (void)setTopmostView:(NSView *)topmostView;
- (void)setAppMainWindowResized:(BOOL)appMainWindowResized;

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (void)calculateTransitionFrame:(NSRect *)transitionFrame fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (BOOL)treeOfView:(NSView *)view containsPosition:(NSPoint)position;
- (BOOL)view:(NSView *)parent contains:(NSView *)child;
- (BOOL)views:(NSArray *)views contain:(NSView *)view;
- (BOOL)window:(NSWindow *)parent contains:(NSWindow *)child;
- (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window;
- (NSVisualEffectView *)contentViewDidContainVisualEffect;
- (void)addView:(NSView *)view toParent:(NSView *)parentView;
- (void)addView:(NSView *)view toParent:(NSView *)parentView autoresizingMask:(BOOL)isAutoresizingMask;
- (void)addView:(NSView *)view toParent:(NSView *)parentView centerAutoresizingMask:(BOOL)isCenterAutoresizingMask;
- (void)setupAutoresizingMaskIfNeeded:(BOOL)needed;
- (void)resetContainerBoundsChangedByNotification;

#pragma mark - Display utilities

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType;
- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition;
- (NSRect)popoverFrameForEdge:(NSRectEdge)popoverEdge;
- (NSRect)popoverFrame;
- (NSRect)p_popoverFrameForEdge:(NSRectEdge *)popoverEdge;
- (NSRect)p_popoverFrame;
- (void)p_backgroundViewShouldUpdate:(BOOL)updated;

@end
