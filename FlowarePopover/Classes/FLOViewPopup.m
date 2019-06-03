//
//  FLOViewPopup.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FLOViewPopup.h"

#import "FLOExtensionsGraphicsContext.h"
#import "FLOExtensionsNSView.h"

#import "FLOPopover.h"

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

@interface FLOViewPopup () <FLOPopoverBackgroundViewDelegate, NSAnimationDelegate, CAAnimationDelegate>

@property (nonatomic, assign, readwrite) BOOL shown;
@property (nonatomic, assign, readwrite) NSRect initialPositioningFrame;

@property (nonatomic, strong) NSEvent *appEvent;
@property (nonatomic, strong) FLOPopoverUtils *utils;

@property (nonatomic, assign) NSRect initialFrame;

@property (nonatomic, assign) BOOL popoverShowing;
@property (nonatomic, assign) BOOL popoverClosing;

@property (nonatomic, strong) NSView *popoverTempView;
@property (nonatomic, strong) FLOPopoverBackgroundView *popoverView;
@property (nonatomic, strong) FLOPopoverWindow *detachableWindow;

/**
 * View that used for making animation with an animated layer.
 */
@property (nonatomic, strong) NSView *snapshotView;

@end

@implementation FLOViewPopup

@synthesize alwaysOnTop = _alwaysOnTop;
@synthesize shouldShowArrow = _shouldShowArrow;
@synthesize arrowSize = _arrowSize;
@synthesize animated = _animated;
@synthesize animatedForwarding = _animatedForwarding;
@synthesize bottomOffset = _bottomOffset;
@synthesize staysInApplicationFrame = _staysInApplicationFrame;
@synthesize updatesFrameWhileShowing = _updatesFrameWhileShowing;
@synthesize shouldRegisterSuperviewObservers = _shouldRegisterSuperviewObservers;
@synthesize shouldChangeSizeWhenApplicationResizes = _shouldChangeSizeWhenApplicationResizes;
@synthesize closesWhenPopoverResignsKey = _closesWhenPopoverResignsKey;
@synthesize closesWhenApplicationBecomesInactive = _closesWhenApplicationBecomesInactive;
@synthesize closesWhenApplicationResizes = _closesWhenApplicationResizes;
@synthesize closesWhenNotBelongToContainerFrame = _closesWhenNotBelongToContainerFrame;
@synthesize closesWhenReceivesEvent = _closesWhenReceivesEvent;
@synthesize isMovable = _isMovable;
@synthesize isDetachable = _isDetachable;
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
        _utils = [[FLOPopoverUtils alloc] init];
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _arrowSize = NSZeroSize;
        _animated = NO;
        _animatedForwarding = NO;
        _bottomOffset = FLO_CONST_POPOVER_BOTTOM_OFFSET;
        _staysInApplicationFrame = NO;
        _updatesFrameWhileShowing = NO;
        _shouldRegisterSuperviewObservers = YES;
        _shouldChangeSizeWhenApplicationResizes = NO;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _closesWhenNotBelongToContainerFrame = YES;
        _closesWhenReceivesEvent = NO;
        _isMovable = NO;
        _isDetachable = NO;
        _tag = -1;
        _animatedByMovingFrame = NO;
        _animationDuration = 0.0;
        _needAutoresizingMask = NO;
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
        _utils.backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentView.frame];
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
        _utils.backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentViewController.view.frame];
    }
    
    return self;
}

- (void)dealloc {
    self.appEvent = nil;
    self.utils = nil;
    
    [self.popoverView removeFromSuperview];
    self.popoverView = nil;
    
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
    return self.popoverView.frame;
}

- (BOOL)isShown {
    return _shown;
}

- (void)setShouldShowArrow:(BOOL)shouldShowArrow {
    _shouldShowArrow = shouldShowArrow;
    
    if (shouldShowArrow && NSEqualSizes(self.arrowSize, NSZeroSize)) {
        self.arrowSize = NSMakeSize(PopoverBackgroundViewArrowWidth, PopoverBackgroundViewArrowHeight);
    } else {
        self.arrowSize = NSZeroSize;
    }
}

