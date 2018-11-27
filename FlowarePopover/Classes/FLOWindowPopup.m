//
//  FLOWindowPopup.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOWindowPopup.h"

#import <QuartzCore/QuartzCore.h>

#import "FLOExtensionsGraphicsContext.h"
#import "FLOExtensionsNSView.h"
#import "FLOExtensionsNSWindow.h"

#import "FLOPopover.h"

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

@interface FLOWindowPopup () <FLOPopoverBackgroundViewDelegate, NSAnimationDelegate, CAAnimationDelegate>

@property (nonatomic, strong) NSEvent *appEvent;
@property (nonatomic, strong) FLOPopoverUtils *utils;

@property (nonatomic, strong) NSWindow *popoverTempWindow;
@property (nonatomic, strong) FLOPopoverWindow *popoverWindow;
@property (nonatomic, assign) NSWindowLevel popoverWindowLevel;

@end

@implementation FLOWindowPopup

@synthesize willShowBlock;
@synthesize didShowBlock;
@synthesize willCloseBlock;
@synthesize didCloseBlock;

- (instancetype)init {
    if (self = [super init]) {
        _utils = [[FLOPopoverUtils alloc] init];
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _animated = NO;
        _animatedForwarding = NO;
        _shouldChangeSizeWhenApplicationResizes = YES;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _isMovable = NO;
        _isDetachable = NO;
        _canBecomeKey = YES;
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
        _utils.backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentView.frame];
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
        _utils.backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentViewController.view.frame];
    }
    
    return self;
}

- (void)dealloc {
    self.appEvent = nil;
    self.utils = nil;
    
    [self.popoverWindow close];
    self.popoverWindow = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Processes

- (BOOL)isShown {
    return self.popoverWindow.isVisible;
}

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    [self.utils setPopoverEdgeType:edgeType];
}

- (void)setTopMostWindowIfNecessary {
    NSWindow *topWindow = [FLOPopoverUtils sharedInstance].topWindow;
    NSArray *windowStack = self.utils.appMainWindow.childWindows;
    
    if ((topWindow != nil) && [windowStack containsObject:topWindow]) {
        NSWindowLevel topWindowLevel = topWindow.level;
        
        [self.utils.appMainWindow removeChildWindow:topWindow];
        [self.utils.appMainWindow addChildWindow:topWindow ordered:NSWindowAbove];
        topWindow.level = topWindowLevel;
    }
}

