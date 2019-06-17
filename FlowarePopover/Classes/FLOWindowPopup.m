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


@interface FLOWindowPopup () <FLOPopoverViewDelegate, NSAnimationDelegate, CAAnimationDelegate> {
    FLOPopoverWindow *_popover;
}

@property (nonatomic, strong) NSEvent *appEvent;

@property (nonatomic, assign) NSRect initialFrame;

@property (nonatomic, assign) BOOL popoverShowing;
@property (nonatomic, assign) BOOL popoverClosing;

@property (nonatomic, strong) FLOPopoverWindow *popoverWindow;
@property (nonatomic, assign) NSWindowLevel popoverWindowLevel;

/**
 * View that used for making animation with an animated layer.
 */
@property (nonatomic, strong) NSView *snapshotView;

@end

@implementation FLOWindowPopup

@synthesize utils = _utils;
@synthesize alwaysOnTop = _alwaysOnTop;
@synthesize shouldShowArrow = _shouldShowArrow;
@synthesize arrowSize = _arrowSize;
@synthesize animated = _animated;
@synthesize animatedForwarding = _animatedForwarding;
@synthesize bottomOffset = _bottomOffset;
@synthesize displaysInsideClipView = _displaysInsideClipView;
@synthesize staysInApplicationFrame = _staysInApplicationFrame;
@synthesize updatesFrameWhileShowing = _updatesFrameWhileShowing;
@synthesize shouldRegisterSuperviewObservers = _shouldRegisterSuperviewObservers;
@synthesize shouldChangeSizeWhenApplicationResizes = _shouldChangeSizeWhenApplicationResizes;
@synthesize closesWhenPopoverResignsKey = _closesWhenPopoverResignsKey;
@synthesize closesWhenApplicationBecomesInactive = _closesWhenApplicationBecomesInactive;
@synthesize closesWhenApplicationResizes = _closesWhenApplicationResizes;
@synthesize closesWhenNotBelongToContainerFrame = _closesWhenNotBelongToContainerFrame;
@synthesize closesWhenReceivesEvent = _closesWhenReceivesEvent;
@synthesize resignsFieldsOnClosing = _resignsFieldsOnClosing;
@synthesize makesKeyAndOrderFrontOnDisplaying = _makesKeyAndOrderFrontOnDisplaying;
@synthesize makesKeyAndOrderFrontOnMouseHover = _makesKeyAndOrderFrontOnMouseHover;
@synthesize isMovable = _isMovable;
@synthesize isDetachable = _isDetachable;
@synthesize canBecomeKey = _canBecomeKey;
@synthesize tag = _tag;
@synthesize animatedByMovingFrame = _animatedByMovingFrame;
@synthesize animationDuration = _animationDuration;
@synthesize needAutoresizingMask = _needAutoresizingMask;

@synthesize willShowBlock;
@synthesize didShowBlock;
@synthesize willCloseBlock;
@synthesize didCloseBlock;
@synthesize didMoveBlock;
@synthesize didDetachBlock;