- (void)setStaysInApplicationFrame:(BOOL)staysInApplicationFrame {
    _staysInApplicationFrame = staysInApplicationFrame;
    
    self.utils.staysInApplicationFrame = staysInApplicationFrame;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    if ([self isShown]) {
        self.popoverView.tag = tag;
    }
}

#pragma mark - Local methods

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    [self.utils setPopoverEdgeType:edgeType];
}

- (void)setTopMostViewIfNecessary {
    NSView *topView = [FLOPopoverUtils sharedInstance].topView;
    NSArray *viewStack = self.utils.appMainWindow.contentView.subviews;
    
    if ((topView != nil) && [viewStack containsObject:topView]) {
        [topView removeFromSuperview];
        [self.utils.appMainWindow.contentView addSubview:topView];
    }
}

- (void)resetContentViewFrame:(NSNotification *)notification {
    NSSize contentSize = [self.utils.backgroundView contentViewSizeForSize:self.utils.originalViewSize];
    
    self.utils.contentView.frame = NSMakeRect(self.utils.contentView.frame.origin.x, self.utils.contentView.frame.origin.y, contentSize.width, contentSize.height);
    
    if ([notification.name isEqualToString:NSWindowWillCloseNotification] && (self.detachableWindow == notification.object)) {
        [self close];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:self.detachableWindow];
    }
    
    if (self.detachableWindow) {
        [self.detachableWindow close];
        self.detachableWindow = nil;
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    [self.utils setupPositioningAnchorWithView:positioningView positioningRect:positioningRect shouldUpdatePosition:shouldUpdatePosition];
}

- (void)addSuperviewObserversForView:(NSView *)view {
    if ([view isKindOfClass:[NSClipView class]]) {
        [view setPostsBoundsChangedNotifications:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clipViewBoundsDidChangeNotification:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:view];
    } else {
        [view addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        [view addObserver:self forKeyPath:@"superview" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    }
}

- (void)updatePopoverFrame {
    if ([self isShown]) {
        if (self.updatesFrameWhileShowing || ((self.popoverShowing == NO) && (self.popoverClosing == NO))) {
            [self displayWithAnimationProcess:NO];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                while (true) {
                    if ((self.popoverShowing == NO) && (self.popoverClosing == NO)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self displayWithAnimationProcess:NO];
                        });
                        
                        break;
                    }
                }
            });
        }
    }
}

