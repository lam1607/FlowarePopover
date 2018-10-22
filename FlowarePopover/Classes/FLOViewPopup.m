//
//  FLOViewPopup.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOViewPopup.h"

#import <QuartzCore/QuartzCore.h>

#import "FLOExtensionsGraphicsContext.h"
#import "FLOExtensionsNSView.h"

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

@interface FLOViewPopup () <FLOPopoverBackgroundViewDelegate, NSAnimationDelegate, CAAnimationDelegate> {
    NSWindow *_appMainWindow;
    NSEvent *_appEvent;
    NSView *_popoverTempView;
}

@property (nonatomic, assign, readwrite) BOOL shown;

@property (nonatomic, strong) NSView *popoverView;
@property (nonatomic, assign) CGFloat popoverVerticalMargins;
@property (nonatomic, assign) BOOL popoverDidMove;

@property (nonatomic, strong) NSView *positioningAnchorView;
@property (nonatomic, assign) NSRect positioningInWindowRect;
@property (nonatomic, strong) NSMutableArray<NSView *> *anchorSuperviews;
@property (nonatomic, assign) BOOL appWindowDidChange;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationTransition animationType;

@property (nonatomic, strong) FLOPopoverBackgroundView *backgroundView;
@property (nonatomic) NSRect positioningRect;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic) NSRectEdge preferredEdge;
@property (nonatomic) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic) CGSize originalViewSize;

@end

@implementation FLOViewPopup

@synthesize popoverDidShowCallback;
@synthesize popoverDidCloseCallback;

/**
 * Initialize the FLOViewPopup with content view.
 *
 * @param contentView the view needs displayed on FLOViewPopup
 * @return FLOViewPopup instance
 */
- (instancetype)initWithContentView:(NSView *)contentView {
    if (self = [super init]) {
        _appMainWindow = [[FLOPopoverUtils sharedInstance] appMainWindow];
        _contentView = contentView;
        _backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentView.frame];
        _anchorPoint = CGPointMake(0.0f, 0.0f);
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _animated = NO;
        _animationBehaviour = FLOPopoverAnimationBehaviorTransition;
        _animationType = FLOPopoverAnimationLeftToRight;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _popoverMovable = NO;
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
    if (self = [super init]) {
        _appMainWindow = [[FLOPopoverUtils sharedInstance] appMainWindow];
        _contentViewController = contentViewController;
        _contentView = contentViewController.view;
        _backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentViewController.view.frame];
        _anchorPoint = CGPointMake(0.0f, 0.0f);
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _animated = NO;
        _animationBehaviour = FLOPopoverAnimationBehaviorTransition;
        _animationType = FLOPopoverAnimationLeftToRight;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _popoverMovable = NO;
    }
    
    return self;
}

- (void)dealloc {
    _appMainWindow = nil;
    _appEvent = nil;
    self.contentViewController = nil;
    self.contentView = nil;
    
    [self.positioningAnchorView removeFromSuperview];
    self.positioningAnchorView = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    [self.popoverView removeFromSuperview];
    self.popoverView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (BOOL)isShown {
    return _shown;
}

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    switch (edgeType) {
        case FLOPopoverEdgeTypeAboveLeftEdge:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = CGPointMake(0.0f, 0.0f);
            break;
        case FLOPopoverEdgeTypeAboveRightEdge:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = CGPointMake(1.0f, 1.0f);
            break;
        case FLOPopoverEdgeTypeBelowLeftEdge:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = CGPointMake(0.0f, 0.0f);
            break;
        case FLOPopoverEdgeTypeBelowRightEdge:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = CGPointMake(1.0f, 1.0f);
            break;
        case FLOPopoverEdgeTypeBackwardBottomEdge:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = CGPointMake(0.0f, 0.0f);
            break;
        case FLOPopoverEdgeTypeBackwardTopEdge:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = CGPointMake(1.0f, 1.0f);
            break;
        case FLOPopoverEdgeTypeForwardBottomEdge:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = CGPointMake(0.0f, 0.0f);
            break;
        case FLOPopoverEdgeTypeForwardTopEdge:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = CGPointMake(1.0f, 1.0f);
            break;
        case FLOPopoverEdgeTypeAboveCenter:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = CGPointMake(0.5f, 0.5f);
            break;
        case FLOPopoverEdgeTypeBelowCenter:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = CGPointMake(0.5f, 0.5f);
            break;
        case FLOPopoverEdgeTypeBackwardCenter:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = CGPointMake(0.5f, 0.5f);
            break;
        case FLOPopoverEdgeTypeForwardCenter:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = CGPointMake(0.5f, 0.5f);
            break;
        default:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = CGPointMake(1.0f, 1.0f);
            break;
    }
}

