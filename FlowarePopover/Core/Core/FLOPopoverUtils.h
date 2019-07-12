//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

@protocol FLOPopoverProtocols;
@class FLOPopoverView;

@interface FLOPopoverUtils : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id<FLOPopoverProtocols> popover;

@property (nonatomic, strong, readonly) NSWindow *mainWindow;
@property (nonatomic, assign, readonly) BOOL mainWindowResized;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign) BOOL userInteractionEnable;

/**
 * The target window that the popover will be added on.
 */
@property (nonatomic, strong) NSWindow *presentedWindow;
@property (nonatomic, assign) FLOPopoverStyle popoverStyle;

@property (nonatomic, assign) BOOL popoverMoved;
@property (nonatomic, assign) BOOL staysInApplicationFrame;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationType animationType;
@property (nonatomic, assign) BOOL animatedInAppFrame;

@property (nonatomic, assign) BOOL needAutoresizingMask;

@property (nonatomic, strong) NSView *positioningAnchorView;
@property (nonatomic, strong) NSView *senderView;
@property (nonatomic, assign) FLOPopoverRelativePositionType relativePositionType;

@property (nonatomic, strong) FLOPopoverView *backgroundView;
@property (nonatomic, assign) NSRect positioningFrame;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGSize originalViewSize;

#pragma mark - Initialize

- (instancetype)initWithPopover:(id<FLOPopoverProtocols>)popover;

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
- (void)registerObserverForClipViews;

#pragma mark - Display utilities

- (void)setupComponentsForPopover;
- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType;
- (void)setUserInteractionEnable:(BOOL)isEnable;
- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state;
- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition;
- (NSRect)popoverFrameForEdge:(NSRectEdge)popoverEdge;
- (NSRect)popoverFrame;
- (NSRect)p_popoverFrameForEdge:(NSRectEdge *)popoverEdge;
- (NSRect)p_popoverFrame;
- (void)p_backgroundViewShouldUpdate:(BOOL)updated;

#pragma mark - Event monitor

- (void)registerApplicationActiveNotification;
- (void)removeApplicationActiveNotification;
- (void)registerSuperviewObservers;
- (void)unregisterSuperviewObservers;
- (void)registerWindowEvents;
- (void)removeWindowEvents;

@end
