//
//  FLOViewPopup.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FLOViewPopup.h"

#import "FLOPopoverView.h"
#import "FLOPopoverWindow.h"
#import "FLOVirtualView.h"

#import "FLOExtensionsNSView.h"
#import "FLOExtensionsNSWindow.h"


@interface FLOViewPopup () <FLOPopoverViewDelegate> {
    FLOPopoverView *_popover;
}

@property (nonatomic, strong) NSEvent *localEvent;

@property (nonatomic, strong) FLOPopoverView *popoverView;
@property (nonatomic, strong) FLOPopoverWindow *popoverWindow;

@end

@implementation FLOViewPopup

@synthesize userInteractionEnable = _userInteractionEnable;
@synthesize disabledColor = _disabledColor;
@synthesize localUpdated = _localUpdated;
@synthesize initialFrame = _initialFrame;
@synthesize utils = _utils;
@synthesize isShowing = _isShowing;
@synthesize isClosing = _isClosing;
@synthesize closeEventReceived = _closeEventReceived;
@synthesize hasShadow = _hasShadow;
@synthesize shouldShowArrow = _shouldShowArrow;
@synthesize arrowSize = _arrowSize;
@synthesize arrowColor = _arrowColor;
@synthesize animated = _animated;
@synthesize animatedForwarding = _animatedForwarding;
@synthesize bottomOffset = _bottomOffset;
@synthesize maxHeight = _maxHeight;
@synthesize stopsAtContainerBounds = _stopsAtContainerBounds;
@synthesize staysInScreen = _staysInScreen;
@synthesize staysInContainer = _staysInContainer;
@synthesize updatesPositionCircularly = _updatesPositionCircularly;
@synthesize updatesFrameWhileShowing = _updatesFrameWhileShowing;
@synthesize updatesFrameWhenApplicationResizes = _updatesFrameWhenApplicationResizes;
@synthesize shouldUseRelativeVisibleRect = _shouldUseRelativeVisibleRect;
@synthesize shouldRegisterSuperviewObservers = _shouldRegisterSuperviewObservers;
@synthesize shouldChangeSizeWhenApplicationResizes = _shouldChangeSizeWhenApplicationResizes;
@synthesize closesWhenPopoverResignsKey = _closesWhenPopoverResignsKey;
@synthesize closesWhenApplicationBecomesInactive = _closesWhenApplicationBecomesInactive;
@synthesize closesWhenApplicationResizes = _closesWhenApplicationResizes;
@synthesize closesWhenNotBelongToContainer = _closesWhenNotBelongToContainer;
@synthesize closesWhenReceivesEvent = _closesWhenReceivesEvent;
@synthesize becomesKeyOnMouseOver = _becomesKeyOnMouseOver;
@synthesize isMovable = _isMovable;
@synthesize isDetachable = _isDetachable;
@synthesize detachableStyleMask = _detachableStyleMask;
@synthesize tag = _tag;
@synthesize animationDuration = _animationDuration;

@synthesize floPopoverWillShowBlock;
@synthesize floPopoverDidShowBlock;
@synthesize floPopoverShouldCloseBlock;
@synthesize floPopoverWillCloseBlock;
@synthesize floPopoverDidCloseBlock;
@synthesize floPopoverWillMoveBlock;
@synthesize floPopoverDidMoveBlock;
@synthesize floPopoverWillDetachBlock;
@synthesize floPopoverDidDetachBlock;

- (instancetype)init {
    if (self = [super init]) {
        _userInteractionEnable = YES;
        _utils = [[FLOPopoverUtils alloc] initWithPopover:self];
        _hasShadow = YES;
        _shouldShowArrow = NO;
        _arrowSize = NSZeroSize;
        _animated = NO;
        _animatedForwarding = NO;
        _bottomOffset = kFlowarePopover_BottomOffset;
        _stopsAtContainerBounds = YES;
        _staysInScreen = NO;
        _staysInContainer = NO;
        _updatesPositionCircularly = YES;
        _updatesFrameWhileShowing = NO;
        _updatesFrameWhenApplicationResizes = YES;
        _shouldUseRelativeVisibleRect = NO;
        _shouldRegisterSuperviewObservers = YES;
        _shouldChangeSizeWhenApplicationResizes = NO;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _closesWhenNotBelongToContainer = NO;
        _closesWhenReceivesEvent = NO;
        _isMovable = NO;
        _isDetachable = NO;
        _detachableStyleMask = (NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable);
        _tag = -1;
        _animationDuration = 0.0;
    }
    
    return self;
}