- (void)setTopMostViewIfNecessary {
    NSView *topView = [[FLOPopoverUtils sharedInstance] topView];
    NSArray *viewStack = _appMainWindow.contentView.subviews;
    
    if ((topView != nil) && [viewStack containsObject:topView]) {
        [topView removeFromSuperview];
        [_appMainWindow.contentView addSubview:topView];
    }
}

- (void)setupPositioningAnchorViewWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    NSRect positioningInWindowRect = [positioningView convertRect:positioningView.bounds toView:positioningView.window.contentView];
    CGFloat posX = positioningInWindowRect.origin.x - NSMinX(positioningRect);
    CGFloat posY = positioningInWindowRect.origin.y - NSMaxY(positioningRect);
    
    if (self.positioningAnchorView == nil) {
        self.positioningAnchorView = [[NSView alloc] initWithFrame:NSZeroRect];
        
        self.positioningAnchorView.wantsLayer = YES;
        self.positioningAnchorView.layer.backgroundColor = [NSColor.clearColor CGColor];
        self.positioningAnchorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [positioningView addSubview:self.positioningAnchorView];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:positioningView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:-posX];
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:positioningView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.positioningAnchorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:-posY];
        
        [leading setActive:YES];
        [bottom setActive:YES];
        
        [positioningView addConstraints:@[leading, bottom]];
        
        CGFloat anchorViewWidth = 1.0f;
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:anchorViewWidth];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:anchorViewWidth];
        
        [width setActive:YES];
        [height setActive:YES];
        
        [self.positioningAnchorView addConstraints:@[width, height]];
        [self.positioningAnchorView setHidden:NO];
    }
    
    if (shouldUpdatePosition && (self.positioningAnchorView != nil) && [self.positioningAnchorView isDescendantOf:positioningView]) {
        for (NSLayoutConstraint *constraint in positioningView.constraints) {
            if ((constraint.firstItem == self.positioningAnchorView) || (constraint.secondItem == self.positioningAnchorView)) {
                if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                    constraint.constant = -posX;
                }
                
                if (constraint.firstAttribute == NSLayoutAttributeBottom) {
                    constraint.constant = -posY;
                }
            }
        }
        
        [positioningView setNeedsUpdateConstraints:YES];
        [positioningView updateConstraints];
        [positioningView updateConstraintsForSubtreeIfNeeded];
        [positioningView layoutSubtreeIfNeeded];
    }
    
    [self.positioningAnchorView setHidden:NO];
}

#pragma mark -
#pragma mark - Display
#pragma mark -
- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType {
    self.animationBehaviour = animationBehaviour;
    self.animationType = animationType;
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    self.originalViewSize = newSize;
    self.contentSize = newSize;
    
    if (self.shown) {
        [self showIfNeeded:NO];
    }
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect; {
    self.originalViewSize = newSize;
    self.contentSize = newSize;
    
    [self setupPositioningAnchorViewWithView:self.positioningView positioningRect:rect shouldUpdatePosition:YES];
    
    if (self.shown) {
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
    if (self.shown) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
        
        return;
    }
    
    self.positioningRect = rect;
    self.positioningView = positioningView;
    self.positioningAnchorView = positioningView;
    
    [self setPopoverEdgeType:edgeType];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0.1f];
    
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
    if (self.shown) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
        
        return;
    }
    
    [self setupPositioningAnchorViewWithView:positioningView positioningRect:rect shouldUpdatePosition:NO];
    
    self.positioningRect = [self.positioningAnchorView bounds];
    self.positioningView = positioningView;
    
    [self setPopoverEdgeType:edgeType];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0.1f];
    
    [self registerForApplicationEvents];
}