- (void)updatePopoverFrameForContainerFrame:(NSRect)containerFrame {
    NSRect positionWindowFrame = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
    
    if (NSEqualPoints(self.utils.positioningWindowFrame.origin, positionWindowFrame.origin) == NO) {
        NSRect positionScreenFrame = [self.utils.positioningView.window convertRectToScreen:positionWindowFrame];
        
        positionScreenFrame = NSMakeRect(positionScreenFrame.origin.x, positionScreenFrame.origin.y, 1.0, 1.0);
        
        NSRect popoverFrame = [self.utils popoverFrameForEdge:self.utils.preferredEdge];
        
        popoverFrame = (NSRect){ .origin = popoverFrame.origin, .size = self.popoverView.frame.size };
        
        if (NSContainsRect(containerFrame, positionScreenFrame) == NO) {
            // If the positioningView (the sender where arrow is displayed at) move out of containerFrame, we should hide the arrow of popover.
            if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView) && (NSEqualSizes(self.arrowSize, NSZeroSize) == NO)) {
                self.utils.backgroundView.arrowSize = NSZeroSize;
                [self.utils.backgroundView showArrow:NO];
            }
            
            return;
        }
        
        if (NSEqualRects(containerFrame, self.utils.appMainWindow.frame) == NO) {
            containerFrame = NSMakeRect(containerFrame.origin.x, containerFrame.origin.y, self.utils.appMainWindow.frame.size.width - (containerFrame.origin.x - self.utils.appMainWindow.frame.origin.x), containerFrame.size.height);
        }
        
        // If the positioningView (the sender where arrow is displayed at) move inside of containerFrame, we should show the arrow of popover.
        // And also update the arrow position respectively to the new popoverOrigin
        if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView) && (NSEqualSizes(self.arrowSize, NSZeroSize) == NO)) {
            NSRect windowRelativeFrame = [self.utils.positioningAnchorView convertRect:[self.utils.positioningAnchorView alignmentRectForFrame:self.utils.positioningFrame] toView:nil];
            NSRect positionScreenFrame = [self.utils.positioningAnchorView.window convertRectToScreen:windowRelativeFrame];
            
            self.utils.backgroundView.popoverOrigin = positionScreenFrame;
            self.utils.backgroundView.arrowSize = self.arrowSize;
            
            [self.utils.backgroundView showArrow:YES];
        }
        
        if (NSContainsRect(containerFrame, popoverFrame) == NO) {
            if (self.closesWhenNotBelongToContainerFrame) {
                [self close];
            }
            
            return;
        }
        
        popoverFrame = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverFrame];
        popoverFrame = (NSRect){ .origin = popoverFrame.origin, .size = self.popoverView.frame.size };
        
        [self.popoverView setFrame:popoverFrame];
        
        self.utils.positioningWindowFrame = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
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
    
    if (self.popoverView.layer != nil) {
        [self.popoverView.layer removeAllAnimations];
    }
    
    [self.popoverView setFrame:self.initialFrame];
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
    if ([contentView isKindOfClass:[NSView class]] == NO) return;
    
    if ([self isShown] && (self.popoverShowing == NO) && (self.popoverClosing == NO)) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentView setFrame:self.utils.contentView.frame];
        
        self.utils.contentView = contentView;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([self.utils.backgroundView isDescendantOf:self.utils.positioningAnchorView.window.contentView]) {
            [self.utils.backgroundView removeFromSuperview];
        }
        
        [self.utils.positioningAnchorView.window.contentView addSubview:self.utils.backgroundView positioned:NSWindowAbove relativeTo:self.utils.positioningAnchorView];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    if ([contentViewController isKindOfClass:[NSViewController class]] == NO) return;
    
    if ([self isShown] && (self.popoverShowing == NO) && (self.popoverClosing == NO)) {
        if ([self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
            [self.utils.contentView removeFromSuperview];
        }
        
        [contentViewController.view setFrame:self.utils.contentView.frame];
        
        self.utils.contentViewController = contentViewController;
        self.utils.contentView = contentViewController.view;
        
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
        
        if ([self.utils.backgroundView isDescendantOf:self.utils.positioningAnchorView.window.contentView]) {
            [self.utils.backgroundView removeFromSuperview];
        }
        
        [self.utils.positioningAnchorView.window.contentView addSubview:self.utils.backgroundView positioned:NSWindowAbove relativeTo:self.utils.positioningAnchorView];
    }
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    if (NSEqualSizes(newSize, self.utils.contentSize)) return;
    
    if (NSEqualSizes(newSize, NSZeroSize) == NO) {
        self.utils.originalViewSize = newSize;
        self.utils.contentSize = newSize;
    }
    
    [self updatePopoverFrame];
}

