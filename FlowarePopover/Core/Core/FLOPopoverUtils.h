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

@property (nonatomic, weak, readonly) NSWindow *mainWindow;
@property (nonatomic, assign, readonly) BOOL isCloseEventReceived;

@property (nonatomic, assign, readonly) NSRectEdge preferredEdge;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign, readonly) BOOL userInteractionEnable;

/**
 * The target window that the popover will be added on.
 */
@property (nonatomic, strong) NSWindow *presentedWindow;
@property (nonatomic, assign) FLOPopoverStyle popoverStyle;

@property (nonatomic, assign) BOOL popoverMoved;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationType animationType;
@property (nonatomic, assign) BOOL animatedInAppFrame;

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

- (NSMutableArray<NSView *> *)observerSuperviews;
- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (void)calculateTransitionFrame:(NSRect *)transitionFrame fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;

- (void)updateContentViewFrameInsets:(NSRectEdge)popoverEdge;
- (void)closePopoverWithTimerIfNeeded;
- (void)invalidateArrowPathColor;
- (void)setLocalUpdatedBlock:(void(^)(void))block;

#pragma mark - Display utilities

- (void)setResponder;
- (void)setupComponentsForPopover:(BOOL)observerNeeded;
- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType;

/// Determine whether the popover can be interacted.
- (void)setUserInteractionEnable:(BOOL)isEnable;

/// The dim color of disable view when the popover interaction is disabled.
- (void)setDisabledColor:(NSColor *)disabledColor;

- (void)showWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state;
- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition;
- (NSRect)popoverFrame;

#pragma mark - Event monitor

- (void)registerObserverForSuperviews;
- (void)registerApplicationEvents;
- (void)removeApplicationEvents;
- (void)registerContentViewEvents;
- (void)removeContentViewEvents;

@end