/**
 * Initialize the FLOViewPopup with content view.
 *
 * @param contentView the view needs displayed on FLOViewPopup
 * @return FLOViewPopup instance
 */
- (instancetype)initWithContentView:(NSView *)contentView {
    if (self = [self init]) {
        _utils.contentView = contentView;
        _utils.backgroundView = [[FLOPopoverView alloc] initWithFrame:contentView.frame];
    }
    
    return self;
}

/**
 * Initialize the FLOViewPopup with content view controller.
 *
 * @param contentViewController the view controller needs displayed on FLOViewPopup
 * @return FLOViewPopup instance
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllApplicationEvents];
    
    self.localEvent = nil;
    self.utils = nil;
    self.arrowColor = NULL;
    
    [self.popoverView removeFromSuperview];
    self.popoverView = nil;
    
    floPopoverWillShowBlock = nil;
    floPopoverDidShowBlock = nil;
    floPopoverShouldCloseBlock = nil;
    floPopoverWillCloseBlock = nil;
    floPopoverDidCloseBlock = nil;
    floPopoverWillMoveBlock = nil;
    floPopoverDidMoveBlock = nil;
    floPopoverWillDetachBlock = nil;
    floPopoverDidDetachBlock = nil;
}

#pragma mark - Getter/Setter

- (NSResponder *)representedObject {
    return self.popoverView;
}

- (NSRect)frame {
    return [[self.popoverView window] convertRectToScreen:[self.popoverView convertRect:self.popoverView.bounds toView:[[self.popoverView window] contentView]]];
}

- (BOOL)isShown {
    return ([self.popoverView superview] != nil);
}

- (FLOPopoverType)type {
    return FLOViewPopover;
}

- (BOOL)containsArrow {
    return (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView) && !NSEqualSizes(self.arrowSize, NSZeroSize));
}

- (BOOL)userInteractionEnable {
    return _userInteractionEnable;
}

- (NSColor *)disabledColor {
    return _disabledColor;
}

- (BOOL)closeEventReceived {
    return (_closeEventReceived || self.utils.isCloseEventReceived);
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

- (void)setArrowColor:(CGColorRef)arrowColor {
    if (self.containsArrow) {
        BOOL invalidateShadow = (arrowColor == NULL) && (self.utils.backgroundView.clippingPath != NULL);
        
        CGColorRelease(_arrowColor);
        _arrowColor = arrowColor;
        CGColorRetain(_arrowColor);
        
        [self.utils.backgroundView setArrowColor:arrowColor];
        
        if (invalidateShadow) {
            [self invalidateShadow];
        }
    }
}

- (void)setStaysInScreen:(BOOL)staysInScreen {
    _staysInScreen = staysInScreen;
    
    if (staysInScreen) {
        [self setStaysInContainer:NO];
    }
}

- (void)setStaysInContainer:(BOOL)staysInContainer {
    _staysInContainer = staysInContainer;
    
    if (staysInContainer) {
        [self setStaysInScreen:NO];
    }
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    if ([self isShown]) {
        [self.popoverView setTag:tag];
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
    NSRect frame = [self.utils.contentView frame];
    NSRect contentViewFrame = NSMakeRect(NSMinX(frame), NSMinY(frame), contentSize.width, contentSize.height);
    
    [self.utils.contentView removeConstraints];
    [self.utils.contentView setFrame:contentViewFrame];
    
    if ((notification != nil) && [notification.name isEqualToString:NSWindowWillCloseNotification] && (self.popoverWindow == notification.object)) {
        [self close];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:self.popoverWindow];
    }
    
    if (self.popoverWindow) {
        [self.popoverWindow close];
        self.popoverWindow = nil;
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    [self.utils setupPositioningAnchorWithView:positioningView positioningRect:positioningRect shouldUpdatePosition:shouldUpdatePosition];
}

#pragma mark - Display

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
        __weak typeof(self) wself = self;
        
        [self.utils setLocalUpdatedBlock:^{
            __strong typeof(self) this = wself;
            
            [this.utils removeContentViewEvents];
            
            if ([this.utils.contentView isDescendantOf:this.utils.backgroundView]) {
                [this.utils.contentView removeFromSuperview];
            }
            
            this.utils.contentView = contentView;
            this.utils.contentSize = [contentView frame].size;
            this.utils.originalViewSize = [contentView frame].size;
            
            if (this.utils.popoverStyle == FLOPopoverStyleAlert) {
                // Do nothing
            } else {
                NSRect contentViewFrame = [this.utils.backgroundView contentViewFrameForBackgroundFrame:[this.utils.backgroundView bounds] popoverEdge:this.utils.preferredEdge];
                NSEdgeInsets contentInsets = [this.utils.contentView contentInsetsWithFrame:contentViewFrame];
                
                [this.utils.contentView addAutoResize:YES toParent:this.utils.backgroundView contentInsets:contentInsets];
            }
            
            if ([this.utils.backgroundView isDescendantOf:[this.utils.presentedWindow contentView]]) {
                [this.utils.backgroundView removeFromSuperview];
            }
            
            [[this.utils.presentedWindow contentView] addSubview:this.utils.backgroundView positioned:NSWindowAbove relativeTo:this.utils.positioningAnchorView];
            [this.utils registerContentViewEvents];
            [this updatePopoverFrame];
        }];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    if (![contentViewController isKindOfClass:[NSViewController class]]) return;
    
    if ([self isShown] && !self.isShowing && !self.isClosing) {
        __weak typeof(self) wself = self;
        
        [self.utils setLocalUpdatedBlock:^{
            __strong typeof(self) this = wself;
            
            [this.utils removeContentViewEvents];
            
            if ([this.utils.contentView isDescendantOf:this.utils.backgroundView]) {
                [this.utils.contentView removeFromSuperview];
            }
            
            this.utils.contentViewController = contentViewController;
            this.utils.contentView = contentViewController.view;
            this.utils.contentSize = [contentViewController.view frame].size;
            this.utils.originalViewSize = [contentViewController.view frame].size;
            
            if (this.utils.popoverStyle == FLOPopoverStyleAlert) {
                // Do nothing
            } else {
                NSRect contentViewFrame = [this.utils.backgroundView contentViewFrameForBackgroundFrame:this.utils.backgroundView.bounds popoverEdge:this.utils.preferredEdge];
                NSEdgeInsets contentInsets = [this.utils.contentView contentInsetsWithFrame:contentViewFrame];
                
                [this.utils.contentView addAutoResize:YES toParent:this.utils.backgroundView contentInsets:contentInsets];
            }
            
            if ([this.utils.backgroundView isDescendantOf:[this.utils.presentedWindow contentView]]) {
                [this.utils.backgroundView removeFromSuperview];
            }
            
            [[this.utils.presentedWindow contentView] addSubview:this.utils.backgroundView positioned:NSWindowAbove relativeTo:this.utils.positioningAnchorView];
            [this.utils registerContentViewEvents];
            [this updatePopoverFrame];
        }];
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
        [self.utils removeApplicationEvents];
        
        if ((self.utils.positioningAnchorView != nil) && ([self.utils.positioningAnchorView isDescendantOf:self.utils.positioningView])) {
            [self.utils.positioningAnchorView removeFromSuperview];
            self.utils.positioningAnchorView = nil;
        }
        
        [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
        
        self.utils.senderView = (self.utils.senderView == self.utils.positioningView) ? positioningView : self.utils.senderView;
        self.utils.positioningView = positioningView;
        
        [self.utils registerApplicationEvents];
        [self.utils registerObserverForSuperviews];
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

/**
 * Sticking rect: Re-arrange the popover with new positioningView and edgeType.
 *
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 */
- (void)setPopoverPositioningView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    [self setPopoverPositioningView:positioningView edgeType:edgeType positioningRect:[positioningView visibleRect]];
}

