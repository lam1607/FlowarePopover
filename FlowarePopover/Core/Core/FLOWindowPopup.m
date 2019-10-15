//
//  FLOWindowPopup.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FLOWindowPopup.h"

#import "FLOExtensionsGraphicsContext.h"
#import "FLOExtensionsNSView.h"
#import "FLOExtensionsNSWindow.h"

#import "FLOPopoverView.h"
#import "FLOPopoverWindow.h"
#import "FLOVirtualView.h"


@interface FLOWindowPopup () <FLOPopoverViewDelegate, NSAnimationDelegate, CAAnimationDelegate> {
    FLOPopoverWindow *_popover;
}

@property (nonatomic, strong) NSEvent *localEvent;

@property (nonatomic, strong) FLOPopoverWindow *popoverWindow;
@property (nonatomic, assign) NSWindowLevel popoverWindowLevel;

/**
 * View that used for making animation with an animated layer.
 */
@property (nonatomic, strong) FLOVirtualView *snapshotView;

@end

@implementation FLOWindowPopup

@synthesize initialFrame = _initialFrame;
@synthesize utils = _utils;
@synthesize isShowing = _isShowing;
@synthesize isClosing = _isClosing;
@synthesize shouldShowArrow = _shouldShowArrow;
@synthesize arrowSize = _arrowSize;
@synthesize animated = _animated;
@synthesize animatedForwarding = _animatedForwarding;
@synthesize bottomOffset = _bottomOffset;
@synthesize floatsWhenAppResignsActive = _floatsWhenAppResignsActive;
@synthesize stopsAtContainerBounds = _stopsAtContainerBounds;
@synthesize staysInContainer = _staysInContainer;
@synthesize updatesFrameWhileShowing = _updatesFrameWhileShowing;
@synthesize shouldRegisterSuperviewObservers = _shouldRegisterSuperviewObservers;
@synthesize shouldChangeSizeWhenApplicationResizes = _shouldChangeSizeWhenApplicationResizes;
@synthesize closesWhenPopoverResignsKey = _closesWhenPopoverResignsKey;
@synthesize closesWhenApplicationBecomesInactive = _closesWhenApplicationBecomesInactive;
@synthesize closesWhenApplicationResizes = _closesWhenApplicationResizes;
@synthesize closesWhenNotBelongToContainer = _closesWhenNotBelongToContainer;
@synthesize closesWhenReceivesEvent = _closesWhenReceivesEvent;
@synthesize resignsFieldsOnClosing = _resignsFieldsOnClosing;
@synthesize becomesKeyAfterDisplaying = _becomesKeyAfterDisplaying;
@synthesize becomesKeyOnMouseOver = _becomesKeyOnMouseOver;
@synthesize isMovable = _isMovable;
@synthesize isDetachable = _isDetachable;
@synthesize detachableStyleMask = _detachableStyleMask;
@synthesize canBecomeKey = _canBecomeKey;
@synthesize tag = _tag;
@synthesize animatedByMovingFrame = _animatedByMovingFrame;
@synthesize animationDuration = _animationDuration;
@synthesize needsAutoresizingMask = _needsAutoresizingMask;

@synthesize willShowBlock;
@synthesize didShowBlock;
@synthesize willCloseBlock;
@synthesize didCloseBlock;
@synthesize didMoveBlock;
@synthesize didDetachBlock;

- (instancetype)init {
    if (self = [super init]) {
        _utils = [[FLOPopoverUtils alloc] initWithPopover:self];
        _shouldShowArrow = NO;
        _arrowSize = NSZeroSize;
        _animated = NO;
        _animatedForwarding = NO;
        _bottomOffset = kFlowarePopover_BottomOffset;
        _floatsWhenAppResignsActive = NO;
        _stopsAtContainerBounds = YES;
        _staysInContainer = NO;
        _updatesFrameWhileShowing = NO;
        _shouldRegisterSuperviewObservers = YES;
        _shouldChangeSizeWhenApplicationResizes = NO;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _closesWhenNotBelongToContainer = YES;
        _closesWhenReceivesEvent = NO;
        _resignsFieldsOnClosing = YES;
        _becomesKeyAfterDisplaying = YES;
        _isMovable = NO;
        _isDetachable = NO;
        _detachableStyleMask = NSNotFound;
        _canBecomeKey = YES;
        _tag = -1;
        _animatedByMovingFrame = NO;
        _animationDuration = 0.0;
        _needsAutoresizingMask = NO;
    }
    
    return self;
}

/**
 * Initialize the FLOWindowPopup with content view.
 *
 * @param contentView the view needs displayed on FLOWindowPopup
 * @return FLOWindowPopup instance
 */
