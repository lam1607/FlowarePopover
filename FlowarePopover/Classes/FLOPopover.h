//
//  FLOPopover.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"
#import "FLOPopoverView.h"
#import "FLOPopoverWindow.h"

@class FLOPopover;

@protocol FLOPopoverDelegate <NSObject>

@optional
- (void)floPopoverWillShow:(FLOPopover *)popover;
- (void)floPopoverDidShow:(FLOPopover *)popover;
- (void)floPopoverWillClose:(FLOPopover *)popover;
- (void)floPopoverDidClose:(FLOPopover *)popover;

@end

@protocol FLOPopoverDelegate;

@interface FLOPopover : NSResponder

@property (weak, readwrite) id<FLOPopoverDelegate> delegate;

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSView *contentView;
@property (nonatomic, strong, readonly) NSViewController *contentViewController;
@property (nonatomic, assign, readonly) FLOPopoverType type;
@property (nonatomic, assign, readonly) NSRect frame;
@property (nonatomic, assign, readonly, getter = isShown) BOOL shown;
@property (nonatomic, assign, readonly) BOOL isMoved;


@property (nonatomic, assign) BOOL alwaysOnTop;
@property (nonatomic, assign) BOOL shouldShowArrow;
@property (nonatomic, assign) NSSize arrowSize;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL animatedForwarding;
@property (nonatomic, assign) CGFloat bottomOffset;
@property (nonatomic, assign) BOOL displaysInsideClipView;

/**
 * Determine whether the popover should stay in application frame or screen frame.
 * Default value of staysInApplicationFrame is NO, it means that the popover will stay inside the screen frame.
 */
@property (nonatomic, assign) BOOL staysInApplicationFrame;
@property (nonatomic, assign) BOOL updatesFrameWhileShowing;
@property (nonatomic, assign) BOOL shouldRegisterSuperviewObservers;
@property (nonatomic, assign) BOOL shouldChangeSizeWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;
@property (nonatomic, assign) BOOL closesWhenApplicationResizes;
@property (nonatomic, assign) BOOL closesWhenNotBelongToContainerFrame;
@property (nonatomic, assign) BOOL closesWhenReceivesEvent;
@property (nonatomic, assign) NSTimeInterval closesAfterTimeInterval;
@property (nonatomic, assign) BOOL cancelClosesAfterTimeIntervalWhenMoving;
@property (nonatomic, assign) BOOL resignsFieldsOnClosing;

/**
 * Make Popover window become key, order front and also activate the application.
 * Only available for FLOWindowPopover
 */
@property (nonatomic, assign) BOOL becomesKeyAfterDisplaying;

/**
 * Make popover become key, order front when mouse hovers the popover
 */
@property (nonatomic, assign) BOOL becomesKeyOnMouseOver;

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
 * Set tag for the popover.
 */
@property (nonatomic, assign) NSInteger tag;

/**
 * Make transition animation by moving frame of the popover instead of using CALayer.
 */
@property (nonatomic, assign) BOOL animatedByMovingFrame;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, assign) BOOL needAutoresizingMask;

#pragma mark - Initialize

/**
 * Initialize the FLOPopover with content view and type is FLOViewPopover by default.
 *
 * @param contentView the view needs displayed on FLOPopover
 * @return FLOPopover instance
 */
- (id)initWithContentView:(NSView *)contentView;
- (id)initWithContentView:(NSView *)contentView type:(FLOPopoverType)type;

/**
 * Initialize the FLOPopover with content view controller and type is FLOViewPopover by default.
 *
 * @param contentViewController the view controller needs displayed on FLOPopover
 * @return FLOPopover instance
 */
- (id)initWithContentViewController:(NSViewController *)contentViewController;
- (id)initWithContentViewController:(NSViewController *)contentViewController type:(FLOPopoverType)type;

#pragma mark - Display

/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level;

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType;
- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInAppFrame:(BOOL)animatedInAppFrame;


/**
 * Update the popover to new contentView while it's displaying.
 *
 * @param contentView the new content view needs displayed on the popover.
 */
- (void)setPopoverContentView:(NSView *)contentView;
- (void)setPopoverContentViewController:(NSViewController *)contentViewController;

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize;
- (void)setPopoverPositioningRect:(NSRect)rect;
- (void)setPopoverPositioningView:(NSView *)positioningView positioningRect:(NSRect)rect;
- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect;
- (void)setUserInteractionEnable:(BOOL)isEnable;

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state;


/**
 * Sticking rect: Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 *
 * @note rect is bounds of positioningView.
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType;

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @warning If you provide the wrong positioningView (sender) view, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect;

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param relativePositionType the specific position that the popover should be displayed relatively to positioningView.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @note If relativePositionType is FLOPopoverRelativePositionAutomatic. It means that the anchor view constraints will be calculated automatically based on the given frame.
 * @warning If you provide the wrong positioningView, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect relativePositionType:(FLOPopoverRelativePositionType)relativePositionType;

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param sender view that sends event for showing the popover.
 *
 * @note positioningView and sender are different together.
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @warning If you provide the wrong positioningView, sender, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender;

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param sender view that sends event for showing the popover.
 * @param relativePositionType the specific position that the popover should be displayed relatively to positioningView.
 *
 * @note positioningView and sender are different together.
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @note If relativePositionType is FLOPopoverRelativePositionAutomatic. It means that the anchor view constraints will be calculated automatically based on the given frame.
 * @warning If you provide the wrong positioningView, sender, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender relativePositionType:(FLOPopoverRelativePositionType)relativePositionType;

/**
 * Display popover as system alert style for presented window.
 *
 * @param presentedWindow the target window that the popover will be alerted on.
 */
- (void)showWithAlertStyleForWindow:(NSWindow *)presentedWindow;

- (void)close;

@end