- (void)setPopoverPositioningRect:(NSRect)rect {
    if (NSEqualRects(rect, NSZeroRect) == NO) {
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
    if ((NSEqualSizes(newSize, NSZeroSize) == NO) && (NSEqualSizes(newSize, self.utils.contentSize) == NO)) {
        self.utils.originalViewSize = newSize;
        self.utils.contentSize = newSize;
    }
    
    [self setPopoverPositioningRect:rect];
}

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    self.utils.shouldShowArrowWithVisualEffect = needed;
    self.utils.arrowVisualEffectMaterial = material;
    self.utils.arrowVisualEffectBlendingMode = blendingMode;
    self.utils.arrowVisualEffectState = state;
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
    
    if ((self.popoverShowing == NO) && (self.popoverClosing == NO)) {
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
    
    if ((self.popoverShowing == NO) && (self.popoverClosing == NO)) {
        self.popoverShowing = YES;
        self.initialPositioningFrame = rect;
        
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

- (void)show {
    [self displayWithAnimationProcess:YES];
}

- (void)setupPopover {
    self.utils.backgroundView.frame = NSMakeRect(SHRT_MIN, SHRT_MIN, self.utils.contentView.frame.size.width, self.utils.contentView.frame.size.height);
    
    [self.utils.backgroundView setNeedsDisplay:YES];
    [self.utils.backgroundView displayRect:NSMakeRect(SHRT_MIN, SHRT_MIN, self.utils.contentView.frame.size.width, self.utils.contentView.frame.size.height)];
    
    if (![self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
        [self.utils addView:self.utils.contentView toParent:self.utils.backgroundView];
    }
    
    if (![self.utils.backgroundView isDescendantOf:self.utils.positioningAnchorView.window.contentView]) {
        [self.utils addView:self.utils.backgroundView toParent:self.utils.positioningAnchorView.window.contentView];
    }
    
    [self.utils setupAutoresizingMaskIfNeeded:YES];
    
    self.utils.backgroundView.tag = self.tag;
}

- (void)displayWithAnimationProcess:(BOOL)needed {
    if (NSEqualRects(self.utils.positioningFrame, NSZeroRect)) {
        self.utils.positioningFrame = [self.utils.positioningAnchorView bounds];
    }
    
    NSRect windowRelativeFrame = [self.utils.positioningAnchorView convertRect:[self.utils.positioningAnchorView alignmentRectForFrame:self.utils.positioningFrame] toView:nil];
    NSRect positionScreenFrame = [self.utils.positioningAnchorView.window convertRectToScreen:windowRelativeFrame];
    
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
    }
    
    [self.utils.backgroundView showShadow:YES];
    
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
    popoverFrame = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverFrame];
    
    // Update arrow edge and content view frame
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils p_backgroundViewShouldUpdate:YES];
    }
    
    self.utils.originalViewSize = self.utils.backgroundView.frame.size;
    self.initialFrame = popoverFrame;
    
    [self.utils.backgroundView setFrame:popoverFrame];
    
    self.popoverView = self.utils.backgroundView;
    
    self.utils.verticalMarginOutOfPopover = self.utils.appMainWindow.contentView.visibleRect.size.height + self.bottomOffset - NSMaxY(popoverFrame);
    self.utils.positioningWindowFrame = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
    
    if (needed) {
        if (self.alwaysOnTop) {
            [self.utils setTopmostView:self.utils.backgroundView];
        }
        
        [self setTopMostViewIfNecessary];
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (![self isShown]) return;
    
    if ([self.popoverView isDescendantOf:self.utils.positioningAnchorView.window.contentView] ||
        (self.utils.positioningAnchorView.window.contentView == nil) || (self.utils.contentView == self.detachableWindow.contentView)) {
        if ((self.popoverClosing == NO) && (self.popoverShowing == NO)) {
            self.popoverClosing = YES;
            
            if (willCloseBlock) willCloseBlock(self);
            
            [self.utils setupAutoresizingMaskIfNeeded:NO];
            [self removeAllApplicationEvents];
            [self popoverShowing:NO animated:self.animated];
        }
    }
}

- (void)closePopoverWhileAnimatingIfNeeded:(BOOL)isNeeded {
    if (!isNeeded) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.popoverShowing) {
        _shown = YES;
        
        self.popoverShowing = NO;
        
        [self removeAnimationProcessIfNeeded:YES];
        
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1];
    } else {
        [self close];
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    _shown = showing;
    
    if (showing == YES) {
        self.popoverView.alphaValue = 1.0;
        
        self.popoverShowing = NO;
        
        [self.utils setupAutoresizingMaskIfNeeded:YES];
        
        if (didShowBlock) didShowBlock(self);
    } else {
        if ([self.popoverView isDescendantOf:self.utils.positioningAnchorView.window.contentView] ||
            (self.utils.positioningAnchorView.window.contentView == nil) || (self.utils.contentView == self.detachableWindow.contentView)) {
            [self resetContentViewFrame:nil];
            
            self.appEvent = nil;
            self.utils = nil;
            
            [self.popoverView removeFromSuperview];
            self.popoverView = nil;
            
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            self.popoverClosing = NO;
            
            if (didCloseBlock) didCloseBlock(self);
        }
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
    if ([self.snapshotView isDescendantOf:self.popoverView.window.contentView]) {
        [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
        [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
    }
    
    CGFloat scaleFactor = showing ? 1.25 : 1.2;
    NSRect frame = self.popoverView.frame;
    CGFloat width = scaleFactor * frame.size.width;
    CGFloat height = scaleFactor * frame.size.height;
    CGFloat x = frame.origin.x - (width - frame.size.width) / 2;
    CGFloat y = frame.origin.y - (height - frame.size.height) / 2;
    NSRect scalingFrame = NSMakeRect(x, y, width, height);
    
    [self.popoverView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    [self.popoverView setAlphaValue:0.01];
    [self.utils.contentView setAlphaValue:0.01];
    
    CGFloat layerX = (scalingFrame.size.width - frame.size.width) / 2;
    CGFloat layerY = (scalingFrame.size.height - frame.size.height) / 2;
    NSRect layerFrame = NSMakeRect(layerX, layerY, frame.size.width, frame.size.height);
    CALayer *animatedLayer = [CALayer layer];
    animatedLayer.contents = snapshotImage;
    animatedLayer.frame = layerFrame;
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[NSView alloc] initWithFrame:scalingFrame];
    }
    
    self.snapshotView.wantsLayer = YES;
    self.snapshotView.frame = scalingFrame;
    [self.snapshotView.layer addSublayer:animatedLayer];
    
    [self.popoverView.window.contentView addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.popoverView];
    
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
        if ([self.snapshotView isDescendantOf:self.popoverView.window.contentView]) {
            [self.snapshotView removeFromSuperview];
            [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
            [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
        }
        
        if (showing == NO) {
            self.snapshotView = nil;
        }
        
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
    if ([self.snapshotView isDescendantOf:self.popoverView.window.contentView]) {
        [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
        [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
    }
    
    NSRect frame = self.popoverView.frame;
    NSRect fromFrame = frame;
    NSRect toFrame = frame;
    
    [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    NSRect transitionFrame = frame;
    
    [self.utils calculateTransitionFrame:&transitionFrame fromFrame:fromFrame toFrame:toFrame animationType:animationType forwarding:self.animatedForwarding showing:showing];
    
    [self.popoverView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.contentView];
    
    [self.popoverView setAlphaValue:0.01];
    [self.utils.contentView setAlphaValue:0.01];
    
    [self.popoverView setFrame:frame];
    
    CGFloat layerX = fromFrame.origin.x - transitionFrame.origin.x;
    CGFloat layerY = fromFrame.origin.y - transitionFrame.origin.y;
    NSRect layerFrame = NSMakeRect(layerX, layerY, frame.size.width, frame.size.height);
    CALayer *animatedLayer = [CALayer layer];
    animatedLayer.contents = snapshotImage;
    animatedLayer.frame = layerFrame;
    
    if (self.snapshotView == nil) {
        self.snapshotView = [[NSView alloc] initWithFrame:transitionFrame];
    }
    
    self.snapshotView.wantsLayer = YES;
    self.snapshotView.frame = transitionFrame;
    [self.snapshotView.layer addSublayer:animatedLayer];
    
    [self.popoverView.window.contentView addSubview:self.snapshotView positioned:NSWindowAbove relativeTo:self.popoverView];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:nil];
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fromValue = @(showing ? 0.0 : 1.0);
    opacityAnimation.toValue = @(showing ? 1.0 : 0.0);
    
    NSPoint startPosition = NSMakePoint(fromFrame.origin.x - transitionFrame.origin.x, fromFrame.origin.y - transitionFrame.origin.y);
    NSPoint endPosition = NSMakePoint(toFrame.origin.x - transitionFrame.origin.x, toFrame.origin.y - transitionFrame.origin.y);
    
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
    
    NSTimeInterval duration = FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD;
    
    if (self.animationDuration > 0) {
        duration = self.animationDuration;
    }
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if ([self.snapshotView isDescendantOf:self.popoverView.window.contentView]) {
            [self.snapshotView removeFromSuperview];
            [[self.snapshotView.layer.sublayers lastObject] removeAllAnimations];
            [[self.snapshotView.layer.sublayers lastObject] removeFromSuperlayer];
        }
        
        if (showing == NO) {
            self.snapshotView = nil;
        }
        
        [self popoverDidStopAnimation];
    }];
    
    [animatedLayer addAnimation:opacityAnimation forKey:@"opacity"];
    [animatedLayer addAnimation:transitionAnimation forKey:transitionAnimationKey];
    
    [CATransaction commit];
    [NSAnimationContext endGrouping];
}

- (void)popoverTransitionAnimationFrameShowing:(BOOL)showing {
    if (self.animatedByMovingFrame && (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition)) {
        __block NSRect frame = self.popoverView.frame;
        NSRect fromFrame = frame;
        NSRect toFrame = frame;
        
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:self.utils.animationType forwarding:self.animatedForwarding showing:showing];
        
        NSPoint beginPoint = fromFrame.origin;
        NSPoint endedPoint = toFrame.origin;
        
        [self.popoverView setFrame:fromFrame];
        
        void(^animationDidStop)(void) = ^{
            [self.popoverView setFrame:frame];
            
            [self popoverDidStopAnimation];
        };
        
        if (showing) {
            [self.popoverView displayAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
                animationDidStop();
            }];
        } else {
            [self.popoverView closeAnimatedWillBeginAtPoint:beginPoint endAtPoint:endedPoint handler:^{
                animationDidStop();
            }];
        }
    }
}

/*
 - FLOPopoverAnimationBehaviorDefault
 */
- (void)popoverDefaultAnimationShowing:(BOOL)showing {
    if (showing) {
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        self.popoverView.alphaValue = 0.0;
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.17];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            self.popoverView.alphaValue = 1.0;
            
            [self popoverDidStopAnimation];
        }];
        
        self.popoverView.animator.alphaValue = 1.0;
        
        [NSAnimationContext endGrouping];
    } else {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            context.duration = 0.095;
            self.popoverView.alphaValue = 0.0;
        } completionHandler:^{
            [self popoverDidStopAnimation];
        }];
    }
}