- (void)show {
    [self showIfNeeded:YES];
}

- (void)showIfNeeded:(BOOL)needed {
    if (NSEqualRects(self.positioningRect, NSZeroRect)) {
        self.positioningRect = [self.positioningAnchorView bounds];
    }
    
    NSRect windowRelativeRect = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:self.positioningRect] toView:nil];
    NSRect positionOnScreenRect = [self.positioningAnchorView.window convertRectToScreen:windowRelativeRect];
    
    self.backgroundView.popoverOrigin = positionOnScreenRect;
    self.originalViewSize = NSEqualSizes(self.originalViewSize, NSZeroSize) ? self.contentView.frame.size : self.originalViewSize;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSRectEdge popoverEdge = self.preferredEdge;
    
    [self.backgroundView setViewMovable:self.popoverMovable];
    
    if (self.positioningAnchorView == self.positioningView) {
        [self.backgroundView setShouldShowArrow:self.shouldShowArrow];
        [self.backgroundView setArrowColor:self.contentView.layer.backgroundColor];
    }
    
    [self.backgroundView setShouldShowShadow:YES];
    
    if (self.popoverMovable) {
        self.backgroundView.delegate = self;
    }
    
    CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.backgroundView.frame = (NSRect) { .size = size };
    self.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
    self.contentView.frame = contentViewFrame;
    
    if (![self.contentView isDescendantOf:self.backgroundView]) {
        [self.backgroundView addSubview:self.contentView positioned:NSWindowAbove relativeTo:nil];
    }
    
    NSRect popoverRect = [self popoverRect];
    popoverRect = [self.positioningAnchorView.window convertRectFromScreen:popoverRect];
    
    self.originalViewSize = size;
    
    [self.backgroundView setFrame:popoverRect];
    
    if (![self.backgroundView isDescendantOf:self.positioningAnchorView.window.contentView]) {
        [self.positioningAnchorView.window.contentView addSubview:self.backgroundView positioned:NSWindowAbove relativeTo:self.positioningAnchorView];
    }
    
    self.popoverView = self.backgroundView;
    
    self.popoverVerticalMargins = _appMainWindow.contentView.visibleRect.size.height + FLO_CONST_POPOVER_BOTTOM_OFFSET - NSMaxY([_appMainWindow convertRectFromScreen:popoverRect]);
    self.positioningInWindowRect = [self.positioningView convertRect:self.positioningView.bounds toView:self.positioningView.window.contentView];
    
    if (needed) {
        if (self.alwaysOnTop) {
            [[FLOPopoverUtils sharedInstance] setTopmostView:self.backgroundView];
        }
        
        [self setTopMostViewIfNecessary];
        
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (!self.shown) return;
    
    if ([self.popoverView isDescendantOf:self.positioningAnchorView.window.contentView] || (self.positioningAnchorView.window.contentView == nil)) {
        [self removeAllApplicationEvents];
        [self popoverShowing:NO animated:self.animated];
        
        [self.popoverView removeFromSuperview];
        //        self.popoverView = nil;
        
        if ((self.positioningAnchorView != self.positioningView) && [self.positioningAnchorView isDescendantOf:self.positioningView]) {
            [self.positioningAnchorView setHidden:YES];
        }
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    self.shown = showing;
    
    if (showing == YES) {
        self.popoverView.alphaValue = 1.0f;
        
        if (popoverDidShowCallback != nil) popoverDidShowCallback(self);
    } else {
        if (popoverDidCloseCallback != nil) popoverDidCloseCallback(self);
    }
}

#pragma mark -
#pragma mark - Display utilities
#pragma mark -
- (NSRect)popoverRectForEdge:(NSRectEdge)popoverEdge {
    NSRect windowRelativeRect = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:self.positioningRect] toView:nil];
    NSRect positionOnScreenRect = [self.positioningAnchorView.window convertRectToScreen:windowRelativeRect];
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSPoint anchorPoint = self.anchorPoint;
    
    NSSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    NSRect returnRect = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
    
    // In all the cases below, find the minimum and maximum position of the
    // popover and then use the anchor point to determine where the popover
    // should be between these two locations.
    //
    // `x0` indicates the x origin of the popover if `self.anchorPoint.x` is
    // 0 and aligns the left edge of the popover to the left edge of the
    // origin view. `x1` is the x origin if `self.anchorPoint.x` is 1 and
    // aligns the right edge of the popover to the right edge of the origin
    // view. The anchor point determines where the popover should be between
    // these extremes.
    if (popoverEdge == NSRectEdgeMinY) {
        CGFloat x0 = NSMinX(positionOnScreenRect);
        CGFloat x1 = NSMaxX(positionOnScreenRect) - contentViewSize.width;
        
        returnRect.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        returnRect.origin.y = NSMinY(positionOnScreenRect) - popoverSize.height;
    } else if (popoverEdge == NSRectEdgeMaxY) {
        CGFloat x0 = NSMinX(positionOnScreenRect);
        CGFloat x1 = NSMaxX(positionOnScreenRect) - contentViewSize.width;
        
        returnRect.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        returnRect.origin.y = NSMaxY(positionOnScreenRect);
    } else if (popoverEdge == NSRectEdgeMinX) {
        CGFloat y0 = NSMinY(positionOnScreenRect);
        CGFloat y1 = NSMaxY(positionOnScreenRect) - contentViewSize.height;
        
        returnRect.origin.x = NSMinX(positionOnScreenRect) - popoverSize.width;
        returnRect.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else if (popoverEdge == NSRectEdgeMaxX) {
        CGFloat y0 = NSMinY(positionOnScreenRect);
        CGFloat y1 = NSMaxY(positionOnScreenRect) - contentViewSize.height;
        
        returnRect.origin.x = NSMaxX(positionOnScreenRect);
        returnRect.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else {
        returnRect = NSZeroRect;
    }
    
    return returnRect;
}

- (BOOL)checkPopoverSizeForScreenWithPopoverEdge:(NSRectEdge)popoverEdge {
    NSRect appScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    NSRect popoverRect = [self popoverRectForEdge:popoverEdge];
    
    return NSContainsRect(appScreenRect, popoverRect);
}

- (NSRectEdge)nextEdgeForEdge:(NSRectEdge)currentEdge {
    if (currentEdge == NSRectEdgeMaxX) {
        return (self.preferredEdge == NSRectEdgeMinX) ? NSRectEdgeMaxY : NSRectEdgeMinX;
    } else if (currentEdge == NSRectEdgeMinX) {
        return (self.preferredEdge == NSRectEdgeMaxX) ? NSRectEdgeMaxY : NSRectEdgeMaxX;
    } else if (currentEdge == NSRectEdgeMaxY) {
        return (self.preferredEdge == NSRectEdgeMinY) ? NSRectEdgeMaxX : NSRectEdgeMinY;
    } else if (currentEdge == NSRectEdgeMinY) {
        return (self.preferredEdge == NSRectEdgeMaxY) ? NSRectEdgeMaxX : NSRectEdgeMaxY;
    }
    
    return currentEdge;
}

- (NSRect)fitRectToScreen:(NSRect)proposedRect {
    NSRect appScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    
    if (proposedRect.origin.y < NSMinY(appScreenRect)) {
        proposedRect.origin.y = NSMinY(appScreenRect);
    }
    if (proposedRect.origin.x < NSMinX(appScreenRect)) {
        proposedRect.origin.x = NSMinX(appScreenRect);
    }
    
    if (NSMaxY(proposedRect) > NSMaxY(appScreenRect)) {
        proposedRect.origin.y = NSMaxY(appScreenRect) - NSHeight(proposedRect);
    }
    if (NSMaxX(proposedRect) > NSMaxX(appScreenRect)) {
        proposedRect.origin.x = NSMaxX(appScreenRect) - NSWidth(proposedRect);
    }
    
    return proposedRect;
}

- (BOOL)screenRectContainsRectEdge:(NSRectEdge)edge {
    NSRect proposedRect = [self popoverRectForEdge:edge];
    NSRect appScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    
    BOOL minYInBounds = (edge == NSRectEdgeMinY) && (NSMinY(proposedRect) >= NSMinY(appScreenRect));
    BOOL maxYInBounds = (edge == NSRectEdgeMaxY) && (NSMaxY(proposedRect) <= NSMaxY(appScreenRect));
    BOOL minXInBounds = (edge == NSRectEdgeMinX) && (NSMinX(proposedRect) >= NSMinX(appScreenRect));
    BOOL maxXInBounds = (edge == NSRectEdgeMaxX) && (NSMaxX(proposedRect) <= NSMaxX(appScreenRect));
    
    return minYInBounds || maxYInBounds || minXInBounds || maxXInBounds;
}

- (NSRect)popoverRect {
    NSRectEdge popoverEdge = self.preferredEdge;
    NSUInteger attemptCount = 0;
    
    while (![self checkPopoverSizeForScreenWithPopoverEdge:popoverEdge]) {
        if (attemptCount >= 4) {
            popoverEdge = [self screenRectContainsRectEdge:self.preferredEdge] ? self.preferredEdge : [self nextEdgeForEdge:self.preferredEdge];
            
            return [self fitRectToScreen:[self popoverRectForEdge:popoverEdge]];
            break;
        }
        
        popoverEdge = [self nextEdgeForEdge:popoverEdge];
        ++attemptCount;
    }
    
    return [self popoverRectForEdge:popoverEdge];
}

#pragma mark -
#pragma mark - Display animations
#pragma mark -
- (void)popoverShowing:(BOOL)showing animated:(BOOL)animated {
    if (animated) {
        switch (self.animationBehaviour) {
            case FLOPopoverAnimationBehaviorTransform:
                return;
            case FLOPopoverAnimationBehaviorTransition:
                [self popoverTransitionAnimationShowing:showing];
                return;
            default:
                [self popoverZoomAnimationShowing:showing];
                return;
        }
    }
    
    [self popoverDidFinishShowing:showing];
}

- (void)popoverTransitionAnimationShowing:(BOOL)showing {
    [self popoverTransitionAnimationFrameShowing:showing];
}

- (void)popoverTransitionAnimationFrameShowing:(BOOL)showing {
    if (self.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        NSRect fromFrame = self.popoverView.frame;
        NSRect toFrame = fromFrame;
        
        [[FLOPopoverUtils sharedInstance] calculateFromFrame:&fromFrame toFrame:&toFrame withAnimationType:self.animationType showing:showing];
        
        [self.popoverView showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:self];
    }
}

- (void)popoverZoomAnimationShowing:(BOOL)showing {
    NSString *scaleAnimationKey = (showing) ? @"transform.scale.show" : @"transform.scale.hide";
    CFTimeInterval duration = FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = duration;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleAnimation.fromValue = [NSNumber numberWithDouble:0.3f];
    scaleAnimation.toValue = [NSNumber numberWithDouble:1.0f];
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.delegate = self;
    
    [self.popoverView setWantsLayer:YES];
    [self.popoverView.layer addAnimation:scaleAnimation forKey:scaleAnimationKey];
}

- (void)popoverAnimationDidStop {
    _shown = _popoverTempView == nil;
    
    if (self.shown) {
        _popoverTempView = self.popoverView;
    } else {
        _popoverTempView = nil;
    }
    
    [self popoverDidFinishShowing:_shown];
}

#pragma mark -
#pragma mark - NSAnimationDelegate
#pragma mark -
- (void)animationDidEnd:(NSAnimation *)animation {
    [self popoverAnimationDidStop];
}

#pragma mark -
#pragma mark - CAAnimationDelegate
#pragma mark -
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self popoverAnimationDidStop];
}