- (instancetype)initWithContentView:(NSView *)contentView {
    if (self = [self init]) {
        _utils.contentView = contentView;
        _utils.backgroundView = [[FLOPopoverView alloc] initWithFrame:contentView.frame];
    }
    
    return self;
}

/**
 * Initialize the FLOWindowPopup with content view controller.
 *
 * @param contentViewController the view controller needs displayed on FLOWindowPopup
 * @return FLOWindowPopup instance
 */
- (instancetype)initWithContentViewController:(NSViewController *)contentViewController {
    if (self = [self init]) {
        _utils.contentViewController = contentViewController;
        _utils.contentView = contentViewController.view;
        _utils.backgroundView = [[FLOPopoverView alloc] initWithFrame:contentViewController.view.frame];
    }
    
    return self;
}

- (void)dealloc {
    self.localEvent = nil;
    self.utils = nil;
    
    [self.popoverWindow close];
    self.popoverWindow = nil;
    
    willShowBlock = nil;
    didShowBlock = nil;
    willCloseBlock = nil;
    didCloseBlock = nil;
    didMoveBlock = nil;
    didDetachBlock = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter/Setter

- (NSResponder *)representedObject {
    return self.popoverWindow;
}

- (NSRect)frame {
    return self.popoverWindow.frame;
}

- (BOOL)isShown {
    return self.popoverWindow.isVisible;
}

- (FLOPopoverType)type {
    return FLOWindowPopover;
}

- (BOOL)containsArrow {
    return (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView) && !NSEqualSizes(self.arrowSize, NSZeroSize));
}

- (BOOL)isCloseEventReceived {
    return self.utils.isCloseEventReceived;
}

- (NSMutableArray<NSClipView *> *)observerClipViews {
    return [self.utils observerClipViews];
}

- (void)setFloatsWhenAppResignsActive:(BOOL)floatsWhenAppResignsActive {
    _floatsWhenAppResignsActive = floatsWhenAppResignsActive;
    
    [self.popoverWindow setFloatsWhenAppResignsActive:floatsWhenAppResignsActive];
}

- (void)setShouldShowArrow:(BOOL)shouldShowArrow {
    _shouldShowArrow = shouldShowArrow;
    
    if (shouldShowArrow && NSEqualSizes(self.arrowSize, NSZeroSize)) {
        self.arrowSize = NSMakeSize(kFlowarePopover_ArrowWidth, kFlowarePopover_ArrowHeight);
    } else {
        self.arrowSize = NSZeroSize;
    }
}

- (void)setArrowSize:(NSSize)arrowSize {
    if (self.shouldShowArrow) {
        _arrowSize = arrowSize;
    } else {
        _arrowSize = NSZeroSize;
    }
}

- (void)setStaysInContainer:(BOOL)staysInContainer {
    _staysInContainer = staysInContainer;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    if ([self isShown]) {
        [self.popoverWindow setTag:tag];
    }
}

- (void)setBecomesKeyOnMouseOver:(BOOL)becomesKeyOnMouseOver {
    self.utils.backgroundView.becomesKeyOnMouseOver = becomesKeyOnMouseOver;
}

#pragma mark - Local methods

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    [self.utils setPopoverEdgeType:edgeType];
}

- (void)resetContentViewFrame:(NSNotification *)notification {
    NSSize contentSize = [self.utils.backgroundView contentViewSizeForSize:self.utils.originalViewSize];
    
    self.utils.contentView.frame = NSMakeRect(self.utils.contentView.frame.origin.x, self.utils.contentView.frame.origin.y, contentSize.width, contentSize.height);
    
    if ([notification.name isEqualToString:NSWindowWillCloseNotification] && (self.popoverWindow == notification.object)) {
        [self close];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    [self.utils setupPositioningAnchorWithView:positioningView positioningRect:positioningRect shouldUpdatePosition:shouldUpdatePosition];
}

- (void)updatePopoverFrame {
    if ([self isShown]) {
        if (self.updatesFrameWhileShowing || (!self.isShowing && !self.isClosing)) {
            [self displayWithAnimationProcess:NO];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePopoverFrame) object:nil];
            [self performSelector:@selector(updatePopoverFrame) withObject:nil afterDelay:0.1];
        }
    }
}

- (void)removeAnimationProcessIfNeeded:(BOOL)isNeeded {
    if (!isNeeded) return;
    
    if (self.snapshotView != nil) {
        [self.snapshotView removeFromSuperview];
        [[[[self.snapshotView layer] sublayers] lastObject] removeAllAnimations];
        [[[[self.snapshotView layer] sublayers] lastObject] removeFromSuperlayer];
        
        self.snapshotView = nil;
    }
    
    if ([[self.popoverWindow contentView] layer] != nil) {
        [[[self.popoverWindow contentView] layer] removeAllAnimations];
    }
    
    [self.popoverWindow setFrame:self.initialFrame display:YES];
}