- (void)popoverDidStopAnimation {
    BOOL isShown = self.popoverTempView == nil;
    
    if (isShown) {
        [self.popoverView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        self.popoverTempView = self.popoverView;
    } else {
        self.popoverTempView = nil;
    }
    
    [self popoverDidFinishShowing:isShown];
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
    
    if (self.closesWhenApplicationBecomesInactive) {
        [self registerApplicationActiveNotification];
    }
    
    [self registerSuperviewObserversForPositioningAnchor];
    [self registerWindowResizeEvent];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self removeApplicationActiveNotification];
    [self unregisterSuperviewObserversForPositioningAnchor];
    [self removeWindowResizeEvent];
}

- (void)registerApplicationActiveNotification {
    if (self.closesWhenApplicationBecomesInactive) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appResignedActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
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
            NSView *clickedView = [event.window.contentView hitTest:event.locationInWindow];
            
            if (self.closesWhenPopoverResignsKey) {
                // If closesWhenPopoverResignsKey is set as YES and clickedView is the same with self.utils.senderView, DO NOTHING.
                // Because the event received from self.utils.senderView will be fired very later soon.
                if ((self.utils.senderView && (clickedView != self.utils.senderView)) || self.closesWhenReceivesEvent) {
                    if (self.popoverView.window == event.window) {
                        if (!([clickedView isDescendantOf:self.popoverView] || (clickedView == self.popoverView))) {
                            [self closePopoverWhileAnimatingIfNeeded:YES];
                        }
                    } else {
                        BOOL contained = [self.utils didWindow:self.popoverView.window contain:event.window];
                        
                        if (contained == NO) {
                            [self closePopoverWhileAnimatingIfNeeded:YES];
                        }
                    }
                }
            } else {
                NSView *frontView = [self.utils.positioningAnchorView.window.contentView.subviews lastObject];
                
                if ((frontView != self.popoverView) && ([clickedView isDescendantOf:self.popoverView] || (clickedView == self.popoverView))) {
                    if ([self.popoverView isDescendantOf:self.utils.positioningAnchorView.window.contentView]) {
                        [self.popoverView removeFromSuperview];
                        
                        // Bring the popoverView to front when focusing on it.
                        [self.utils.positioningAnchorView.window.contentView addSubview:self.popoverView positioned:NSWindowAbove relativeTo:self.utils.positioningAnchorView];
                    }
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
    if (self.shouldRegisterSuperviewObservers) {
        self.utils.anchorSuperviews = [[NSMutableArray alloc] init];
        
        [self.utils.anchorSuperviews addObject:self.utils.positioningAnchorView];
        
        [self addSuperviewObserversForView:self.utils.positioningAnchorView];
        
        NSView *anchorSuperview = [self.utils.positioningAnchorView superview];
        
        while (anchorSuperview != nil) {
            if ([anchorSuperview isKindOfClass:[NSView class]]) {
                [self.utils.anchorSuperviews addObject:anchorSuperview];
                
                [self addSuperviewObserversForView:anchorSuperview];
            }
            
            anchorSuperview = [anchorSuperview superview];
        }
    }
    
    if (self.closesWhenApplicationResizes) {
        [self.utils.appMainWindow.contentView addObserver:self forKeyPath:@"frame"
                                                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                                  context:NULL];
    }
}

- (void)unregisterSuperviewObserversForPositioningAnchor {
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
        [self.utils.appMainWindow.contentView removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)registerWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
}

- (void)removeWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
}

#pragma mark - Utilities

- (void)closePopover:(NSResponder *)sender {
    _shown = YES;
    self.popoverShowing = NO;
    self.popoverClosing = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeAnimationProcessIfNeeded:YES];
    [self close];
}

