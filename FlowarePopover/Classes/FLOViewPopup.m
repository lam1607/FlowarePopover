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
@property (nonatomic, assign, readwrite) NSRect initialPositioningRect;

@property (nonatomic, strong) NSEvent *appEvent;
@property (nonatomic, strong) FLOPopoverUtils *utils;

@property (nonatomic, assign) BOOL popoverShowing;
@property (nonatomic, assign) BOOL popoverClosing;

@property (nonatomic, strong) NSView *popoverTempView;
@property (nonatomic, strong) FLOPopoverBackgroundView *popoverView;
@property (nonatomic, strong) FLOPopoverWindow *detachableWindow;

/**
 * View that used for making animation with an animated layer.
 */
@property (nonatomic, strong) NSView *snapshotView;

@property (nonatomic, strong) NSImageView *visualEffectImageView;

@end

@implementation FLOViewPopup

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
        _animated = NO;
        _animatedForwarding = NO;
        _staysInApplicationRect = NO;
        _updatesFrameWhileShowing = NO;
        _makeKeyWindowOnMouseEvents = NO;
        _shouldRegisterSuperviewObservers = YES;
        _shouldChangeSizeWhenApplicationResizes = YES;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _closesWhenApplicationResizes = NO;
        _closesWhenNotBelongToApplicationFrame = YES;
        _isMovable = NO;
        _isDetachable = NO;
        _tag = -1;
        _animatedByMovingFrame = NO;
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

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    if ([self isShown]) {
        self.popoverView.tag = tag;
    }
}

#pragma mark - Processes

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

- (void)resetContentViewRect:(NSNotification *)notification {
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
    [view addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [view addObserver:self forKeyPath:@"superview" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)setVisualEffectImageViewEnabled:(BOOL)enabled {
    NSRect visualEffectFrame = NSIntersectionRect(self.utils.appMainWindow.frame, self.popoverView.frame);
    NSImage *visualEffectImage = [FLOExtensionsGraphicsContext screenShotImageAtFrame:visualEffectFrame];
    
    if (visualEffectImage) {
        if (self.visualEffectImageView == nil) {
            self.visualEffectImageView = [[NSImageView alloc] initWithFrame:self.popoverView.bounds];
        }
        
        if (enabled) {
            NSImageView *visualEffectImageView = self.visualEffectImageView;
            
            [self.popoverView addSubview:visualEffectImageView positioned:NSWindowBelow relativeTo:self.utils.contentView];
            
            [self.visualEffectImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.popoverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[visualEffectImageView]|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(visualEffectImageView)]];
            [self.popoverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[visualEffectImageView]|"
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:NSDictionaryOfVariableBindings(visualEffectImageView)]];
            
            visualEffectImageView.image = visualEffectImage;
        } else {
            if (self.visualEffectImageView && [self.visualEffectImageView isDescendantOf:self.popoverView]) {
                [self.visualEffectImageView removeFromSuperview];
            }
        }
    }
}

#pragma mark - Display

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInApplicationRect:(BOOL)animatedInApplicationRect {
    self.utils.animationBehaviour = animationBehaviour;
    self.utils.animationType = animationType;
    self.utils.animatedInApplicationRect = animatedInApplicationRect;
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

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
    if ((NSEqualSizes(newSize, NSZeroSize) == NO) && (NSEqualSizes(newSize, self.utils.contentSize) == NO)) {
        self.utils.originalViewSize = newSize;
        self.utils.contentSize = newSize;
    }
    
    if (NSEqualRects(rect, NSZeroRect) == NO) {
        [self setupPositioningAnchorWithView:self.utils.positioningView positioningRect:rect shouldUpdatePosition:YES];
    }
    
    [self updatePopoverFrame];
}