#pragma mark - Display

/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level {
    self.popoverWindowLevel = level;
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInAppFrame:(BOOL)animatedInAppFrame {
    self.utils.animationBehaviour = animationBehaviour;
    self.utils.animationType = animationType;
    self.utils.animatedInAppFrame = animatedInAppFrame;
}

/**
 * Update the popover to new contentView while it's displaying.
 *
 * @param contentView the new content view needs displayed on the popover.
 */
- (void)setPopoverContentView:(NSView *)contentView {
    if (![contentView isKindOfClass:[NSView class]]) return;
    
    if ([self isShown] && !self.isShowing && !self.isClosing) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentView setFrame:self.utils.contentView.frame];
        
        self.utils.contentView = contentView;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([[self.utils.presentedWindow childWindows] containsObject:self.popoverWindow]) {
            [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        }
        
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    if (![contentViewController isKindOfClass:[NSViewController class]]) return;
    
    if ([self isShown] && !self.isShowing && !self.isClosing) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentViewController.view setFrame:self.utils.contentView.frame];
        
        self.utils.contentViewController = contentViewController;
        self.utils.contentView = contentViewController.view;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([[self.utils.presentedWindow childWindows] containsObject:self.popoverWindow]) {
            [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        }
        
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    if (NSEqualSizes(newSize, self.utils.contentSize)) return;
    
    if (!NSEqualSizes(newSize, NSZeroSize)) {
        self.utils.originalViewSize = newSize;
        self.utils.contentSize = newSize;
    }
    
    [self updatePopoverFrame];
}

- (void)setPopoverPositioningRect:(NSRect)rect {
    if (!NSEqualRects(rect, NSZeroRect)) {
        [self setupPositioningAnchorWithView:self.utils.positioningView positioningRect:rect shouldUpdatePosition:YES];
    }
    
    [self updatePopoverFrame];
}

- (void)setPopoverPositioningView:(NSView *)positioningView positioningRect:(NSRect)rect {
    if ((positioningView != nil) && (self.utils.positioningView != positioningView)) {
        if ((self.utils.positioningAnchorView != nil) && ([self.utils.positioningAnchorView isDescendantOf:self.utils.positioningView])) {
            [self.utils.positioningAnchorView removeFromSuperview];
            
            self.utils.positioningAnchorView = nil;
        }
        
        self.utils.positioningView = positioningView;
    }
    
    [self setPopoverPositioningRect:rect];
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
    if (!NSEqualSizes(newSize, NSZeroSize) && !NSEqualSizes(newSize, self.utils.contentSize)) {
        self.utils.originalViewSize = newSize;
        self.utils.contentSize = newSize;
    }
    
    [self setPopoverPositioningRect:rect];
}

- (void)setUserInteractionEnable:(BOOL)isEnable {
    self.popoverWindow.userInteractionEnable = isEnable;
    
    [self.utils setUserInteractionEnable:isEnable];
}

- (void)showWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    [self.utils showWithVisualEffect:needed material:material blendingMode:blendingMode state:state];
}

- (void)updateFrame:(NSRect)frame {
    [self.popoverWindow setFrame:frame display:YES];
}

- (void)invalidateShadow {
    // Because of [invalidateShadow] of NSWindow is not working,
    // We should do the trick as following to force the NSWindow re-renders its shadow.
    // Each time arrow's position of the popover updated.
    if (self.containsArrow) {
        NSRect frame = [self.popoverWindow frame];
        
        [self updateFrame:(NSRect){ .origin = frame.origin, .size = NSMakeSize(frame.size.width + 1.0, frame.size.height + 1.0) }];
        [self updateFrame:frame];
    }
}