- (void)closePopover:(NSResponder *)sender completion:(void (^)(void))complete {
    // code ...
}

- (BOOL)shouldClosePopoverByCheckingChangedView:(NSView *)changedView {
    if ([changedView.window isVisible] == NO) {
        return YES;
    }
    
    if ([self.utils.anchorSuperviews containsObject:changedView]) {
        if ((changedView != self.utils.positioningAnchorView) && ![self.utils.positioningAnchorView isDescendantOf:changedView]) {
            return YES;
        }
        
        NSInteger index = [self.utils.anchorSuperviews indexOfObject:changedView];
        
        if (index < (self.utils.anchorSuperviews.count - 1)) {
            NSView *anchorSuperview = [self.utils.anchorSuperviews objectAtIndex:(index + 1)];
            NSView *changingSuperview = [changedView superview];
            
            if (anchorSuperview != changingSuperview) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)clipViewBoundsDidChangeNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSViewBoundsDidChangeNotification] && [notification.object isKindOfClass:[NSClipView class]] && [self.utils.anchorSuperviews containsObject:notification.object]) {
        NSClipView *clipView = (NSClipView *)notification.object;
        NSRect clipViewScreenFrame = [clipView.window convertRectToScreen:[clipView convertRect:clipView.bounds toView:clipView.window.contentView]];
        
        if ((self.popoverShowing == NO) && (self.popoverClosing == NO) && [self.utils.positioningAnchorView isDescendantOf:clipView]) {
            self.utils.containerBoundsChangedByNotification = YES;
            
            [self updatePopoverFrameForContainerFrame:clipViewScreenFrame];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self.utils selector:@selector(resetContainerBoundsChangedByNotification) object:nil];
            [self.utils performSelector:@selector(resetContainerBoundsChangedByNotification) withObject:nil afterDelay:1.0];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.shouldRegisterSuperviewObservers) {
        if ([keyPath isEqualToString:@"superview"] && [object isKindOfClass:[NSView class]]) {
            NSView *view = (NSView *)object;
            
            if ([self shouldClosePopoverByCheckingChangedView:view]) {
                [self closePopover:nil];
                return;
            }
        }
    }
    
    if ([self.utils appMainWindowResized]) return;
    
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *)object;
        
        if (view == self.utils.appMainWindow.contentView) {
            [self.utils setAppMainWindowResized:YES];
            
            if (self.closesWhenPopoverResignsKey || self.closesWhenApplicationResizes) {
                [self closePopover:nil];
            }
            
            return;
        }
        
        if (self.shouldRegisterSuperviewObservers) {
            if ([self shouldClosePopoverByCheckingChangedView:view]) {
                [self closePopover:nil];
                return;
            }
            
            if ((self.popoverShowing == NO) && (self.popoverClosing == NO) && [self.utils.positioningAnchorView isDescendantOf:view]) {
                if (self.utils.containerBoundsChangedByNotification == NO) {
                    [self updatePopoverFrameForContainerFrame:self.utils.appMainWindow.frame];
                }
            }
        }
    }
}