- (void)updatePopoverFrame {
    if ([self isShown]) {
        if (self.updatesFrameWhileShowing || ((self.popoverShowing == NO) && (self.popoverClosing == NO))) {
            [self showIfNeeded:NO];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                while (true) {
                    if ((self.popoverShowing == NO) && (self.popoverClosing == NO)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self showIfNeeded:NO];
                        });
                        
                        break;
                    }
                }
            });
        }
    }
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
        
        // Must set alphaValue 0.01 (for user don't see the view in UI) to let the content view makes data loading.
        // NEVER set alphaValue 0.0, if alphaValue is set as 0.0 the content view cannot reload UI and update frame correctly.
        [self.utils.contentView setAlphaValue:0.01];
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.positioningRect = rect;
        self.utils.positioningView = positioningView;
        self.utils.positioningAnchorView = positioningView;
        self.utils.senderView = positioningView;
        
        [self setPopoverEdgeType:edgeType];
        // Should perform with selector after 0.001 second, for preventing flashing issue
        // When contentView is added to backgroundView, when running the while loop
        [self performSelector:@selector(show) withObject:nil afterDelay:0.001];
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
        self.initialPositioningRect = rect;
        
        // Must set alphaValue 0.01 (for user don't see the view in UI) to let the content view makes data loading.
        // NEVER set alphaValue 0.0, if alphaValue is set as 0.0 the content view cannot reload UI and update frame correctly.
        [self.utils.contentView setAlphaValue:0.01];
        
        if (willShowBlock) willShowBlock(self);
        
        self.utils.relativePositionType = relativePositionType;
        
        [self setupPositioningAnchorWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
        
        self.utils.positioningRect = [self.utils.positioningAnchorView bounds];
        self.utils.positioningView = positioningView;
        self.utils.senderView = sender;
        
        [self setPopoverEdgeType:edgeType];
        // Should perform with selector after 0.001 second, for preventing flashing issue
        // When contentView is added to backgroundView, when running the while loop
        [self performSelector:@selector(show) withObject:nil afterDelay:0.001];
        [self registerForApplicationEvents];
    }
}

- (void)show {
    [self showIfNeeded:YES];
}