- (void)resetContentViewRect:(NSNotification *)notification {
    self.utils.contentView.frame = NSMakeRect(self.utils.contentView.frame.origin.x, self.utils.contentView.frame.origin.y, self.utils.originalViewSize.width, self.utils.originalViewSize.height);
    
    if ([notification.name isEqualToString:NSWindowWillCloseNotification] && (self.popoverWindow == notification.object)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    [self.utils setupPositioningAnchorWithView:positioningView positioningRect:positioningRect shouldUpdatePosition:shouldUpdatePosition];
}

- (void)addSuperviewObserversForView:(NSView *)view {
    [view addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [view addObserver:self forKeyPath:@"superview" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
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

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType {
    self.utils.animationBehaviour = animationBehaviour;
    self.utils.animationType = animationType;
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    self.utils.originalViewSize = newSize;
    self.utils.contentSize = newSize;
    
    if ([self isShown]) {
        [self showIfNeeded:NO];
    }
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect; {
    self.utils.originalViewSize = newSize;
    self.utils.contentSize = newSize;
    
    [self setupPositioningAnchorWithView:self.utils.positioningView positioningRect:rect shouldUpdatePosition:YES];
    
    if ([self isShown]) {
        [self showIfNeeded:NO];
    }
}

/**
 * Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    if ([self isShown]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self performSelector:@selector(close) withObject:nil afterDelay:0.03];
        
        return;
    }
    
    if (willShowBlock) willShowBlock(self);
    
    self.utils.positioningRect = rect;
    self.utils.positioningView = positioningView;
    self.utils.positioningAnchorView = positioningView;
    
    [self setPopoverEdgeType:edgeType];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0.03];
    
    [self registerForApplicationEvents];
}

/**
 * Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed at.
 * @param rect the given rect that popover should be displayed at.
 * @param edgeType 'position' that the popover should be displayed.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect edgeType:(FLOPopoverEdgeType)edgeType {
    [self showRelativeToView:positioningView withRect:rect anchorType:FLOPopoverAnchorBottomPositiveLeadingPositive edgeType:edgeType];
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param anchorType type of anchor that the anchor view will stick to the positioningView ((top, leading) | (top, trailing), (bottom, leading), (bottom, trailing)).
 * @param edgeType 'position' that the popover should be displayed.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect anchorType:(FLOPopoverAnchorType)anchorType edgeType:(FLOPopoverEdgeType)edgeType {
    if ([self isShown]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self performSelector:@selector(close) withObject:nil afterDelay:0.03];
        
        return;
    }
    
    if (willShowBlock) willShowBlock(self);
    
    self.utils.positioningAnchorType = anchorType;
    
    [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
    
    self.utils.positioningRect = [self.utils.positioningAnchorView bounds];
    self.utils.positioningView = positioningView;
    
    [self setPopoverEdgeType:edgeType];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0.03];
    
    [self registerForApplicationEvents];
}

- (void)show {
    [self showIfNeeded:YES];
}

- (void)showIfNeeded:(BOOL)needed {
    if (NSEqualRects(self.utils.positioningRect, NSZeroRect)) {
        self.utils.positioningRect = [self.utils.positioningAnchorView bounds];
    }
    
    NSRect windowRelativeRect = [self.utils.positioningAnchorView convertRect:[self.utils.positioningAnchorView alignmentRectForFrame:self.utils.positioningRect] toView:nil];
    NSRect positionOnScreenRect = [self.utils.positioningAnchorView.window convertRectToScreen:windowRelativeRect];
    
    self.utils.backgroundView.popoverOrigin = positionOnScreenRect;
    self.utils.originalViewSize = NSEqualSizes(self.utils.originalViewSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.originalViewSize;
    self.utils.contentSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.contentSize;
    
    NSSize contentViewSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.originalViewSize : self.utils.contentSize;
    NSRectEdge popoverEdge = self.utils.preferredEdge;
    
    [self.utils.backgroundView setMovable:self.isMovable];
    [self.utils.backgroundView setDetachable:self.isDetachable];
    
    if (self.utils.positioningAnchorView == self.utils.positioningView) {
        [self.utils.backgroundView setShouldShowArrow:self.shouldShowArrow];
        [self.utils.backgroundView setArrowColor:self.utils.contentView.layer.backgroundColor];
    }
    
    if (self.isMovable || self.isDetachable) {
        self.utils.backgroundView.delegate = self;
    }
    
    CGSize size = [self.utils.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.utils.backgroundView.frame = (NSRect) { .size = size };
    self.utils.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.utils.backgroundView contentViewFrameForBackgroundFrame:self.utils.backgroundView.bounds popoverEdge:popoverEdge];
    self.utils.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.utils.contentView.frame = contentViewFrame;
    
    if (![self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
    }
    
    NSRect popoverRect = [self.utils popoverRectForEdge:self.utils.preferredEdge];
    
    self.utils.originalViewSize = size;
    
    if (self.popoverWindow == nil) {
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:popoverRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        self.popoverWindow.hasShadow = YES;
        self.popoverWindow.releasedWhenClosed = NO;
        self.popoverWindow.opaque = NO;
        self.popoverWindow.backgroundColor = NSColor.clearColor;
        self.popoverWindow.contentView = self.utils.backgroundView;
    }
    
    self.popoverWindow.canBecomeKey = self.canBecomeKey;
    [self.popoverWindow setFrame:popoverRect display:NO];
    
    if (![self.utils.positioningAnchorView.window.childWindows containsObject:self.popoverWindow]) {
        [self.utils.positioningAnchorView.window addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    self.popoverWindow.level = self.popoverWindowLevel;
    
    popoverRect = [self.utils.appMainWindow convertRectFromScreen:popoverRect];
    
    self.utils.verticalMarginOutOfPopover = self.utils.appMainWindow.contentView.visibleRect.size.height + FLO_CONST_POPOVER_BOTTOM_OFFSET - NSMaxY(popoverRect);
    self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
    
    if (needed) {
        self.popoverTempWindow = self.popoverWindow;
        
        if (self.alwaysOnTop) {
            [self.utils setTopmostWindow:self.popoverWindow];
        }
        
        [self setTopMostWindowIfNecessary];
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (![self isShown]) return;
    
    if (willCloseBlock) willCloseBlock(self);
    
    self.popoverTempWindow = nil;
    
    [self removeAllApplicationEvents];
    [self popoverShowing:NO animated:self.animated];
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    if (showing == YES) {
        [self.popoverWindow makeKeyAndOrderFront:nil];
        self.popoverWindow.alphaValue = 1.0;
        
        if (didShowBlock) didShowBlock(self);
    } else {
        [self.utils.positioningAnchorView.window removeChildWindow:self.popoverWindow];
        [self.popoverWindow close];
        [self.utils.contentView removeFromSuperview];
        
        if ((self.utils.positioningAnchorView != self.utils.positioningView) && [self.utils.positioningAnchorView isDescendantOf:self.utils.positioningView]) {
            [self.utils.positioningAnchorView removeFromSuperview];
            self.utils.positioningAnchorView = nil;
        }
        
        [self resetContentViewRect:nil];
        
        if (didCloseBlock) didCloseBlock(self);
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
    
    [self popoverDidFinishShowing:showing];
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
    [self.utils.positioningView.window setIgnoresMouseEvents:YES];
    
    CGFloat scaleFactor = showing ? 1.25 : 1.2;
    NSRect frame = self.popoverWindow.frame;
    CGFloat width = scaleFactor * frame.size.width;
    CGFloat height = scaleFactor * frame.size.height;
    CGFloat x = frame.origin.x - (width - frame.size.width) / 2;
    CGFloat y = frame.origin.y - (height - frame.size.height) / 2;
    NSRect scalingFrame = NSMakeRect(x, y, width, height);
    
    usleep(100000);
    
    [self.utils.backgroundView setAlphaValue:1.0];
    [self.popoverWindow setAlphaValue:1.0];
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.backgroundView];
    
    [self.utils.backgroundView setAlphaValue:0.0];
    
    CGFloat layerX = (scalingFrame.size.width - frame.size.width) / 2;
    CGFloat layerY = (scalingFrame.size.height - frame.size.height) / 2;
    NSRect layerFrame = NSMakeRect(layerX, layerY, frame.size.width, frame.size.height);
    CALayer *animatedLayer = [CALayer layer];
    animatedLayer.contents = snapshotImage;
    animatedLayer.frame = layerFrame;
    
    NSView *contentView = [[NSView alloc] initWithFrame:(NSRect){ .size = scalingFrame.size }];
    contentView.wantsLayer = YES;
    [contentView.layer addSublayer:animatedLayer];
    
    self.popoverWindow.contentView = contentView;
    [self.popoverWindow setFrame:scalingFrame display:showing];
    
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
    
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^{
        if (showing) {
            [self.utils.backgroundView setAlphaValue:1.0];
            self.popoverWindow.contentView = self.utils.backgroundView;
            [self.popoverWindow setFrame:frame display:showing];
        }
        
        [self popoverDidStopAnimation];
        
        [self.utils.positioningView.window setIgnoresMouseEvents:NO];
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
    [self popoverTransitionAnimationFrameShowing:showing];
}

- (void)popoverTransitionAnimationFrameShowing:(BOOL)showing {
    if (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        NSRect fromFrame = self.popoverWindow.frame;
        NSRect toFrame = fromFrame;
        
        [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:self.utils.animationType forwarding:self.animatedForwarding showing:showing];
        
        [self.popoverWindow showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:self];
    }
}

/*
 - FLOPopoverAnimationBehaviorDefault
 */
- (void)popoverDefaultAnimationShowing:(BOOL)showing {
    self.popoverWindow.alphaValue = showing ? 0.0 : 1.0;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.17];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        self.popoverWindow.alphaValue = showing ? 1.0 : 0.0;
        
        [self popoverDidStopAnimation];
    }];
    
    self.popoverWindow.animator.alphaValue = showing ? 1.0 : 0.0;
    
    [NSAnimationContext endGrouping];
}

- (void)popoverDidStopAnimation {
    BOOL showing = self.popoverTempWindow != nil;
    
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
    if (self.closesWhenPopoverResignsKey) {
        [self registerApplicationEventsMonitor];
    }
    
    if (self.closesWhenApplicationBecomesInactive) {
        [self registerApplicationActiveNotification];
    }
    
    [self registerSuperviewObserversForPositioningAnchor];
    
    [self removeWindowResizeEvent];
    [self registerWindowResizeEvent];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self removeApplicationActiveNotification];
    [self unregisterSuperviewObserversForPositioningAnchor];
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
            if (self.closesWhenPopoverResignsKey) {
                if (self.popoverWindow == event.window) {
                    NSPoint eventPoint = [self.popoverWindow.contentView convertPoint:event.locationInWindow fromView:nil];
                    
                    if (NSPointInRect(eventPoint, self.popoverWindow.contentView.bounds) == NO) {
                        [self performSelector:@selector(close) withObject:nil afterDelay:0.1];
                    }
                } else {
                    BOOL contained = [self.utils didWindow:self.popoverWindow contain:event.window];
                    
                    if (contained == NO) {
                        [self performSelector:@selector(close) withObject:nil afterDelay:0.1];
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
    
    if (self.utils.anchorSuperviews.count > 0) {
        [self.utils.appMainWindow.contentView addObserver:self forKeyPath:@"frame"
                                                  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                                  context:NULL];
    }
}

- (void)unregisterSuperviewObserversForPositioningAnchor {
    for (NSView *anchorSuperview in self.utils.anchorSuperviews) {
        [anchorSuperview removeObserver:self forKeyPath:@"frame"];
        [anchorSuperview removeObserver:self forKeyPath:@"superview"];
    }
    
    if (self.utils.anchorSuperviews.count > 0) {
        [self.utils.appMainWindow.contentView removeObserver:self forKeyPath:@"frame"];
    }
    
    self.utils.anchorSuperviews = nil;
}

- (void)registerWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
}

- (void)removeWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
}

#pragma mark - Utilities

- (void)closePopover:(NSResponder *)sender {
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"superview"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *)object;
        
        if ([self shouldClosePopoverByCheckingChangedView:view]) {
            [self close];
            return;
        }
    }
    
    if ([self.utils appMainWindowResized]) return;
    
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *)object;
        
        if (view == self.utils.appMainWindow.contentView) {
            [self.utils setAppMainWindowResized:YES];
            
            if (self.closesWhenApplicationResizes) {
                [self close];
            }
            
            return;
        }
        
        if ([self shouldClosePopoverByCheckingChangedView:view]) {
            [self close];
            return;
        }
        
        if ([self.utils.positioningAnchorView isDescendantOf:view]) {
            NSRect positioningInWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
            
            if (NSEqualPoints(self.utils.positioningWindowRect.origin, positioningInWindowRect.origin) == NO) {
                NSRect popoverRect = [self.utils popoverRectForEdge:self.utils.preferredEdge];
                
                popoverRect = (NSRect) { .origin = popoverRect.origin, .size = self.popoverWindow.frame.size };
                
                if (NSContainsRect(self.utils.appMainWindow.frame, popoverRect) == NO) {
                    [self close];
                    return;
                }
                
                [self.popoverWindow setFrame:popoverRect display:YES];
                
                self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
            }
        }
    }
}