#pragma mark -
#pragma mark - Event monitor
#pragma mark -
- (void)registerForApplicationEvents {
    if (self.closesWhenPopoverResignsKey) {
        [self registerApplicationEventsMonitor];
    }
    
    if (self.closesWhenApplicationBecomesInactive) {
        [self registerApplicationActiveNotification];
    }
    
    [self registerObserverForPositioningSuperviewsFrameChanged];
    
    [self removeWindowDidMoveEvent];
    [self registerWindowDidMoveEvent];
    
    [self removeWindowResizeEvent];
    [self registerWindowResizeEvent];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self removeApplicationActiveNotification];
    [self unregisterObserverForPositioningSuperviewsFrameChanged];
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
    if (!_appEvent) {
        _appEvent = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent* event) {
            if (self.closesWhenPopoverResignsKey) {
                if (self.popoverView.window == event.window) {
                    NSRect viewRect = [self.popoverView convertRect:self.popoverView.bounds toView:self.popoverView.window.contentView];
                    
                    if (NSPointInRect(event.locationInWindow, viewRect) == NO) {
                        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
                    }
                } else {
                    BOOL contained = [[FLOPopoverUtils sharedInstance] didWindow:self.popoverView.window contain:event.window];
                    
                    if (contained == NO) {
                        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
                    }
                }
            }
            
            return event;
        }];
    }
}