/**
 * Sticking rect: Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 *
 * @note rect is bounds of positioningView (should be visibleRect of positioningView).
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    if ([self isShown]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self close];
        
        return;
    }
    
    if (!self.isShowing && !self.isClosing) {
        self.isShowing = YES;
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.positioningFrame = rect;
        self.utils.positioningView = positioningView;
        self.utils.positioningAnchorView = positioningView;
        self.utils.senderView = positioningView;
        self.utils.needsAutoresizingMask = self.needsAutoresizingMask;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopoverStyleNormal];
        [self.utils setResponder];
        
        // Wait for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.01];
        [self registerForApplicationEvents];
    }
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param sender view that sends event for showing the popover.
 * @param relativePositionType the specific position that the popover should be displayed relatively to positioningView.
 * @param edgeType 'position' that the popover should be displayed to the anchor view.
 *
 * @note positioningView and sender are different together.
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @note If relativePositionType is FLOPopoverRelativePositionAutomatic. It means that the anchor view constraints will be calculated automatically based on the given frame.
 * @warning If you provide the wrong positioningView, sender, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender relativePositionType:(FLOPopoverRelativePositionType)relativePositionType edgeType:(FLOPopoverEdgeType)edgeType {
    if ([self isShown]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self close];
        
        return;
    }
    
    if (!self.isShowing && !self.isClosing) {
        self.isShowing = YES;
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.relativePositionType = relativePositionType;
        
        [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
        
        self.utils.positioningFrame = [self.utils.positioningAnchorView bounds];
        self.utils.positioningView = positioningView;
        self.utils.senderView = sender;
        self.utils.needsAutoresizingMask = self.needsAutoresizingMask;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopoverStyleNormal];
        [self.utils setResponder];
        
        // Wait for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.01];
        [self registerForApplicationEvents];
    }
}

/**
 * Display popover as system alert style for presented window.
 *
 * @param presentedWindow the target window that the popover will be alerted on.
 * @param backgroundColor background color for alert window.
 */