/**
 * Sticking rect: Re-arrange the popover with new positioningView, edgeType and positioningRect.
 *
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 * @param rect 'position' that the popover should be displayed.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 */
- (void)setPopoverPositioningView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType positioningRect:(NSRect)rect {
    if ((positioningView != nil) && (self.utils.positioningView != positioningView)) {
        [self.utils removeApplicationEvents];
        
        if ((self.utils.positioningView == self.utils.positioningAnchorView) && (self.utils.positioningView == self.utils.senderView)) {
            self.utils.positioningFrame = rect;
            self.utils.positioningView = positioningView;
            self.utils.positioningAnchorView = positioningView;
            self.utils.senderView = positioningView;
        }
        
        [self setPopoverEdgeType:edgeType];
        [self.utils registerApplicationEvents];
        [self.utils registerObserverForSuperviews];
        [self updatePopoverFrame];
    }
}

- (void)setUserInteractionEnable:(BOOL)isEnabled {
    _userInteractionEnable = isEnabled;
    
    self.popoverView.userInteractionEnable = isEnabled;
    
    [self.utils setUserInteractionEnable:isEnabled];
}

- (void)setDisabledColor:(NSColor *)disabledColor {
    _disabledColor = disabledColor;
    
    self.popoverView.disabledColor = disabledColor;
    
    [self.utils setDisabledColor:disabledColor];
}