- (void)removeApplicationEventsMonitor {
    if (_appEvent) {
        [NSEvent removeMonitor:_appEvent];
        
        _appEvent = nil;
    }
}

- (void)registerObserverForPositioningSuperviewsFrameChanged {
    self.anchorSuperviews = [[NSMutableArray alloc] init];
    
    [self.anchorSuperviews addObject:self.positioningAnchorView];
    
    [self.positioningAnchorView addObserver:self forKeyPath:@"frame"
                                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                    context:NULL];
    [self.positioningAnchorView addObserver:self forKeyPath:@"superview"
                                    options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                    context:NULL];
    
    NSView *anchorSuperview = [self.positioningAnchorView superview];
    
    while (anchorSuperview != nil) {
        if ([anchorSuperview isKindOfClass:[NSView class]]) {
            [self.anchorSuperviews addObject:anchorSuperview];
            
            [anchorSuperview addObserver:self forKeyPath:@"frame"
                                 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                 context:NULL];
            [anchorSuperview addObserver:self forKeyPath:@"superview"
                                 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                 context:NULL];
        }
        
        anchorSuperview = [anchorSuperview superview];
    }
    
    if (self.anchorSuperviews.count > 0) {
        [_appMainWindow.contentView addObserver:self forKeyPath:@"frame"
                                        options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                        context:NULL];
    }
}