- (void)showWithAlertStyleForWindow:(NSWindow *)presentedWindow backgroundColor:(NSColor *)backgroundColor {
    if ([presentedWindow isKindOfClass:[NSWindow class]]) {
        self.utils.presentedWindow = presentedWindow;
        self.utils.popoverStyle = FLOPopoverStyleAlert;
        self.utils.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.utils.animationType = FLOPopoverAnimationDefault;
        
        self.shouldShowArrow = NO;
        self.isMovable = NO;
        self.isDetachable = NO;
        self.animatedByMovingFrame = NO;
        
        [self setupPopoverStyleAlertWithColor:backgroundColor];
        [self.utils setResponder];
        
        _popover = self.popoverWindow;
        
        [self registerForApplicationEvents];
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)show {
    [self displayWithAnimationProcess:YES];
}

- (void)setupPopoverStyleNormal {
    [self.utils.backgroundView setFrame:(NSRect){ .size = self.utils.contentView.frame.size }];
    
    if (self.popoverWindow == nil) {
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:NSMakeRect(SHRT_MIN, SHRT_MIN, NSWidth(self.utils.contentView.frame), NSHeight(self.utils.contentView.frame)) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [self.popoverWindow setHasShadow:NO];
        [self.popoverWindow setReleasedWhenClosed:NO];
        [self.popoverWindow setOpaque:NO];
        [self.popoverWindow setBackgroundColor:[NSColor clearColor]];
        [self.popoverWindow setTag:self.tag];
        [self.popoverWindow setFloatsWhenAppResignsActive:self.floatsWhenAppResignsActive];
    }
    
    [self.utils addView:self.utils.contentView toParent:self.utils.backgroundView autoresizingMask:NO];
    [self.utils addView:self.utils.backgroundView toParent:[self.popoverWindow contentView] autoresizingMask:NO];
    
    if (![[self.utils.presentedWindow childWindows] containsObject:self.popoverWindow]) {
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    [self.utils setupAutoresizingMaskIfNeeded:YES];
    
    [self.popoverWindow setCanBecomeKey:self.canBecomeKey];
    [self.popoverWindow setLevel:self.popoverWindowLevel];
}

- (void)setupPopoverStyleAlertWithColor:(NSColor *)backgroundColor {
    [self.utils.backgroundView setFrame:(NSRect){ .size = self.utils.contentView.frame.size }];
    
    if (self.popoverWindow == nil) {
        NSRect frame = [self.utils.presentedWindow contentRectForFrameRect:self.utils.presentedWindow.frame];
        
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [self.popoverWindow setHasShadow:NO];
        [self.popoverWindow setReleasedWhenClosed:NO];
        [self.popoverWindow setOpaque:NO];
        [self.popoverWindow setBackgroundColor:[NSColor clearColor]];
        [self.popoverWindow setTag:self.tag];
        [self.popoverWindow setFloatsWhenAppResignsActive:self.floatsWhenAppResignsActive];
        [[self.popoverWindow contentView] setWantsLayer:YES];
        [[[self.popoverWindow contentView] layer] setBackgroundColor:[backgroundColor CGColor]];
    }
    
    [self.utils addView:self.utils.contentView toParent:self.utils.backgroundView centerAutoresizingMask:YES];
    [self.utils addView:self.utils.backgroundView toParent:[self.popoverWindow contentView] autoresizingMask:YES];
    
    if (![[self.utils.presentedWindow childWindows] containsObject:self.popoverWindow]) {
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    [self.popoverWindow setCanBecomeKey:self.canBecomeKey];
    [self.popoverWindow setLevel:self.popoverWindowLevel];
}

- (void)displayWithAnimationProcess:(BOOL)displayAnimated {
    _popover = self.popoverWindow;
    
    [self.utils setupComponentsForPopover:displayAnimated];
    
    if (displayAnimated) {
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (![self isShown]) return;
    if (self.isClosing || self.isShowing) return;
    
    if (self.resignsFieldsOnClosing) {
        // Use this trick for resigning first responder for all NSTextFields of popoverWindow
        [self.popoverWindow makeFirstResponder:nil];
    }
    
    self.isClosing = YES;
    
    if (willCloseBlock) willCloseBlock(self);
    
    _popover = nil;
    
    [self.utils setupAutoresizingMaskIfNeeded:NO];
    [self removeAllApplicationEvents];
    [self popoverShowing:NO animated:self.animated];
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    if (showing) {
        self.isShowing = NO;
        
        [self.popoverWindow setAlphaValue:1.0];
        
        if (self.becomesKeyAfterDisplaying) {
            [self.popoverWindow makeKeyAndOrderFront:nil];
        }
        
        if (self.utils.popoverStyle == FLOPopoverStyleNormal) {
            [self.utils setupAutoresizingMaskIfNeeded:YES];
        }
        
        if (didShowBlock) didShowBlock(self);
    } else {
        [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        
        [self resetContentViewFrame:nil];
        
        self.localEvent = nil;
        
        [self.utils.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.utils.backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.utils = nil;
        
        [self.popoverWindow close];
        self.popoverWindow = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        self.isClosing = NO;
        
        if (didCloseBlock) didCloseBlock(self);
    }
}

#pragma mark - Display animations

- (void)popoverShowing:(BOOL)showing animated:(BOOL)animated {
    if (animated) {
        [self.utils setupAutoresizingMaskIfNeeded:NO];
        
        switch (self.utils.animationBehaviour) {
            case FLOPopoverAnimationBehaviorTransform:
                [self popoverTransformAnimationShowing:showing];
                return;
            case FLOPopoverAnimationBehaviorTransition:
                [self popoverTransitionAnimationShowing:showing];
                return;
            default:
                [self popoverDefaultAnimationShowing:showing];
                return;
        }
    }
    
    [self popoverDidStopAnimation];
}

/*
 - FLOPopoverAnimationBehaviorTransform
 */
- (void)popoverTransformAnimationShowing:(BOOL)showing {
    if (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransform) {
        switch (self.utils.animationType) {
            case FLOPopoverAnimationRotate:
                break;
            case FLOPopoverAnimationFlip:
                break;
            default:
                [self popoverScalingAnimationShowing:showing];
                break;
        }
    }
}

- (void)popoverScalingAnimationShowing:(BOOL)showing {
    if ([self.snapshotView isDescendantOf:[self.popoverWindow contentView]]) {
        [[[[self.snapshotView layer] sublayers] lastObject] removeAllAnimations];
        [[[[self.snapshotView layer] sublayers] lastObject] removeFromSuperlayer];
    }
    
    CGFloat scaleFactor = showing ? 1.25 : 1.2;
    NSRect frame = self.popoverWindow.frame;
    CGFloat width = scaleFactor * frame.size.width;
    CGFloat height = scaleFactor * frame.size.height;
    CGFloat x = frame.origin.x - (width - frame.size.width) / 2;
    CGFloat y = frame.origin.y - (height - frame.size.height) / 2;
    NSRect scalingFrame = NSMakeRect(x, y, width, height);
    
    [self.popoverWindow setHasShadow:YES];
    [self.popoverWindow setAlphaValue:1.0];
    [self.popoverWindow setFrame:frame display:YES];
    [self.utils.backgroundView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    [self.popoverWindow setHasShadow:NO];
    [self.utils.contentView setAlphaValue:0.01];
    
    [self.popoverWindow setFrame:scalingFrame display:showing];
    
    NSRect layerFrame = [self.popoverWindow convertRectFromScreen:frame];
    CALayer *animatedLayer = [CALayer layer];
    [animatedLayer setContents:snapshotImage];
    [animatedLayer setFrame:layerFrame];
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[FLOVirtualView alloc] initWithFrame:(NSRect){ .size = scalingFrame.size } type:FLOVirtualViewAnimation];
    }
    
    
    [self.snapshotView setWantsLayer:YES];
    [self.snapshotView setFrame:(NSRect){ .size = scalingFrame.size }];
    [[self.snapshotView layer] addSublayer:animatedLayer];
    
    [[self.popoverWindow contentView] addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.utils.backgroundView];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:nil];
    [opacityAnimation setFillMode:kCAFillModeForwards];
    [opacityAnimation setRemovedOnCompletion:NO];
    [opacityAnimation setFromValue:@(showing ? 0.0 : 1.0)];
    [opacityAnimation setToValue:@(showing ? 1.0 : 0.0)];
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:nil];
    [transformAnimation setFillMode:kCAFillModeForwards];
    [transformAnimation setRemovedOnCompletion:NO];
    [transformAnimation setFromValue:(showing ? [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)] : [NSValue valueWithCATransform3D:CATransform3DIdentity])];
    [transformAnimation setToValue:(showing ? [NSValue valueWithCATransform3D:CATransform3DIdentity] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)])];
    
    NSTimeInterval duration = showing ? kFlowarePopover_AnimationTimeInterval : 0.15;
    
    if (self.animationDuration > 0) {
        duration = self.animationDuration;
    }
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if ([self.snapshotView isDescendantOf:[self.popoverWindow contentView]]) {
            [self.snapshotView removeFromSuperview];
            [[[[self.snapshotView layer] sublayers] lastObject] removeAllAnimations];
            [[[[self.snapshotView layer] sublayers] lastObject] removeFromSuperlayer];
            
            self.snapshotView = nil;
        }
        
        [self.popoverWindow setFrame:frame display:showing];
        
        [self popoverDidStopAnimation];
    }];
    
    [animatedLayer addAnimation:opacityAnimation forKey:@"opacity"];
    [animatedLayer addAnimation:transformAnimation forKey:@"transform"];
    
    [CATransaction commit];
    [NSAnimationContext endGrouping];
}