- (void)appResignedActive:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSApplicationDidResignActiveNotification]) {
        [self close];
    }
}

- (void)windowDidResize:(NSNotification *)notification {
    if ((self.popoverShowing == NO) && (self.popoverClosing == NO) && [notification.name isEqualToString:NSWindowDidResizeNotification] && (notification.object == self.utils.appMainWindow)) {
        if (self.closesWhenApplicationResizes == NO) {
            NSWindow *resizedWindow = (NSWindow *)notification.object;
            NSRect popoverFrame = (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) ? [self.utils p_popoverFrame] : [self.utils popoverFrameForEdge:self.utils.preferredEdge];
            popoverFrame = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverFrame];
            
            CGFloat popoverOriginX = popoverFrame.origin.x;
            CGFloat popoverOriginY = popoverFrame.origin.y;
            
            if (self.shouldChangeSizeWhenApplicationResizes) {
                CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.utils.verticalMarginOutOfPopover;
                CGFloat deltaHeight = popoverFrame.size.height - newHeight;
                CGFloat popoverHeight = newHeight;
                
                popoverOriginY = popoverFrame.origin.y + deltaHeight;
                
                popoverFrame = NSMakeRect(popoverOriginX, popoverOriginY, popoverFrame.size.width, popoverHeight);
            } else {
                popoverFrame = NSMakeRect(popoverOriginX, popoverOriginY, self.utils.originalViewSize.width, self.utils.originalViewSize.height);
            }
            
            // Update arrow edge and content view frame
            if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
                [self.utils p_backgroundViewShouldUpdate:YES];
            }
            
            [self.popoverView setFrame:popoverFrame];
            
            if (NSEqualSizes(self.utils.backgroundView.arrowSize, NSZeroSize) == NO) {
                if ((self.utils.preferredEdge == NSRectEdgeMinY) || (self.utils.preferredEdge == NSRectEdgeMaxY)) {
                    self.utils.contentSize = NSMakeSize(self.popoverView.frame.size.width, self.popoverView.frame.size.height - self.utils.backgroundView.arrowSize.height);
                } else {
                    self.utils.contentSize = NSMakeSize(self.popoverView.frame.size.width - self.utils.backgroundView.arrowSize.height, self.popoverView.frame.size.height);
                }
            } else {
                self.utils.contentSize = self.popoverView.frame.size;
            }
            
            if (!(self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView))) {
                NSRect contentViewFrame = [self.utils.backgroundView contentViewFrameForBackgroundFrame:self.utils.backgroundView.bounds popoverEdge:self.utils.preferredEdge];
                self.utils.contentView.frame = contentViewFrame;
            }
            
            self.utils.positioningWindowFrame = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
        }
    }
}