- (void)showWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    [self.utils showWithVisualEffect:needed material:material blendingMode:blendingMode state:state];
}

- (void)updateFrame:(NSRect)frame {
    [self.popoverView setFrame:frame];
}

- (void)updatePopoverFrame {
    if ([self isShown] || self.isShowing) {
        if (self.updatesFrameWhileShowing || (!self.isShowing && !self.isClosing)) {
            [self displayWithAnimationProcess:NO];
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updatePopoverFrame) object:nil];
            [self performSelector:@selector(updatePopoverFrame) withObject:nil afterDelay:0.1];
        }
    }
}

- (void)invalidateShadow {
    [self.popoverView invalidateShadow];
}

- (void)invalidateArrowPathColor {
    [self.utils invalidateArrowPathColor];
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
    if (![self isShown] && !self.isShowing && !self.isClosing) {
        self.isShowing = YES;
        
        if (floPopoverWillShowBlock) floPopoverWillShowBlock(self);
        
        self.utils.positioningFrame = rect;
        self.utils.positioningView = positioningView;
        self.utils.positioningAnchorView = positioningView;
        self.utils.senderView = positioningView;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopoverStyleNormal];
        [self.utils setResponder];
        [self registerForApplicationEvents];
        // Wait for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.05];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self close];
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
    if (![self isShown] && !self.isShowing && !self.isClosing) {
        self.isShowing = YES;
        
        if (floPopoverWillShowBlock) floPopoverWillShowBlock(self);
        
        self.utils.relativePositionType = relativePositionType;
        
        [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
        
        self.utils.positioningFrame = [self.utils.positioningAnchorView bounds];
        self.utils.positioningView = positioningView;
        self.utils.senderView = sender;
        
        [self setPopoverEdgeType:edgeType];
        [self setupPopoverStyleNormal];
        [self.utils setResponder];
        [self registerForApplicationEvents];
        // Wait for content view loading data and update its frame correctly before animation.
        [self performSelector:@selector(show) withObject:nil afterDelay:0.05];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self close];
    }
}

- (void)show {
    [self displayWithAnimationProcess:YES];
}

- (void)setupPopoverStyleNormal {
    __weak typeof(self) wself = self;
    
    [self.utils setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        NSRect contentViewFrame = [this.utils.contentView frame];
        
        [this.utils.backgroundView setFrame:NSMakeRect(kFlowarePopover_OffScreen_Value, kFlowarePopover_OffScreen_Value, NSWidth(contentViewFrame), NSHeight(contentViewFrame))];
        [this.utils.backgroundView setNeedsDisplay:YES];
        [this.utils.backgroundView displayRect:NSMakeRect(kFlowarePopover_OffScreen_Value, kFlowarePopover_OffScreen_Value, NSWidth(contentViewFrame), NSHeight(contentViewFrame))];
        [this.utils.backgroundView setTag:this.tag];
        
        [this.utils.contentView addAutoResize:YES toParent:this.utils.backgroundView];
        [this.utils.backgroundView addAutoResize:NO toParent:[this.utils.presentedWindow contentView]];
        
        [[this.utils.presentedWindow contentView] setWantsLayer:YES];
        [[[this.utils.presentedWindow contentView] layer] setMasksToBounds:NO];
    }];
}