- (void)appResignedActive:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSApplicationDidResignActiveNotification]) {
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1];
    }
}

- (void)windowDidResize:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidResizeNotification] && (notification.object == self.utils.appMainWindow)) {
        if (self.closesWhenApplicationResizes == NO) {
            NSWindow *resizedWindow = (NSWindow *)notification.object;
            NSRect popoverRect = [self.utils popoverRectForEdge:self.utils.preferredEdge];
            CGFloat popoverOriginX = popoverRect.origin.x;
            CGFloat popoverOriginY = popoverRect.origin.y;
            
            if (self.shouldChangeSizeWhenApplicationResizes) {
                CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.utils.verticalMarginOutOfPopover;
                CGFloat deltaHeight = popoverRect.size.height - newHeight;
                CGFloat popoverHeight = (newHeight < self.utils.originalViewSize.height) ? newHeight : self.utils.originalViewSize.height;
                
                popoverOriginY = popoverRect.origin.y + ((newHeight < self.utils.originalViewSize.height) ? deltaHeight : 0.0);
                
                popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, self.popoverWindow.frame.size.width, popoverHeight);
            } else {
                popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, self.popoverWindow.frame.size.width, self.popoverWindow.frame.size.height);
            }
            
            [self.popoverWindow setFrame:popoverRect display:YES];
            
            if (NSEqualSizes(self.utils.backgroundView.arrowSize, NSZeroSize) == NO) {
                if ((self.utils.preferredEdge == NSRectEdgeMinY) || (self.utils.preferredEdge == NSRectEdgeMaxY)) {
                    self.utils.contentSize = NSMakeSize(self.popoverWindow.frame.size.width, self.popoverWindow.frame.size.height - self.utils.backgroundView.arrowSize.height);
                } else {
                    self.utils.contentSize = NSMakeSize(self.popoverWindow.frame.size.width - self.utils.backgroundView.arrowSize.height, self.popoverWindow.frame.size.height);
                }
            } else {
                self.utils.contentSize = self.popoverWindow.frame.size;
            }
            
            self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
        }
    }
}

#pragma mark - FLOPopoverBackgroundViewDelegate

- (void)didPopoverMakeMovement {
}

- (void)didPopoverBecomeDetachable:(NSWindow *)targetWindow {
    if (targetWindow == self.popoverWindow) {
        if ([self.utils.positioningAnchorView.window.childWindows containsObject:targetWindow]) {
            [self.utils.positioningAnchorView.window removeChildWindow:self.popoverWindow];
            
            NSView *contentView = self.popoverWindow.contentView;
            NSRect windowRect = self.popoverWindow.frame;
            NSUInteger styleMask = NSWindowStyleMaskTitled + NSWindowStyleMaskClosable;
            
            NSWindow *temp = [[NSWindow alloc] initWithContentRect:windowRect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
            NSRect detachableWindowRect = [temp frameRectForContentRect:windowRect];
            
            contentView.wantsLayer = YES;
            contentView.layer.cornerRadius = 0.0;
            [self.popoverWindow setStyleMask:styleMask];
            [self.popoverWindow setFrame:detachableWindowRect display:YES];
            [self.popoverWindow makeKeyAndOrderFront:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewRect:) name:NSWindowWillCloseNotification object:targetWindow];
        }
    }
}

@end