- (void)showIfNeeded:(BOOL)needed {
    if (NSEqualRects(self.utils.positioningRect, NSZeroRect)) {
        self.utils.positioningRect = [self.utils.positioningAnchorView bounds];
    }
    
    self.utils.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (needed) {
        self.utils.backgroundView.frame = (NSRect){ .size = self.utils.contentView.frame.size };
    }
    
    if (![self.utils.backgroundView isDescendantOf:self.utils.positioningAnchorView.window.contentView]) {
        [self.utils.positioningAnchorView.window.contentView addSubview:self.utils.backgroundView positioned:NSWindowAbove relativeTo:self.utils.positioningAnchorView];
    }
    
    if (![self.utils.contentView isDescendantOf:self.utils.backgroundView]) {
        [self.utils.backgroundView addSubview:self.utils.contentView positioned:NSWindowAbove relativeTo:nil];
    }
    
    if (needed) {
        // Must set alphaValue 0.01 (for user don't see the view in UI) to let the content view makes data loading.
        // NEVER set alphaValue 0.0, if alphaValue is set as 0.0 the content view cannot reload UI and update frame correctly.
        [self.utils.backgroundView setAlphaValue:0.01];
        
        // Waiting for content view loading data and update its frame correctly before animation.
        while (true) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.075]];
            break;
        }
    }
    
    self.utils.backgroundView.tag = self.tag;
    
    NSRect windowRelativeRect = [self.utils.positioningAnchorView convertRect:[self.utils.positioningAnchorView alignmentRectForFrame:self.utils.positioningRect] toView:nil];
    NSRect positionOnScreenRect = [self.utils.positioningAnchorView.window convertRectToScreen:windowRelativeRect];
    
    self.utils.backgroundView.popoverOrigin = positionOnScreenRect;
    self.utils.originalViewSize = NSEqualSizes(self.utils.originalViewSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.originalViewSize;
    self.utils.contentSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.contentView.frame.size : self.utils.contentSize;
    
    NSSize contentViewSize = NSEqualSizes(self.utils.contentSize, NSZeroSize) ? self.utils.originalViewSize : self.utils.contentSize;
    NSRectEdge popoverEdge = self.utils.preferredEdge;
    
    self.utils.backgroundView.makeKeyWindowOnMouseEvents = self.makeKeyWindowOnMouseEvents;
    
    [self.utils.backgroundView setMovable:self.isMovable];
    [self.utils.backgroundView setDetachable:self.isDetachable];
    
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        [self.utils.backgroundView setShouldShowArrow:self.shouldShowArrow];
        [self.utils.backgroundView setArrowColor:self.utils.contentView.layer.backgroundColor];
    }
    
    [self.utils.backgroundView setShouldShowShadow:YES];
    
    if (self.isMovable || self.isDetachable) {
        self.utils.backgroundView.delegate = self;
    }
    
    CGSize size = [self.utils.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.utils.backgroundView.frame = (NSRect){ .size = size };
    self.utils.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.utils.backgroundView contentViewFrameForBackgroundFrame:self.utils.backgroundView.bounds popoverEdge:popoverEdge];
    self.utils.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.utils.contentView.frame = contentViewFrame;
    
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        self.staysInApplicationRect = YES;
        self.utils.staysInApplicationRect = YES;
        self.utils.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.utils.animationType = FLOPopoverAnimationDefault;
    }
    
    NSRect popoverRect = (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) ? [self.utils _popoverRect] : [self.utils popoverRectForEdge:self.utils.preferredEdge];
    popoverRect = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverRect];
    
    // Update arrow edge and content view frame
    if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils _backgroundViewShouldUpdate:YES];
    }
    
    self.utils.originalViewSize = self.utils.backgroundView.frame.size;
    
    [self.utils.backgroundView setFrame:popoverRect];
    
    self.popoverView = self.utils.backgroundView;
    
    self.utils.verticalMarginOutOfPopover = self.utils.appMainWindow.contentView.visibleRect.size.height + FLO_CONST_POPOVER_BOTTOM_OFFSET - NSMaxY(popoverRect);
    self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
    
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
            
            [self removeAllApplicationEvents];
            [self popoverShowing:NO animated:self.animated];
        }
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    _shown = showing;
    
    if (showing == YES) {
        self.popoverView.alphaValue = 1.0;
        
        self.popoverShowing = NO;
        
        if (didShowBlock) didShowBlock(self);
    } else {
        if ([self.popoverView isDescendantOf:self.utils.positioningAnchorView.window.contentView] ||
            (self.utils.positioningAnchorView.window.contentView == nil) || (self.utils.contentView == self.detachableWindow.contentView)) {
            [self resetContentViewRect:nil];
            
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
    
    NSVisualEffectView *visualEffectView = [self.utils contentViewDidContainVisualEffect];
    
    [self.popoverView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    if (visualEffectView) {
        [self setVisualEffectImageViewEnabled:YES];
    }
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.backgroundView];
    
    if (visualEffectView) {
        [self setVisualEffectImageViewEnabled:NO];
    }
    
    [self.popoverView setAlphaValue:0.0];
    [self.utils.contentView setAlphaValue:0.0];
    
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
    
    NSVisualEffectView *visualEffectView = [self.utils contentViewDidContainVisualEffect];
    
    [self.popoverView setAlphaValue:1.0];
    [self.utils.contentView setAlphaValue:1.0];
    [self.utils.contentView display];
    
    if (visualEffectView) {
        [self setVisualEffectImageViewEnabled:YES];
    }
    
    NSImage *snapshotImage = [FLOExtensionsGraphicsContext snapshotImageFromView:self.utils.backgroundView];
    
    if (visualEffectView) {
        [self setVisualEffectImageViewEnabled:NO];
    }
    
    [self.popoverView setAlphaValue:0.0];
    [self.utils.contentView setAlphaValue:0.0];
    
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
    if (self.utils.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        NSRect fromFrame = self.popoverView.frame;
        NSRect toFrame = fromFrame;
        
        [self.utils.backgroundView setAlphaValue:1.0];
        [self.utils.contentView setAlphaValue:1.0];
        
        [self.utils calculateFromFrame:&fromFrame toFrame:&toFrame animationType:self.utils.animationType forwarding:self.animatedForwarding showing:showing];
        
        NSTimeInterval duration = FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD;
        
        if (self.animationDuration > 0) {
            duration = self.animationDuration;
        }
        
        [self.popoverView showingAnimated:showing fromFrame:fromFrame toFrame:toFrame duration:duration source:self];
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
                if (self.utils.senderView && (clickedView != self.utils.senderView)) {
                    if (self.popoverView.window == event.window) {
                        if (!([clickedView isDescendantOf:self.popoverView] || (clickedView == self.popoverView))) {
                            [self close];
                        }
                    } else {
                        BOOL contained = [self.utils didWindow:self.popoverView.window contain:event.window];
                        
                        if (contained == NO) {
                            [self close];
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
            [anchorSuperview removeObserver:self forKeyPath:@"frame"];
            [anchorSuperview removeObserver:self forKeyPath:@"superview"];
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
                NSRect positioningInWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
                
                if (NSEqualPoints(self.utils.positioningWindowRect.origin, positioningInWindowRect.origin) == NO) {
                    NSRect popoverRect = [self.utils popoverRectForEdge:self.utils.preferredEdge];
                    
                    popoverRect = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverRect];
                    popoverRect = (NSRect) { .origin = popoverRect.origin, .size = self.popoverView.frame.size };
                    
                    if (self.closesWhenNotBelongToApplicationFrame && (NSContainsRect(self.utils.appMainWindow.contentView.visibleRect, popoverRect) == NO)) {
                        [self close];
                        return;
                    }
                    
                    [self.popoverView setFrame:popoverRect];
                    
                    self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
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
            NSRect popoverRect = (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) ? [self.utils _popoverRect] : [self.utils popoverRectForEdge:self.utils.preferredEdge];
            popoverRect = [self.utils.positioningAnchorView.window convertRectFromScreen:popoverRect];
            
            CGFloat popoverOriginX = popoverRect.origin.x;
            CGFloat popoverOriginY = popoverRect.origin.y;
            
            if (self.shouldChangeSizeWhenApplicationResizes) {
                CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.utils.verticalMarginOutOfPopover;
                CGFloat deltaHeight = popoverRect.size.height - newHeight;
                CGFloat popoverHeight = (newHeight < self.utils.originalViewSize.height) ? newHeight : self.utils.originalViewSize.height;
                
                popoverOriginY = popoverRect.origin.y + ((newHeight < self.utils.originalViewSize.height) ? deltaHeight : 0.0);
                
                popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, popoverRect.size.width, popoverHeight);
            } else {
                popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, self.utils.originalViewSize.width, self.utils.originalViewSize.height);
            }
            
            // Update arrow edge and content view frame
            if (self.shouldShowArrow && (self.utils.positioningView == self.utils.positioningAnchorView)) {
                [self.utils _backgroundViewShouldUpdate:YES];
            }
            
            [self.popoverView setFrame:popoverRect];
            
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
                self.utils.contentView.translatesAutoresizingMaskIntoConstraints = YES;
                self.utils.contentView.frame = contentViewFrame;
            }
            
            self.utils.positioningWindowRect = [self.utils.positioningView convertRect:self.utils.positioningView.bounds toView:self.utils.positioningView.window.contentView];
        }
    }
}

#pragma mark - FLOPopoverBackgroundViewDelegate

- (void)didPopoverMakeMovement {
    if (didMoveBlock) {
        didMoveBlock(self);
    }
}

- (void)didPopoverBecomeDetachable:(NSWindow *)targetWindow {
    if ([self.popoverView isDescendantOf:targetWindow.contentView]) {
        [self removeAllApplicationEvents];
        
        if (didDetachBlock) {
            didDetachBlock(self);
        }
        
        [self.utils.backgroundView removeFromSuperview];
        [self.utils.contentView removeFromSuperview];
        
        NSView *contentView = self.utils.contentView;
        NSRect contentViewRect = [self.utils.positioningAnchorView.window convertRectToScreen:self.popoverView.frame];
        NSUInteger styleMask = NSWindowStyleMaskTitled + NSWindowStyleMaskClosable;
        
        self.detachableWindow = [[FLOPopoverWindow alloc] initWithContentRect:contentViewRect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
        NSRect detachableWindowRect = [self.detachableWindow frameRectForContentRect:contentViewRect];
        
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
        [self.detachableWindow setFrame:detachableWindowRect display:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewRect:) name:NSWindowWillCloseNotification object:self.detachableWindow];
    }
}

@end