- (instancetype)init {
    if (self = [super init]) {
        _utils = [[FLOPopoverUtils alloc] initWithPopover:self];
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _arrowSize = NSZeroSize;
        _animated = NO;
        _animatedForwarding = NO;
        _bottomOffset = FLO_CONST_POPOVER_BOTTOM_OFFSET;
        _displaysInsideClipView = NO;
        _staysInApplicationFrame = NO;
        _updatesFrameWhileShowing = NO;
        _shouldRegisterSuperviewObservers = YES;
        _shouldChangeSizeWhenApplicationResizes = NO;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _closesWhenNotBelongToContainerFrame = YES;
        _closesWhenReceivesEvent = NO;
        _resignsFieldsOnClosing = YES;
        _makesKeyAndOrderFrontOnDisplaying = YES;
        _isMovable = NO;
        _isDetachable = NO;
        _canBecomeKey = YES;
        _tag = -1;
        _animatedByMovingFrame = NO;
        _animationDuration = 0.0;
        _needAutoresizingMask = NO;
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
    self.appEvent = nil;
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

- (NSRect)frame {
    return self.popoverWindow.frame;
}

- (BOOL)isShown {
    return self.popoverWindow.isVisible;
}

- (FLOPopoverType)type {
    return FLOWindowPopover;
}

- (void)setShouldShowArrow:(BOOL)shouldShowArrow {
    _shouldShowArrow = shouldShowArrow;
    
    if (shouldShowArrow && NSEqualSizes(self.arrowSize, NSZeroSize)) {
        self.arrowSize = NSMakeSize(PopoverBackgroundViewArrowWidth, PopoverBackgroundViewArrowHeight);
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

- (void)setStaysInApplicationFrame:(BOOL)staysInApplicationFrame {
    _staysInApplicationFrame = staysInApplicationFrame;
    
    self.utils.staysInApplicationFrame = staysInApplicationFrame;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    if ([self isShown]) {
        self.popoverWindow.tag = tag;
    }
}

- (void)setMakesKeyAndOrderFrontOnMouseHover:(BOOL)makesKeyAndOrderFrontOnMouseHover {
}

#pragma mark - Local methods

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    [self.utils setPopoverEdgeType:edgeType];
}

- (void)setTopMostWindowIfNecessary {
    NSWindow *topWindow = [FLOPopoverUtils sharedInstance].topWindow;
    NSArray *windowStack = self.utils.mainWindow.childWindows;
    
    if ((topWindow != nil) && [windowStack containsObject:topWindow]) {
        NSWindowLevel topWindowLevel = topWindow.level;
        
        [self.utils.mainWindow removeChildWindow:topWindow];
        [self.utils.mainWindow addChildWindow:topWindow ordered:NSWindowAbove];
        topWindow.level = topWindowLevel;
    }
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
        if (self.updatesFrameWhileShowing || (!self.popoverShowing && !self.popoverClosing)) {
            [self displayWithAnimationProcess:NO];
        } else {
            [self performSelector:@selector(updatePopoverFrame) withObject:nil afterDelay:0.1];
        }
    }
}

- (void)removeAnimationProcessIfNeeded:(BOOL)isNeeded {
    if (!isNeeded) return;
    
    if (self.snapshotView != nil) {
        [self.snapshotView removeFromSuperview];
        [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
        [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
        
        self.snapshotView = nil;
    }
    
    if (self.popoverWindow.contentView.layer != nil) {
        [self.popoverWindow.contentView.layer removeAllAnimations];
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
    
    if ([self isShown] && !self.popoverShowing && !self.popoverClosing) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentView setFrame:self.utils.contentView.frame];
        
        self.utils.contentView = contentView;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([self.utils.presentedWindow.childWindows containsObject:self.popoverWindow]) {
            [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        }
        
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    if (![contentViewController isKindOfClass:[NSViewController class]]) return;
    
    if ([self isShown] && !self.popoverShowing && !self.popoverClosing) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentViewController.view setFrame:self.utils.contentView.frame];
        
        self.utils.contentViewController = contentViewController;
        self.utils.contentView = contentViewController.view;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([self.utils.presentedWindow.childWindows containsObject:self.popoverWindow]) {
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
    [self.utils setUserInteractionEnable:isEnable];
}

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    self.utils.shouldShowArrowWithVisualEffect = needed;
    self.utils.arrowVisualEffectMaterial = material;
    self.utils.arrowVisualEffectBlendingMode = blendingMode;
    self.utils.arrowVisualEffectState = state;
}

- (void)updatePopoverFrame:(NSRect)frame {
    [self.popoverWindow setFrame:frame display:YES];
}

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
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    if ([self isShown]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self close];
        
        return;
    }
    
    if (!self.popoverShowing && !self.popoverClosing) {
        self.popoverShowing = YES;
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.positioningFrame = rect;
        self.utils.positioningView = positioningView;
        self.utils.positioningAnchorView = positioningView;
        self.utils.senderView = positioningView;
        self.utils.needAutoresizingMask = self.needAutoresizingMask;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopover];
        
        // Waiting for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.069];
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
    
    if (!self.popoverShowing && !self.popoverClosing) {
        self.popoverShowing = YES;
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.relativePositionType = relativePositionType;
        
        [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
        
        self.utils.positioningFrame = [self.utils.positioningAnchorView bounds];
        self.utils.positioningView = positioningView;
        self.utils.senderView = sender;
        self.utils.needAutoresizingMask = self.needAutoresizingMask;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopover];
        
        // Waiting for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.069];
        [self registerForApplicationEvents];
    }
}

/**
 * Display popover as system alert style for presented window.
 *
 * @param presentedWindow the target window that the popover will be alerted on.
 */
- (void)showWithAlertStyleForWindow:(NSWindow *)presentedWindow {
    if ([presentedWindow isKindOfClass:[NSWindow class]]) {
        self.utils.presentedWindow = presentedWindow;
        self.utils.popoverStyle = FLOPopoverStyleAlert;
        self.utils.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.utils.animationType = FLOPopoverAnimationDefault;
        
        self.shouldShowArrow = NO;
        self.isMovable = NO;
        self.isDetachable = NO;
        self.animatedByMovingFrame = NO;
        
        [self setupPopover];
        
        _popover = self.popoverWindow;
        
        [self registerForApplicationEvents];
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)show {
    [self displayWithAnimationProcess:YES];
}

- (void)setupPopover {
    if (self.utils.popoverStyle == FLOPopoverStyleAlert) {
        [self setupPopoverStyleAlert];
    } else {
        [self setupPopoverStyleNormal];
    }
}

- (void)setupPopoverStyleNormal {
    self.utils.backgroundView.frame = (NSRect){ .size = self.utils.contentView.frame.size };
    
    if (self.popoverWindow == nil) {
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:NSMakeRect(SHRT_MIN, SHRT_MIN, self.utils.contentView.frame.size.width, self.utils.contentView.frame.size.height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        self.popoverWindow.hasShadow = NO;
        self.popoverWindow.releasedWhenClosed = NO;
        self.popoverWindow.opaque = NO;
        self.popoverWindow.backgroundColor = NSColor.clearColor;
    }
    
    [self.utils addView:self.utils.contentView toParent:self.utils.backgroundView autoresizingMask:NO];
    [self.utils addView:self.utils.backgroundView toParent:self.popoverWindow.contentView autoresizingMask:NO];
    
    if (![self.utils.presentedWindow.childWindows containsObject:self.popoverWindow]) {
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    [self.utils setupAutoresizingMaskIfNeeded:YES];
    
    self.popoverWindow.canBecomeKey = self.canBecomeKey;
    self.popoverWindow.tag = self.tag;
    self.popoverWindow.level = self.popoverWindowLevel;
}

- (void)setupPopoverStyleAlert {
    self.utils.backgroundView.frame = (NSRect){ .size = self.utils.contentView.frame.size };
    
    if (self.popoverWindow == nil) {
        NSRect frame = [self.utils.presentedWindow contentRectForFrameRect:self.utils.presentedWindow.frame];
        
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        self.popoverWindow.hasShadow = NO;
        self.popoverWindow.releasedWhenClosed = NO;
        self.popoverWindow.opaque = NO;
        self.popoverWindow.backgroundColor = NSColor.clearColor;
        
        self.popoverWindow.contentView.wantsLayer = YES;
        self.popoverWindow.contentView.layer.backgroundColor = [[NSColor.whiteColor colorWithAlphaComponent:0.01] CGColor];
    }
    
    [self.utils addView:self.utils.contentView toParent:self.utils.backgroundView centerAutoresizingMask:YES];
    [self.utils addView:self.utils.backgroundView toParent:self.popoverWindow.contentView autoresizingMask:YES];
    
    if (![self.utils.presentedWindow.childWindows containsObject:self.popoverWindow]) {
        [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    self.popoverWindow.canBecomeKey = self.canBecomeKey;
    self.popoverWindow.tag = self.tag;
    self.popoverWindow.level = self.popoverWindowLevel;
}

- (void)displayWithAnimationProcess:(BOOL)needed {
    if (NSEqualRects(self.utils.positioningFrame, NSZeroRect)) {
        self.utils.positioningFrame = [self.utils.positioningAnchorView bounds];
    }
    
    NSRect windowRelativeFrame = [self.utils.positioningAnchorView convertRect:[self.utils.positioningAnchorView alignmentRectForFrame:self.utils.positioningFrame] toView:nil];
    NSRect positionScreenFrame = [self.utils.presentedWindow convertRectToScreen:windowRelativeFrame];
    
    self.utils.backgroundView.popoverOrigin = positionScreenFrame;
    self.utils.originalViewSize = NSEqualSizes(self.utils.originalViewSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.originalViewSize;
    self.utils.contentSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.contentSize;
    
    NSSize contentViewSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.originalViewSize : self.utils.contentSize;
    NSRectEdge popoverEdge = self.utils.preferredEdge;
    
    self.utils.backgroundView.borderRadius = self.utils.contentView.layer ? self.utils.contentView.layer.cornerRadius : PopoverBackgroundViewBorderRadius;
    
    [self.utils.backgroundView makeMovable:self.isMovable];
    [self.utils.backgroundView makeDetachable:self.isDetachable];
    
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        self.utils.backgroundView.arrowSize = self.arrowSize;
        
        [self.utils.backgroundView showArrow:self.shouldShowArrow];
        [self.utils.backgroundView setArrowColor:self.utils.contentView.layer.backgroundColor];
        
        if (self.utils.shouldShowArrowWithVisualEffect) {
            [self.utils.backgroundView showArrowWithVisualEffect:self.utils.shouldShowArrowWithVisualEffect material:self.utils.arrowVisualEffectMaterial blendingMode:self.utils.arrowVisualEffectBlendingMode state:self.utils.arrowVisualEffectState];
        }
    } else {
        self.arrowSize = NSZeroSize;
    }
    
    if (self.isMovable || self.isDetachable) {
        self.utils.backgroundView.delegate = self;
    }
    
    CGSize size = [self.utils.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.utils.backgroundView.frame = (NSRect){ .size = size };
    self.utils.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.utils.backgroundView contentViewFrameForBackgroundFrame:self.utils.backgroundView.bounds popoverEdge:popoverEdge];
    self.utils.contentView.frame = contentViewFrame;
    
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        self.utils.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.utils.animationType = FLOPopoverAnimationDefault;
    }
    
    NSRect popoverFrame = (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) ? [self.utils p_popoverFrame] : [self.utils popoverFrame];
    
    // Update arrow edge and content view frame
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils p_backgroundViewShouldUpdate:YES];
    }
    
    self.utils.originalViewSize = self.utils.backgroundView.frame.size;
    self.initialFrame = popoverFrame;
    
    [self.popoverWindow setFrame:popoverFrame display:NO];
    
    popoverFrame = [self.utils.mainWindow convertRectFromScreen:popoverFrame];
    
    self.utils.verticalMarginOutOfPopover = self.utils.mainWindow.contentView.visibleRect.size.height + self.bottomOffset - NSMaxY(popoverFrame);
    self.utils.positioningWindowFrame = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.presentedWindow.contentView];
    
    if (needed) {
        _popover = self.popoverWindow;
        
        if (self.alwaysOnTop) {
            [self.utils setTopmostWindow:self.popoverWindow];
        }
        
        [self setTopMostWindowIfNecessary];
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (![self isShown]) return;
    
    if (!self.popoverClosing && !self.popoverShowing) {
        if (self.resignsFieldsOnClosing) {
            // Use this trick for resigning first responder for all NSTextFields of popoverWindow
            [self.popoverWindow makeFirstResponder:nil];
        }
        
        self.popoverClosing = YES;
        
        if (willCloseBlock) willCloseBlock(self);
        
        _popover = nil;
        
        [self.utils setupAutoresizingMaskIfNeeded:NO];
        [self removeAllApplicationEvents];
        [self popoverShowing:NO animated:self.animated];
    }
}

- (void)closePopoverWhileAnimatingIfNeeded:(BOOL)isNeeded {
    if (!isNeeded) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.popoverShowing) {
        self.popoverShowing = NO;
        
        [self removeAnimationProcessIfNeeded:YES];
        
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1];
    } else {
        [self close];
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    if (showing) {
        if (self.makesKeyAndOrderFrontOnDisplaying) {
            [self.popoverWindow makeKeyAndOrderFront:nil];
        }
        
        self.popoverWindow.alphaValue = 1.0;
        
        self.popoverShowing = NO;
        
        if (self.utils.popoverStyle == FLOPopoverStyleNormal) {
            [self.utils setupAutoresizingMaskIfNeeded:YES];
        }
        
        if (didShowBlock) didShowBlock(self);
    } else {
        [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        
        [self resetContentViewFrame:nil];
        
        self.appEvent = nil;
        self.utils.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        self.utils.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        self.utils = nil;
        
        [self.popoverWindow close];
        self.popoverWindow = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        self.popoverClosing = NO;
        
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
    if ([self.snapshotView isDescendantOf:self.popoverWindow.contentView]) {
        [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
        [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
    }
    
    CGFloat scaleFactor = showing ? 1.25 : 1.2;
    NSRect frame = self.popoverWindow.frame;
    CGFloat width = scaleFactor * frame.size.width;
    CGFloat height = scaleFactor * frame.size.height;
    CGFloat x = frame.origin.x - (width - frame.size.width) / 2;
    CGFloat y = frame.origin.y - (height - frame.size.height) / 2;
    NSRect scalingFrame = NSMakeRect(x, y, width, height);
    
    self.popoverWindow.hasShadow = YES;
    [self.popoverWindow setAlphaValue:1.0];
    [self.popoverWindow setFrame:frame display:YES];
    [self.utils.backgroundView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    self.popoverWindow.hasShadow = NO;
    [self.utils.contentView setAlphaValue:0.01];
    
    [self.popoverWindow setFrame:scalingFrame display:showing];
    
    NSRect layerFrame = [self.popoverWindow convertRectFromScreen:frame];
    CALayer *animatedLayer = [CALayer layer];
    animatedLayer.contents = snapshotImage;
    animatedLayer.frame = layerFrame;
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[NSView alloc] initWithFrame:(NSRect){ .size = scalingFrame.size }];
    }
    
    self.snapshotView.wantsLayer = YES;
    self.snapshotView.frame = (NSRect){ .size = scalingFrame.size };
    [self.snapshotView.layer addSublayer:animatedLayer];
    
    [self.popoverWindow.contentView addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.utils.backgroundView];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:nil];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fromValue = @(showing ? 0.0 : 1.0);
    opacityAnimation.toValue = @(showing ? 1.0 : 0.0);
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:nil];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.fromValue = showing ? [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)] : [NSValue valueWithCATransform3D:CATransform3DIdentity];
    transformAnimation.toValue = showing ? [NSValue valueWithCATransform3D:CATransform3DIdentity] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)];
    
    NSTimeInterval duration = showing ? FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD : 0.15;
    
    if (self.animationDuration > 0) {
        duration = self.animationDuration;
    }
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if ([self.snapshotView isDescendantOf:self.popoverWindow.contentView]) {
            [self.snapshotView removeFromSuperview];
            [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
            [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
            
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
    if ([self.snapshotView isDescendantOf:self.popoverWindow.contentView]) {
        [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
        [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
    }
    
    NSRect frame = self.popoverWindow.frame;
    NSRect fromFrame = frame;
    NSRect toFrame = frame;
    
    [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    NSRect transitionFrame = frame;
    
    [self.utils calculateTransitionFrame:&transitionFrame fromFrame:fromFrame toFrame:toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    self.popoverWindow.hasShadow = YES;
    [self.popoverWindow setAlphaValue:1.0];
    [self.popoverWindow setFrame:frame display:YES];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    self.popoverWindow.hasShadow = NO;
    [self.utils.contentView setAlphaValue:0.01];
    
    [self.popoverWindow setFrame:transitionFrame display:YES];
    
    NSRect layerFrame = [self.popoverWindow convertRectFromScreen:fromFrame];
    CALayer *animatedLayer = [CALayer layer];
    animatedLayer.contents = snapshotImage;
    animatedLayer.frame = layerFrame;
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[NSView alloc] initWithFrame:(NSRect){ .size = transitionFrame.size }];
    }
    
    self.snapshotView.wantsLayer = YES;
    self.snapshotView.frame = (NSRect){ .size = transitionFrame.size };
    [self.snapshotView.layer addSublayer:animatedLayer];
    
    [self.popoverWindow.contentView addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.utils.backgroundView];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:nil];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fromValue = @(showing ? 0.0 : 1.0);
    opacityAnimation.toValue = @(showing ? 1.0 : 0.0);
    
    NSRect startFrame = [self.popoverWindow convertRectFromScreen:fromFrame];
    NSRect endFrame = [self.popoverWindow convertRectFromScreen:toFrame];
    NSPoint startPosition = startFrame.origin;
    NSPoint endPosition = endFrame.origin;
    
    NSString *transitionAnimationKey = @"position.x";
    
    CABasicAnimation *transitionAnimation = [CABasicAnimation animationWithKeyPath:nil];
    transitionAnimation.fillMode = kCAFillModeForwards;
    transitionAnimation.removedOnCompletion = NO;
    
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
        
        transitionAnimation.fromValue = [NSValue valueWithPoint:startPosition];
        transitionAnimation.toValue = [NSValue valueWithPoint:endPosition];
    }
    
    if (!self.utils.popoverMoved && self.utils.animatedInAppFrame && !NSContainsRect(self.utils.mainWindow.frame, transitionFrame)) {
        NSRect intersectionFrame = NSIntersectionRect(self.utils.mainWindow.frame, transitionFrame);
        [self.popoverWindow setFrame:intersectionFrame display:YES];
        [self.snapshotView setFrame:NSMakeRect(transitionFrame.origin.x - intersectionFrame.origin.x, transitionFrame.origin.y - intersectionFrame.origin.y, transitionFrame.size.width, transitionFrame.size.height)];
    }
    
    NSTimeInterval duration = FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD;
    
    if (self.animationDuration > 0) {
        duration = self.animationDuration;
    }
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if ([self.snapshotView isDescendantOf:self.popoverWindow.contentView]) {
            [self.snapshotView removeFromSuperview];
            [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
            [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
            
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
        
        self.popoverWindow.hasShadow = NO;
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
        
        [self.popoverWindow.contentView setWantsLayer:YES];
        [self.popoverWindow.contentView.layer setFrame:beginFrame];
        
        if (showing) {
            [self.popoverWindow.contentView displayAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
                [self.popoverWindow setFrame:frame display:YES];
                
                [self popoverDidStopAnimation];
            }];
        } else {
            [self.popoverWindow.contentView closeAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
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
        self.popoverWindow.alphaValue = 0.0;
        self.popoverWindow.hasShadow = YES;
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.17];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            self.popoverWindow.alphaValue = 1.0;
            
            [self popoverDidStopAnimation];
        }];
        
        self.popoverWindow.animator.alphaValue = 1.0;
        
        [NSAnimationContext endGrouping];
    } else {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.095;
            self.popoverWindow.alphaValue = 0.0;
        } completionHandler:^{
            [self popoverDidStopAnimation];
        }];
    }
}

- (void)popoverDidStopAnimation {
    BOOL showing = _popover != nil;
    
    if (showing) {
        self.popoverWindow.hasShadow = YES;
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
    [self registerApplicationActiveNotification];
    [self registerSuperviewObserversForPositioningAnchor];
    [self registerWindowEvents];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self removeApplicationActiveNotification];
    [self unregisterSuperviewObserversForPositioningAnchor];
    [self removeWindowEvents];
}

- (void)registerApplicationActiveNotification {
    if (self.closesWhenApplicationBecomesInactive) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(eventObserver_applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
}

- (void)removeApplicationActiveNotification {
    if (self.closesWhenApplicationBecomesInactive) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
        
        self.closesWhenApplicationBecomesInactive = NO;
    }
}

- (void)registerApplicationEventsMonitor {
    if (!self.appEvent) {
        self.appEvent = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent* event) {
            if (!self.utils.userInteractionEnable) return event;
            
            if (self.closesWhenPopoverResignsKey) {
                NSView *clickedView = [event.window.contentView hitTest:event.locationInWindow];
                
                // If closesWhenPopoverResignsKey is set as YES and clickedView is the same with self.utils.senderView, DO NOTHING.
                // Because the event received from self.utils.senderView will be fired very later soon.
                if ((self.utils.senderView && (clickedView != self.utils.senderView)) || self.closesWhenReceivesEvent) {
                    if (self.popoverWindow == event.window) {
                        NSPoint eventPoint = [self.popoverWindow.contentView convertPoint:event.locationInWindow fromView:nil];
                        
                        if (!NSPointInRect(eventPoint, self.popoverWindow.contentView.bounds)) {
                            [self closePopoverWhileAnimatingIfNeeded:YES];
                        }
                    } else {
                        BOOL contained = [self.utils window:self.popoverWindow contains:event.window];
                        
                        if (!contained) {
                            [self closePopoverWhileAnimatingIfNeeded:YES];
                        }
                    }
                }
            } else {
                NSWindow *frontWindow = [self.utils.presentedWindow.childWindows lastObject];
                
                if ((frontWindow != self.popoverWindow) && (self.popoverWindow == event.window)) {
                    NSWindowLevel popoverLevel = self.popoverWindow.level;
                    
                    [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
                    [self.utils.presentedWindow addChildWindow:self.popoverWindow ordered:NSWindowAbove];
                    
                    self.popoverWindow.level = popoverLevel;
                }
            }
            
            return event;
        }];
    }
}

- (void)removeApplicationEventsMonitor {
    if (self.appEvent) {
        [NSEvent removeMonitor:self.appEvent];
        
        self.appEvent = nil;
    }
}

- (void)registerSuperviewObserversForPositioningAnchor {
    if (self.utils.popoverStyle != FLOPopoverStyleNormal) return;
    
    if (self.shouldRegisterSuperviewObservers) {
        self.utils.anchorSuperviews = [[NSMutableArray alloc] init];
        
        [self.utils.anchorSuperviews addObject:self.utils.positioningAnchorView];
        
        [self.utils addSuperviewObserversForView:self.utils.positioningAnchorView selector:@selector(eventObserver_viewBoundsDidChange:) source:self];
        
        NSView *anchorSuperview = [self.utils.positioningAnchorView superview];
        
        while (anchorSuperview != nil) {
            if ([anchorSuperview isKindOfClass:[NSView class]]) {
                [self.utils.anchorSuperviews addObject:anchorSuperview];
                
                [self.utils addSuperviewObserversForView:anchorSuperview selector:@selector(eventObserver_viewBoundsDidChange:) source:self];
            }
            
            anchorSuperview = [anchorSuperview superview];
        }
    }
    
    if (self.closesWhenApplicationResizes) {
        [self.utils.mainWindow.contentView addObserver:self forKeyPath:@"frame"
                                               options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                               context:NULL];
    }
}

- (void)unregisterSuperviewObserversForPositioningAnchor {
    if (self.utils.popoverStyle != FLOPopoverStyleNormal) return;
    
    if (self.shouldRegisterSuperviewObservers) {
        for (NSView *anchorSuperview in self.utils.anchorSuperviews) {
            @try {
                if ([anchorSuperview isKindOfClass:[NSClipView class]]) {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:anchorSuperview];
                } else {
                    [anchorSuperview removeObserver:self forKeyPath:@"frame"];
                    [anchorSuperview removeObserver:self forKeyPath:@"superview"];
                }
            } @catch (NSException *exception) {
                NSLog(@"%s-[%d] exception - reason = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason);
            }
        }
        
        self.utils.anchorSuperviews = nil;
    }
    
    if (self.closesWhenApplicationResizes) {
        [self.utils.mainWindow.contentView removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)registerWindowEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}

- (void)removeWindowEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
}

#pragma mark - Utilities

- (void)closePopover:(id<FLOPopoverProtocols>)sender {
    self.popoverShowing = NO;
    self.popoverClosing = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeAnimationProcessIfNeeded:YES];
    [self close];
}