- (void)setupPopoverStyleAlertWithColor:(NSColor *)backgroundColor {
    // Currently do nothing for FLOViewPopover.
}

- (void)displayWithAnimationProcess:(BOOL)displayAnimated {
    self.popoverView = self.utils.backgroundView;
    
    [self.utils setupComponentsForPopover:displayAnimated];
    
    if (displayAnimated) {
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (![self isShown] || self.isClosing || self.isShowing) {
        if (self.isShowing) {
            [self.utils closePopoverWithTimerIfNeeded];
        }
    } else {
        if (!([self.popoverView isDescendantOf:[self.utils.presentedWindow contentView]] || ([self.utils.presentedWindow contentView] == nil) || [self.utils.contentView isDescendantOf:[self.popoverWindow contentView]])) return;
        
        BOOL shouldClose = (floPopoverShouldCloseBlock) ? floPopoverShouldCloseBlock(self) : YES;
        
        if (shouldClose) {
            self.closeEventReceived = NO;
            self.isClosing = YES;
            
            if (floPopoverWillCloseBlock) floPopoverWillCloseBlock(self);
            
            [self removeAllApplicationEvents];
            [self popoverShowing:NO animated:self.animated];
        }
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    if (showing) {
        self.isShowing = NO;
        
        [self.popoverView setAlphaValue:1.0];
        [self.popoverView setShadow:self.hasShadow];
        
        [self.utils registerObserverForSuperviews];
        
        if (floPopoverDidShowBlock) floPopoverDidShowBlock(self);
    } else {
        if ([self.popoverView isDescendantOf:[self.utils.presentedWindow contentView]] || ([self.utils.presentedWindow contentView] == nil) || [self.utils.contentView isDescendantOf:[self.popoverWindow contentView]]) {
            [self resetContentViewFrame:nil];
            
            self.localEvent = nil;
            self.utils = nil;
            
            [self.popoverView removeFromSuperview];
            self.popoverView = nil;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            self.isClosing = NO;
            
            if (floPopoverDidCloseBlock) floPopoverDidCloseBlock(self);
        }
    }
}

#pragma mark - Display animations

- (void)popoverShowing:(BOOL)showing animated:(BOOL)animated {
    if (animated) {
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
    __weak typeof(self) wself = self;
    
    [self.utils setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        __weak FLOPopoverUtils *utils = this.utils;
        __weak FLOPopoverView *popoverView = this.popoverView;
        __weak NSView *backgroundView = utils.backgroundView;
        __weak NSView *contentView = utils.contentView;
        __weak NSView *parentView = [backgroundView superview];
        
        BOOL wantedSuperLayer = parentView.wantsLayer;
        BOOL wantedLayer = backgroundView.wantsLayer;
        
        [parentView setWantsLayer:YES];
        [backgroundView setWantsLayer:YES];
        
        BOOL masksToBounds = [[parentView layer] masksToBounds];
        
        [[parentView layer] setMasksToBounds:NO];
        [[backgroundView layer] removeAllAnimations];
        
        CGFloat scaleValue = showing ? 1.25 : 1.2;
        NSRect frame = [[popoverView window] convertRectToScreen:popoverView.frame];
        CGFloat width = scaleValue * frame.size.width;
        CGFloat height = scaleValue * frame.size.height;
        NSRect scalingFrame = NSIntegralRect(NSMakeRect(NSMinX(frame) - (width - NSWidth(frame)) / 2, NSMinY(frame) - (height - NSHeight(frame)) / 2, width, height));
        NSRect fromFrame = showing ? scalingFrame : frame;
        NSRect toFrame = showing ? frame : scalingFrame;
        
        [backgroundView removeConstraints];
        [popoverView setAlphaValue:1.0];
        [this updateFrame:scalingFrame];
        
        NSRect viewFrame = [[backgroundView window] convertRectFromScreen:frame];
        NSRect windowStartFrame = [[backgroundView window] convertRectFromScreen:fromFrame];
        NSRect windowEndFrame = [[backgroundView window] convertRectFromScreen:toFrame];
        NSRect startFrame = [[[backgroundView window] contentView] convertRect:windowStartFrame toView:parentView];
        NSRect endFrame = [[[backgroundView window] contentView] convertRect:windowEndFrame toView:parentView];
        NSPoint startPosition = NSMakePoint(NSMinX(startFrame), NSMinY(startFrame));
        NSPoint endPosition = NSMakePoint(NSMinX(endFrame), NSMinY(endFrame));
        CGFloat scaleFactorX = showing ? (NSWidth(startFrame) / NSWidth(endFrame)) : (NSWidth(endFrame) / NSWidth(startFrame));
        CGFloat scaleFactorY = showing ? (NSHeight(startFrame) / NSHeight(endFrame)) : (NSHeight(endFrame) / NSHeight(startFrame));
        NSPoint scaleFactor = NSMakePoint(scaleFactorX, scaleFactorY);
        NSTimeInterval duration = showing ? kFlowarePopover_AnimationTimeInterval : 0.15;
        
        [backgroundView setSizeConstraints:viewFrame];
        [backgroundView setFrame:viewFrame];
        [backgroundView setAlphaValue:1.0];
        [contentView setAlphaValue:1.0];
        [contentView display];
        
        __weak typeof(self) wself = this;
        
        void (^completionBlock)(void) = ^{
            __strong typeof(self) this = wself;
            
            [utils setLocalUpdatedBlock:^{
                [parentView setWantsLayer:wantedSuperLayer];
                [[parentView layer] setMasksToBounds:masksToBounds];
                [[backgroundView layer] removeAllAnimations];
                [backgroundView setWantsLayer:wantedLayer];
                [backgroundView removeConstraints];
                [backgroundView addAutoResize:NO toParent:[[popoverView window] contentView]];
                [this updateFrame:viewFrame];
                [this popoverDidStopAnimation];
            }];
        };
        
        if (showing) {
            [backgroundView displayScaleTransitionWithFactor:scaleFactor beginAtPoint:startPosition endAtPoint:endPosition duration:duration removedOnCompletion:NO completion:completionBlock];
        } else {
            [backgroundView closeScaleTransitionWithFactor:scaleFactor beginAtPoint:startPosition endAtPoint:endPosition duration:duration removedOnCompletion:NO completion:completionBlock];
        }
    }];
}

/*
 - FLOPopoverAnimationBehaviorTransition
 */
- (void)popoverTransitionAnimationShowing:(BOOL)showing {
    if (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        [self popoverTransitionAnimationShowing:showing animationType:self.utils.animationType];
    }
}

- (void)popoverTransitionAnimationShowing:(BOOL)showing animationType:(FLOPopoverAnimationType)animationType {
    __weak typeof(self) wself = self;
    
    [self.utils setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        __weak FLOPopoverUtils *utils = this.utils;
        __weak FLOPopoverView *popoverView = this.popoverView;
        __weak NSView *backgroundView = utils.backgroundView;
        __weak NSView *contentView = utils.contentView;
        __weak NSView *parentView = [backgroundView superview];
        
        BOOL wantedSuperLayer = parentView.wantsLayer;
        BOOL wantedLayer = backgroundView.wantsLayer;
        
        [parentView setWantsLayer:YES];
        [backgroundView setWantsLayer:YES];
        
        BOOL masksToBounds = [[parentView layer] masksToBounds];
        
        [[parentView layer] setMasksToBounds:NO];
        [[backgroundView layer] removeAllAnimations];
        
        NSRect frame = [[popoverView window] convertRectToScreen:popoverView.frame];
        NSRect fromFrame = frame;
        NSRect toFrame = frame;
        NSRect transitionFrame = frame;
        
        [utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:utils.animationType forwarding:this.animatedForwarding showing:showing];
        [utils calculateTransitionFrame:&transitionFrame fromFrame:fromFrame toFrame:toFrame animationType:utils.animationType forwarding:this.animatedForwarding showing:showing];
        
        [backgroundView removeConstraints];
        
        [popoverView setAlphaValue:1.0];
        [this updateFrame:transitionFrame];
        
        if (!utils.popoverMoved && utils.animatedInAppFrame && !NSContainsRect(utils.mainWindow.frame, transitionFrame)) {
            NSRect intersectionFrame = NSIntersectionRect(utils.mainWindow.frame, transitionFrame);
            [this updateFrame:intersectionFrame];
        }
        
        NSRect viewFrame = [[backgroundView window] convertRectFromScreen:frame];
        NSRect windowStartFrame = [[backgroundView window] convertRectFromScreen:fromFrame];
        NSRect windowEndFrame = [[backgroundView window] convertRectFromScreen:toFrame];
        NSRect startFrame = [[[backgroundView window] contentView] convertRect:windowStartFrame toView:parentView];
        NSRect endFrame = [[[backgroundView window] contentView] convertRect:windowEndFrame toView:parentView];
        NSPoint startPosition = NSMakePoint(NSMinX(startFrame), NSMinY(startFrame));
        NSPoint endPosition = NSMakePoint(NSMinX(endFrame), NSMinY(endFrame));
        CGFloat scaleFactorX = showing ? (NSWidth(startFrame) / NSWidth(endFrame)) : (NSWidth(endFrame) / NSWidth(startFrame));
        CGFloat scaleFactorY = showing ? (NSHeight(startFrame) / NSHeight(endFrame)) : (NSHeight(endFrame) / NSHeight(startFrame));
        NSPoint scaleFactor = NSMakePoint(scaleFactorX, scaleFactorY);
        NSTimeInterval duration = (this.animationDuration > 0) ? this.animationDuration : kFlowarePopover_AnimationTimeInterval;
        
        [backgroundView setSizeConstraints:viewFrame];
        [backgroundView setFrame:viewFrame];
        [backgroundView setAlphaValue:1.0];
        [contentView setAlphaValue:1.0];
        [contentView display];
        
        __weak typeof(self) wself = this;
        
        void (^completionBlock)(void) = ^{
            __strong typeof(self) this = wself;
            
            [utils setLocalUpdatedBlock:^{
                [parentView setWantsLayer:wantedSuperLayer];
                [[parentView layer] setMasksToBounds:masksToBounds];
                [[backgroundView layer] removeAllAnimations];
                [backgroundView setWantsLayer:wantedLayer];
                [backgroundView removeConstraints];
                [backgroundView addAutoResize:NO toParent:[[popoverView window] contentView]];
                [this updateFrame:viewFrame];
                [this popoverDidStopAnimation];
            }];
        };
        
        if (showing) {
            [backgroundView displayScaleTransitionWithFactor:scaleFactor beginAtPoint:startPosition endAtPoint:endPosition duration:duration removedOnCompletion:NO completion:completionBlock];
        } else {
            [backgroundView closeScaleTransitionWithFactor:scaleFactor beginAtPoint:startPosition endAtPoint:endPosition duration:duration removedOnCompletion:NO completion:completionBlock];
        }
    }];
}

/*
 - FLOPopoverAnimationBehaviorDefault
 */
- (void)popoverDefaultAnimationShowing:(BOOL)showing {
    [self.utils.backgroundView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    
    [self.popoverView setAlphaValue:1.0];
    
    if (showing) {
        [self popoverDidStopAnimation];
    } else {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.16];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self.popoverView setAlphaValue:0.0];
            [self popoverDidStopAnimation];
        }];
        
        [self.popoverView.animator setAlphaValue:0.0];
        
        [NSAnimationContext endGrouping];
    }
}