/*
 - FLOPopoverAnimationBehaviorTransition
 */
- (void)popoverTransitionAnimationShowing:(BOOL)showing {
    if (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        if (self.animatedByMovingFrame) {
            [self popoverTransitionAnimationFrameShowing:showing];
        } else {
            [self popoverTransitionAnimationShowing:showing animationType:self.utils.animationType];
        }
    }
}

- (void)popoverTransitionAnimationShowing:(BOOL)showing animationType:(FLOPopoverAnimationType)animationType {
    if ([self.snapshotView isDescendantOf:[self.popoverWindow contentView]]) {
        [[[[self.snapshotView layer] sublayers] lastObject] removeAllAnimations];
        [[[[self.snapshotView layer] sublayers] lastObject] removeFromSuperlayer];
    }
    
    NSRect frame = self.popoverWindow.frame;
    NSRect fromFrame = frame;
    NSRect toFrame = frame;
    
    [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    NSRect transitionFrame = frame;
    
    [self.utils calculateTransitionFrame:&transitionFrame fromFrame:fromFrame toFrame:toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    [self.popoverWindow setHasShadow:YES];
    [self.popoverWindow setAlphaValue:1.0];
    [self.popoverWindow setFrame:frame display:YES];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    [self.popoverWindow setHasShadow:NO];
    [self.utils.contentView setAlphaValue:0.01];
    
    [self.popoverWindow setFrame:transitionFrame display:YES];
    
    NSRect layerFrame = [self.popoverWindow convertRectFromScreen:fromFrame];
    CALayer *animatedLayer = [CALayer layer];
    [animatedLayer setContents:snapshotImage];
    [animatedLayer setFrame:layerFrame];
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[FLOVirtualView alloc] initWithFrame:(NSRect){ .size = transitionFrame.size } type:FLOVirtualViewAnimation];
    }
    
    [self.snapshotView setWantsLayer:YES];
    [self.snapshotView setFrame:(NSRect){ .size = transitionFrame.size }];
    [[self.snapshotView layer] addSublayer:animatedLayer];
    
    [[self.popoverWindow contentView] addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.utils.backgroundView];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:nil];
    [opacityAnimation setFillMode:kCAFillModeForwards];
    [opacityAnimation setRemovedOnCompletion:NO];
    [opacityAnimation setFromValue:@(showing ? 0.0 : 1.0)];
    [opacityAnimation setToValue:@(showing ? 1.0 : 0.0)];
    
    NSRect startFrame = [self.popoverWindow convertRectFromScreen:fromFrame];
    NSRect endFrame = [self.popoverWindow convertRectFromScreen:toFrame];
    NSPoint startPosition = startFrame.origin;
    NSPoint endPosition = endFrame.origin;
    
    NSString *transitionAnimationKey = @"position.x";
    
    CABasicAnimation *transitionAnimation = [CABasicAnimation animationWithKeyPath:nil];
    [transitionAnimation setFillMode:kCAFillModeForwards];
    [transitionAnimation setRemovedOnCompletion:NO];
    
    if ((animationType == FLOPopoverAnimationBottomToTop) || (animationType == FLOPopoverAnimationTopToBottom)) {
        transitionAnimationKey = @"position.y";
        
        if (animationType == FLOPopoverAnimationTopToBottom) {
            startPosition.y += layerFrame.size.height / 2;
            endPosition.y += layerFrame.size.height / 2;
        } else {
            startPosition.y -= layerFrame.size.height / 2;
            endPosition.y -= layerFrame.size.height / 2;
        }
        
        transitionAnimation.byValue = @(endPosition.y - startPosition.y);
    } else {
        startPosition.x += layerFrame.size.width / 2;
        endPosition.x += layerFrame.size.width / 2;
        
        [transitionAnimation setFromValue:[NSValue valueWithPoint:startPosition]];
        [transitionAnimation setToValue:[NSValue valueWithPoint:endPosition]];
    }
    
    if (!self.utils.popoverMoved && self.utils.animatedInAppFrame && !NSContainsRect(self.utils.mainWindow.frame, transitionFrame)) {
        NSRect intersectionFrame = NSIntersectionRect(self.utils.mainWindow.frame, transitionFrame);
        [self.popoverWindow setFrame:intersectionFrame display:YES];
        [self.snapshotView setFrame:NSMakeRect(transitionFrame.origin.x - intersectionFrame.origin.x, transitionFrame.origin.y - intersectionFrame.origin.y, transitionFrame.size.width, transitionFrame.size.height)];
    }
    
    NSTimeInterval duration = kFlowarePopover_AnimationTimeInterval;
    
    if (self.animationDuration > 0) {
        duration = self.animationDuration;
    }
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if ([self.snapshotView isDescendantOf:[self.popoverWindow contentView]]) {
            [self.snapshotView removeFromSuperview];
            [[[[self.snapshotView layer] sublayers] lastObject] removeAllAnimations];
            [[[[self.snapshotView layer] sublayers] lastObject] removeFromSuperlayer];
            
            self.snapshotView = nil;
        }
        
        [self.popoverWindow setFrame:frame display:showing];
        
        [self popoverDidStopAnimation];
    }];
    
    [animatedLayer addAnimation:opacityAnimation forKey:@"opacity"];
    [animatedLayer addAnimation:transitionAnimation forKey:transitionAnimationKey];
    
    [CATransaction commit];
    [NSAnimationContext endGrouping];
}