- (void)unregisterObserverForPositioningSuperviewsFrameChanged {
    for (NSView *anchorSuperview in self.anchorSuperviews) {
        [anchorSuperview removeObserver:self forKeyPath:@"frame"];
        [anchorSuperview removeObserver:self forKeyPath:@"superview"];
    }
    
    if (self.anchorSuperviews.count > 0) {
        [_appMainWindow.contentView removeObserver:self forKeyPath:@"frame"];
    }
    
    self.anchorSuperviews = nil;
}

- (void)registerWindowDidMoveEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidMove:) name:NSWindowDidMoveNotification object:nil];
}

- (void)removeWindowDidMoveEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidMoveNotification object:nil];
}

- (void)registerWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
}

- (void)removeWindowResizeEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
}

#pragma mark -
#pragma mark - Utilities
#pragma mark -
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
    
    if ([self.anchorSuperviews containsObject:changedView]) {
        if ((changedView != self.positioningAnchorView) && ![self.positioningAnchorView isDescendantOf:changedView]) {
            return YES;
        }
        
        NSInteger index = [self.anchorSuperviews indexOfObject:changedView];
        
        if (index < (self.anchorSuperviews.count - 1)) {
            NSView *anchorSuperview = [self.anchorSuperviews objectAtIndex:(index + 1)];
            NSView *changingSuperview = [changedView superview];
            
            if (anchorSuperview != changingSuperview) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([[FLOPopoverUtils sharedInstance] appMainWindowResized]) {
        return;
    }
    
    if ([keyPath isEqualToString:@"superview"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *) object;
        
        if ([self shouldClosePopoverByCheckingChangedView:view]) {
            [self close];
            return;
        }
    }
    
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *) object;
        
        if (view == _appMainWindow.contentView) {
            [[FLOPopoverUtils sharedInstance] setAppMainWindowResized:YES];
            return;
        }
        
        if ([self shouldClosePopoverByCheckingChangedView:view]) {
            [self close];
            return;
        }
        
        if ([self.positioningAnchorView isDescendantOf:view]) {
            NSRect positioningInWindowRect = [self.positioningView convertRect:self.positioningView.bounds toView:self.positioningView.window.contentView];
            
            if (NSEqualPoints(self.positioningInWindowRect.origin, positioningInWindowRect.origin) == NO) {
                NSRect popoverRect = [self popoverRectForEdge:self.preferredEdge];
                
                popoverRect = [self.positioningAnchorView.window convertRectFromScreen:popoverRect];
                popoverRect = (NSRect) { .origin = popoverRect.origin, .size = self.popoverView.frame.size };
                
                if (NSContainsRect(_appMainWindow.contentView.visibleRect, popoverRect) == NO) {
                    [self close];
                    return;
                }
                
                [self.popoverView setFrame:popoverRect];
                
                self.positioningInWindowRect = [self.positioningView convertRect:self.positioningView.bounds toView:self.positioningView.window.contentView];
            }
        }
    }
}