- (void)popoverDidStopAnimation {
    BOOL isShowing = _popover == nil;
    
    if (isShowing) {
        [self.popoverView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        [self.utils updateContentViewFrameInsets:self.utils.preferredEdge];
        _popover = self.popoverView;
    } else {
        _popover = nil;
    }
    
    [self popoverDidFinishShowing:isShowing];
}

#pragma mark - Event monitor

- (void)registerForApplicationEvents {
    [self registerLocalMonitorForEvents];
    [self.utils registerApplicationEvents];
}

- (void)removeAllApplicationEvents {
    [self removeLocalMonitorForEvents];
    [self.utils removeApplicationEvents];
}

- (void)registerLocalMonitorForEvents {
    if (!self.localEvent) {
        self.localEvent = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent *event) {
            if (event.window == nil) return event;
            if (!self.utils.userInteractionEnable) return event;
            
            NSView *clickedView = [[event.window contentView] hitTest:event.locationInWindow];
            
            if (self.closesWhenPopoverResignsKey) {
                if (!((self.utils.senderView && (clickedView != self.utils.senderView)) || self.closesWhenReceivesEvent)) return event;
                
                // If closesWhenPopoverResignsKey is set as YES and clickedView is the same with self.utils.senderView, DO NOTHING.
                // Because the event received from self.utils.senderView will be fired very later soon.
                BOOL closeNeeded = NO;
                
                if (event.window == [self.popoverView window]) {
                    closeNeeded = !([clickedView isDescendantOf:self.popoverView] || (clickedView == self.popoverView));
                } else {
                    closeNeeded = ![[self.popoverView window] containsChildWindow:event.window];
                }
                
                if (closeNeeded) {
                    self.closeEventReceived = YES;
                    
                    [self.utils closePopoverWithTimerIfNeeded];
                }
            } else {
                NSView *frontView = [[[self.utils.presentedWindow contentView] subviews] lastObject];
                
                if ((frontView != self.popoverView) && ([clickedView isDescendantOf:self.popoverView] || (clickedView == self.popoverView))) {
                    if ([self.popoverView isDescendantOf:[self.utils.presentedWindow contentView]]) {
                        [self.popoverView removeFromSuperview];
                        
                        // Bring the popoverView to front when focusing on it.
                        [[self.utils.presentedWindow contentView] addSubview:self.popoverView positioned:NSWindowAbove relativeTo:self.utils.positioningAnchorView];
                    }
                }
            }
            
            return event;
        }];
    }
}