- (void)popoverTransitionAnimationFrameShowing:(BOOL)showing {
    if (self.animatedByMovingFrame && (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition)) {
        __block NSRect frame = self.popoverWindow.frame;
        NSRect fromFrame = frame;
        NSRect toFrame = frame;
        
        [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:self.utils.animationType forwarding:self.animatedForwarding showing:showing];
        
        NSRect transitionFrame = frame;
        
        [self.utils calculateTransitionFrame:&transitionFrame fromFrame:fromFrame toFrame:toFrame animationType:self.utils.animationType forwarding:self.animatedForwarding showing:showing];
        
        [self.popoverWindow setHasShadow:NO];
        [self.popoverWindow setAlphaValue:1.0];
        
        [self.popoverWindow setFrame:transitionFrame display:YES];
        
        if (!self.utils.popoverMoved && self.utils.animatedInAppFrame && !NSContainsRect(self.utils.mainWindow.frame, transitionFrame)) {
            NSRect intersectionFrame = NSIntersectionRect(self.utils.mainWindow.frame, transitionFrame);
            [self.popoverWindow setFrame:intersectionFrame display:YES];
        }
        
        NSRect beginFrame = [self.popoverWindow convertRectFromScreen:fromFrame];
        NSRect endFrame = [self.popoverWindow convertRectFromScreen:toFrame];
        NSPoint beginPoint = beginFrame.origin;
        NSPoint endedPoint = endFrame.origin;
        
        [[self.popoverWindow contentView] setWantsLayer:YES];
        [[[self.popoverWindow contentView] layer] setFrame:beginFrame];
        
        if (showing) {
            [[self.popoverWindow contentView] displayAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
                [self.popoverWindow setFrame:frame display:YES];
                
                [self popoverDidStopAnimation];
            }];
        } else {
            [[self.popoverWindow contentView] closeAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
                [self.popoverWindow setFrame:frame display:YES];
                
                [self popoverDidStopAnimation];
            }];
        }
    }
}

/*
 - FLOPopoverAnimationBehaviorDefault
 */
- (void)popoverDefaultAnimationShowing:(BOOL)showing {
    if (showing) {
        [self.popoverWindow setAlphaValue:0.0];
        [self.popoverWindow setHasShadow:YES];
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.17];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self.popoverWindow setAlphaValue:1.0];
            
            [self popoverDidStopAnimation];
        }];
        
        [self.popoverWindow.animator setAlphaValue:1.0];
        
        [NSAnimationContext endGrouping];
    } else {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setDuration:0.1];
            
            [self.popoverWindow setAlphaValue:0.0];
        } completionHandler:^{
            [self popoverDidStopAnimation];
        }];
    }
}