- (void)appResignedActive:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSApplicationDidResignActiveNotification]) {
        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
    }
}

- (void)windowDidMove:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidMoveNotification] && [notification.object isKindOfClass:[NSWindow class]]) {
        NSWindow *movedWindow = (NSWindow *) notification.object;
        
        if (movedWindow == _appMainWindow) {
            self.appWindowDidChange = YES;
        }
    }
}

- (void)windowDidResize:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidResizeNotification] && (notification.object == _appMainWindow)) {
        NSWindow *resizedWindow = (NSWindow *) notification.object;
        NSRect popoverRect = [self popoverRectForEdge:self.preferredEdge];
        
        popoverRect = [resizedWindow convertRectFromScreen:popoverRect];
        
        CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.popoverVerticalMargins;
        CGFloat deltaHeight = popoverRect.size.height - newHeight;
        CGFloat popoverOriginX = popoverRect.origin.x;
        CGFloat popoverOriginY = popoverRect.origin.y + ((newHeight < self.originalViewSize.height) ? deltaHeight : 0.0f);
        CGFloat popoverHeight = (newHeight < self.originalViewSize.height) ? newHeight : self.originalViewSize.height;
        
        popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, self.popoverView.frame.size.width, popoverHeight);
        
        [self.popoverView setFrame:popoverRect];
        
        self.appWindowDidChange = YES;
        
        if (NSEqualSizes(self.backgroundView.arrowSize, NSZeroSize) == NO) {
            if ((self.preferredEdge == NSRectEdgeMinY) || (self.preferredEdge == NSRectEdgeMaxY)) {
                self.contentSize = NSMakeSize(self.popoverView.frame.size.width, self.popoverView.frame.size.height - self.backgroundView.arrowSize.height);
            } else {
                self.contentSize = NSMakeSize(self.popoverView.frame.size.width - self.backgroundView.arrowSize.height, self.popoverView.frame.size.height);
            }
        } else {
            self.contentSize = self.popoverView.frame.size;
        }
        
        self.positioningInWindowRect = [self.positioningView convertRect:self.positioningView.bounds toView:self.positioningView.window.contentView];
    }
}

#pragma mark -
#pragma mark - FLOPopoverBackgroundViewDelegate
#pragma mark -
- (void)didPopoverMakeMovement {
    self.popoverDidMove = YES;
}

@end