- (void)closePopover:(id<FLOPopoverProtocols>)sender completion:(void (^)(void))complete {
    // code ...
}

#pragma mark - Event handling

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self.utils handleObserveValueForKeyPath:keyPath ofObject:object change:change context:context popoverShowing:self.popoverShowing popoverClosing:self.popoverClosing];
}

- (void)eventObserver_viewBoundsDidChange:(NSNotification *)notification {
    [self.utils handleObserverViewBoundsDidChange:notification popoverShowing:self.popoverShowing popoverClosing:self.popoverClosing];
}

- (void)eventObserver_applicationDidResignActive:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSApplicationDidResignActiveNotification]) {
        [self close];
    }
}

- (void)eventObserver_windowDidResize:(NSNotification *)notification {
    [self.utils handleObserverWindowDidResize:notification popoverShowing:self.popoverShowing popoverClosing:self.popoverClosing];
}

- (void)eventObserver_windowWillClose:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowWillCloseNotification] && [notification.object isKindOfClass:[NSWindow class]]) {
        NSWindow *window = (NSWindow *)notification.object;
        
        if ((window != self.popoverWindow) && [self.utils window:window contains:self.popoverWindow]) {
            [self closePopoverWhileAnimatingIfNeeded:YES];
        }
    }
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
    if ((targetWindow == self.popoverWindow) && [self.utils.presentedWindow.childWindows containsObject:targetWindow]) {
        [self removeAllApplicationEvents];
        
        if (didDetachBlock) {
            didDetachBlock(self);
            
            didDetachBlock = nil;
        }
        
        [self.utils.backgroundView removeFromSuperview];
        [self.utils.contentView removeFromSuperview];
        
        [self.utils.presentedWindow removeChildWindow:self.popoverWindow];
        
        NSView *contentView = self.utils.contentView;
        NSRect frame = [self.popoverWindow contentRectForFrameRect:self.popoverWindow.frame];
        NSUInteger styleMask = NSWindowStyleMaskTitled + NSWindowStyleMaskClosable;
        NSWindow *window = [[NSWindow alloc] initWithContentRect:frame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
        
        frame = [window frameRectForContentRect:frame];
        
        [self.popoverWindow.contentView addSubview:contentView];
        [self.popoverWindow setStyleMask:styleMask];
        [self.popoverWindow setFrame:frame display:YES];
        [self.popoverWindow makeKeyAndOrderFront:nil];
        
        [contentView setFrameSize:contentView.frame.size];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewFrame:) name:NSWindowWillCloseNotification object:targetWindow];
    }
}

@end