- (void)popoverDidStopAnimation {
    BOOL showing = _popover != nil;
    
    if (showing) {
        [self.popoverWindow setHasShadow:YES];
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
    }
    
    [self popoverDidFinishShowing:showing];
}

#pragma mark - NSAnimationDelegate

- (void)animationDidEnd:(NSAnimation *)animation {
    [self popoverDidStopAnimation];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self popoverDidStopAnimation];
}

#pragma mark - Event monitor

- (void)registerForApplicationEvents {
    [self registerApplicationEventsMonitor];
    [self.utils registerForApplicationEvents];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self.utils removeAllApplicationEvents];
}

- (void)registerApplicationEventsMonitor {
    if (!self.localEvent) {
        self.localEvent = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent *event) {
            if (!self.utils.userInteractionEnable) return event;
            
            if (self.closesWhenPopoverResignsKey) {
                NSView *clickedView = [[event.window contentView] hitTest:event.locationInWindow];
                
                if (!((self.utils.senderView && (clickedView != self.utils.senderView)) || self.closesWhenReceivesEvent)) return event;
                
                // If closesWhenPopoverResignsKey is set as YES and clickedView is the same with self.utils.senderView, DO NOTHING.
                // Because the event received from self.utils.senderView will be fired very later soon.
                BOOL closeNeeded = NO;
                
                if (self.popoverWindow == event.window) {
                    NSPoint eventPoint = [[self.popoverWindow contentView] convertPoint:event.locationInWindow fromView:nil];
                    
                    closeNeeded = !NSPointInRect(eventPoint, [[self.popoverWindow contentView] bounds]);
                } else {
                    closeNeeded = ![self.utils window:self.popoverWindow contains:event.window];
                }
                
                if (closeNeeded) {
                    [self.utils closePopoverWithTimerIfNeeded];
                }
            } else {
                NSWindow *frontWindow = [[self.utils.presentedWindow childWindows] lastObject];
                
                if ((frontWindow != self.popoverWindow) && (self.popoverWindow == event.window)) {
                    NSWindowLevel popoverLevel = [self.popoverWindow level];
                    
                    [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
                    [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
                    [self.popoverWindow setLevel:popoverLevel];
                }
            }
            
            return event;
        }];
    }
}

- (void)removeApplicationEventsMonitor {
    if (self.localEvent) {
        [NSEvent removeMonitor:self.localEvent];
        
        self.localEvent = nil;
    }
}

#pragma mark - Utilities

- (void)closePopover:(id<FLOPopoverProtocols>)sender {
    if (self.isShowing || self.isClosing) {
        [self removeAnimationProcessIfNeeded:YES];
    }
    
    self.isShowing = NO;
    self.isClosing = NO;
    
    [self close];
}

- (void)closePopover:(id<FLOPopoverProtocols>)sender completion:(void (^)(void))complete {
    // code ...
}

#pragma mark - FLOPopoverViewDelegate

- (void)popoverDidMakeMovement {
    self.utils.popoverMoved = YES;
    
    if (didMoveBlock) {
        didMoveBlock(self);
        
        didMoveBlock = nil;
    }
}

- (void)popoverDidMakeDetachable:(NSWindow *)targetWindow {
    if ((targetWindow == self.popoverWindow) && [[self.utils.presentedWindow childWindows] containsObject:targetWindow]) {
        [self removeAllApplicationEvents];
        
        if (didDetachBlock) {
            didDetachBlock(self);
            
            didDetachBlock = nil;
        }
        
        NSView *contentView = self.utils.contentView;
        NSRect contentFrame = [contentView.window contentRectForFrameRect:[contentView.window convertRectToScreen:[contentView convertRect:contentView.bounds toView:[contentView.window contentView]]]];
        NSWindowStyleMask styleMask = (self.detachableStyleMask != NSNotFound) ? self.detachableStyleMask : (NSWindowStyleMaskTitled + NSWindowStyleMaskClosable);
        NSWindow *window = [[NSWindow alloc] initWithContentRect:contentFrame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
        NSRect frame = [window frameRectForContentRect:contentFrame];
        
        [self.utils.backgroundView removeFromSuperview];
        [self.utils.contentView removeFromSuperview];
        [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        
        [self.utils addView:contentView toParent:[self.popoverWindow contentView] autoresizingMask:YES];
        
        [self.popoverWindow setStyleMask:styleMask];
        [self.popoverWindow makeKeyAndOrderFront:nil];
        [self.popoverWindow setFrame:frame display:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewFrame:) name:NSWindowWillCloseNotification object:targetWindow];
    }
}

@end