#pragma mark - FLOPopoverBackgroundViewDelegate

- (void)popoverDidMakeMovement {
    self.utils.popoverMoved = YES;
    
    if (didMoveBlock) {
        didMoveBlock(self);
        
        didMoveBlock = nil;
    }
}

- (void)popoverDidMakeDetachable:(NSWindow *)targetWindow {
    if ([self.popoverView isDescendantOf:targetWindow.contentView]) {
        [self removeAllApplicationEvents];
        
        if (didDetachBlock) {
            didDetachBlock(self);
            
            didDetachBlock = nil;
        }
        
        [self.utils.backgroundView removeFromSuperview];
        [self.utils.contentView removeFromSuperview];
        
        NSView *contentView = self.utils.contentView;
        NSRect contentViewFrame = [self.utils.positioningAnchorView.window convertRectToScreen:self.popoverView.frame];
        NSUInteger styleMask = NSWindowStyleMaskTitled + NSWindowStyleMaskClosable;
        
        self.detachableWindow = [[FLOPopoverWindow alloc] initWithContentRect:contentViewFrame styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
        NSRect detachableFrame = [self.detachableWindow frameRectForContentRect:contentViewFrame];
        
        self.detachableWindow.hasShadow = YES;
        self.detachableWindow.releasedWhenClosed = NO;
        self.detachableWindow.opaque = NO;
        self.detachableWindow.backgroundColor = NSColor.clearColor;
        self.detachableWindow.contentView = contentView;
        
        [contentView setNeedsUpdateConstraints:YES];
        [contentView updateConstraints];
        [contentView updateConstraintsForSubtreeIfNeeded];
        [contentView layoutSubtreeIfNeeded];
        
        self.detachableWindow.canBecomeKey = YES;
        [self.detachableWindow makeKeyAndOrderFront:nil];
        [self.detachableWindow setFrame:detachableFrame display:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewFrame:) name:NSWindowWillCloseNotification object:self.detachableWindow];
    }
}

@end