- (void)removeLocalMonitorForEvents {
    if (self.localEvent) {
        [NSEvent removeMonitor:self.localEvent];
        self.localEvent = nil;
    }
}

#pragma mark - FLOPopoverViewDelegate

- (void)popoverWillMakeMovement {
    self.utils.popoverMoved = YES;
    
    if (floPopoverWillMoveBlock) {
        floPopoverWillMoveBlock(self);
    }
}

- (void)popoverDidMakeMovement {
    if (floPopoverDidMoveBlock) {
        floPopoverDidMoveBlock(self);
    }
}

- (void)popoverDidMakeDetachable:(NSWindow *)targetWindow {
    if ((floPopoverWillDetachBlock != nil) && [self.popoverView isDescendantOf:[targetWindow contentView]]) {
        if (floPopoverWillDetachBlock) {
            floPopoverWillDetachBlock(self);
            floPopoverWillDetachBlock = nil;
        }
        
        __weak typeof(self) wself = self;
        
        [self.utils setLocalUpdatedBlock:^{
            __strong typeof(self) this = wself;
            
            [this removeAllApplicationEvents];
            
            NSView *contentView = this.utils.contentView;
            NSRect contentFrame = [contentView.window contentRectForFrameRect:[contentView.window convertRectToScreen:[contentView convertRect:contentView.bounds toView:[contentView.window contentView]]]];
            NSWindowStyleMask styleMask = this.detachableStyleMask;
            FLOPopoverWindow *window = [[FLOPopoverWindow alloc] initWithContentRect:contentFrame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
            NSRect frame = [window frameRectForContentRect:contentFrame];
            
            [this.utils.backgroundView removeFromSuperview];
            [this.utils.contentView removeFromSuperview];
            
            [window setHasShadow:YES];
            [window setReleasedWhenClosed:NO];
            [window setOpaque:NO];
            [window setBackgroundColor:[NSColor clearColor]];
            [window setCanBecomeKey:YES];
            
            [contentView addAutoResize:YES toParent:[window contentView]];
            
            // Should make window key and order front before setting its frame.
            [window makeKeyAndOrderFront:nil];
            [window setFrame:frame display:YES];
            
            this.popoverWindow = window;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewFrame:) name:NSWindowWillCloseNotification object:self.popoverWindow];
        
        if (floPopoverDidDetachBlock) {
            floPopoverDidDetachBlock(self);
            floPopoverDidDetachBlock = nil;
        }
    }
}

@end
