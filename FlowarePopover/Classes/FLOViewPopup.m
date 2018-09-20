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

#import "FLOPopoverWindowController.h"

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

@interface FLOViewPopup () <FLOPopoverBackgroundViewDelegate, NSAnimationDelegate> {
    NSWindow *_appMainWindow;
    NSEvent *_applicationEvent;
    NSView *_snapshotView;
    NSView *_popoverTempView;
}

@property (nonatomic, assign, readwrite) BOOL shown;

@property (nonatomic, strong) NSView *popoverView;
@property (nonatomic, assign) CGFloat popoverVerticalMargins;
@property (nonatomic, assign) BOOL popoverDidMove;

@property (nonatomic, assign) BOOL isRelativeToRectOfView;
@property (nonatomic, strong) NSView *positioningVirtualView;
@property (nonatomic, assign) BOOL applicationWindowDidChange;

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

@synthesize popoverDidShow;
@synthesize popoverDidClose;

- (instancetype)initWithContentView:(NSView *)contentView {
    if (self = [super init]) {
        _appMainWindow = [[FLOPopoverWindow sharedInstance] appMainWindow];
        _contentView = contentView;
        _backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentView.frame];
        _anchorPoint = CGPointMake(0.0f, 0.0f);
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _animated = NO;
        _animationBehaviour = FLOPopoverAnimationBehaviorNone;
        _animationType = FLOPopoverAnimationLeftToRight;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
    }
    
    return self;
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController {
    if (self = [super init]) {
        _appMainWindow = [[FLOPopoverWindow sharedInstance] appMainWindow];
        _contentViewController = contentViewController;
        _contentView = contentViewController.view;
        _backgroundView = [[FLOPopoverBackgroundView alloc] initWithFrame:contentViewController.view.frame];
        _anchorPoint = CGPointMake(0.0f, 0.0f);
        _alwaysOnTop = NO;
        _shouldShowArrow = NO;
        _animated = NO;
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
    }
    
    return self;
}

- (void)dealloc {
    _appMainWindow = nil;
    _applicationEvent = nil;
    _contentViewController = nil;
    _contentView = nil;
    
    [self.positioningVirtualView removeFromSuperview];
    self.positioningVirtualView = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    [self.popoverView removeFromSuperview];
    self.popoverView = nil;
    
    [_snapshotView removeFromSuperview];
    _snapshotView = nil;
    
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
    NSView *topView = [[FLOPopoverWindow sharedInstance] topView];
    NSArray *viewStack = _appMainWindow.contentView.subviews;
    
    if ((topView != nil) && [viewStack containsObject:topView]) {
        [topView removeFromSuperview];
        [_appMainWindow.contentView addSubview:topView];
    }
}

- (void)setupPositioningVirtualViewWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect {
    if (self.isRelativeToRectOfView == NO) {
        if (self.positioningVirtualView == nil) {
            self.positioningVirtualView = [[NSView alloc] initWithFrame:NSZeroRect];
            self.positioningVirtualView.wantsLayer = YES;
            self.positioningVirtualView.layer.backgroundColor = [NSColor.clearColor CGColor];
            self.positioningVirtualView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [_appMainWindow.contentView addSubview:self.positioningVirtualView];
            
            CGFloat virtualViewWidth = 1.0f;
            CGFloat virtualViewHeight = 1.0f;
            NSRect visibleRect = [_appMainWindow.contentView visibleRect];
            NSSize contentViewSize = self.contentView.frame.size;
            
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:positioningView.window.contentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:(visibleRect.size.height - virtualViewHeight - positioningRect.origin.y - contentViewSize.height)];
            
            if (positioningRect.origin.x > (positioningView.window.frame.size.width / 2)) {
                NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:positioningView.window.contentView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.positioningVirtualView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                           multiplier:1
                                                                             constant:(visibleRect.size.width - virtualViewWidth - positioningRect.origin.x)];
                
                [top setActive:YES];
                [trailing setActive:YES];
                
                [positioningView.window.contentView addConstraints:@[top, trailing]];
            } else {
                NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:positioningView.window.contentView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1
                                                                            constant:(positioningRect.origin.x - virtualViewWidth)];
                
                [top setActive:YES];
                [leading setActive:YES];
                
                [positioningView.window.contentView addConstraints:@[top, leading]];
            }
            
            NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1
                                                                      constant:virtualViewWidth];
            NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1
                                                                       constant:virtualViewHeight];
            
            [width setActive:YES];
            [height setActive:YES];
            
            [self.positioningVirtualView addConstraints:@[width, height]];
        }
        
        [self.positioningVirtualView setHidden:NO];
    }
}

#pragma mark -
#pragma mark - Display
#pragma mark -
- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType {
    self.animationBehaviour = animationBehaviour;
    self.animationType = animationType;
}

- (void)rearrangePopoverWithNewContentViewFrame:(NSRect)newFrame positioningRect:(NSRect)rect; {
    [self.contentView setFrame:newFrame];
    self.originalViewSize = newFrame.size;
    self.contentSize = newFrame.size;
    
    [self showIfNeeded:NO];
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
    
    self.isRelativeToRectOfView = YES;
    
    self.positioningRect = rect;
    self.positioningView = positioningView;
    
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
    
    self.isRelativeToRectOfView = NO;
    
    [self setupPositioningVirtualViewWithView:positioningView positioningRect:rect];
    
    self.positioningRect = (self.positioningVirtualView != nil) ? self.positioningVirtualView.bounds : NSZeroRect;
    self.positioningView = positioningView;
    self.anchorPoint = CGPointMake(0.0f, 0.0f);
    
    [self setPopoverEdgeType:edgeType];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(show) object:nil];
    [self performSelector:@selector(show) withObject:nil afterDelay:0.1f];
    
    [self registerForApplicationEvents];
}

- (void)show {
    [self showIfNeeded:YES];
}

- (void)showIfNeeded:(BOOL)needed {
    if (self.isRelativeToRectOfView) {
        if (NSEqualRects(self.positioningRect, NSZeroRect)) {
            self.positioningRect = [self.positioningView bounds];
        }
        
        NSRect windowRelativeRect = [self.positioningView convertRect:[self.positioningView alignmentRectForFrame:self.positioningRect] toView:nil];
        NSRect positionOnScreenRect = [self.positioningView.window convertRectToScreen:windowRelativeRect];
        
        self.backgroundView.popoverOrigin = positionOnScreenRect;
    } else {
        NSRect windowRelativeRect = [self.positioningVirtualView convertRect:[self.positioningVirtualView alignmentRectForFrame:self.positioningRect] toView:nil];
        NSRect positionOnScreenRect = [self.positioningVirtualView.window convertRectToScreen:windowRelativeRect];
        
        self.backgroundView.popoverOrigin = positionOnScreenRect;
    }
    
    self.originalViewSize = NSEqualSizes(self.originalViewSize, NSZeroSize) ? self.contentView.frame.size : self.originalViewSize;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSRectEdge popoverEdge = self.preferredEdge;
    NSRect popoverScreenRect = [self popoverRect];
    
    [self.backgroundView setViewMovable:self.popoverMovable];
    [self.backgroundView setShouldShowArrow:self.shouldShowArrow];
    [self.backgroundView setArrowColor:self.contentView.layer.backgroundColor];
    
    if (self.popoverMovable) {
        self.backgroundView.delegate = self;
    }
    
    CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.backgroundView.frame = (NSRect) { .size = size };
    self.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
    self.contentView.autoresizingMask = (NSViewWidthSizable | NSViewHeightSizable);
    self.contentView.frame = contentViewFrame;
    
    if (![self.contentView isDescendantOf:self.backgroundView]) {
        [self.backgroundView addSubview:self.contentView positioned:NSWindowAbove relativeTo:nil];
    }
    
    [self.backgroundView setFrame:[_appMainWindow convertRectFromScreen:popoverScreenRect]];
    
    if (![self.backgroundView isDescendantOf:self.positioningView.window.contentView]) {
        [self.positioningView.window.contentView addSubview:self.backgroundView positioned:NSWindowAbove relativeTo:self.positioningView];
    }
    
    self.popoverView = self.backgroundView;
    
    self.popoverVerticalMargins = _appMainWindow.contentView.visibleRect.size.height + FLO_CONST_POPOVER_BOTTOM_OFFSET - NSMaxY([_appMainWindow convertRectFromScreen:popoverScreenRect]);
    
    if (needed) {
        if (self.alwaysOnTop) {
            [[FLOPopoverWindow sharedInstance] setTopmostView:self.backgroundView];
        }
        
        [self setTopMostViewIfNecessary];
        
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (!self.shown) return;
    
    if ([self.popoverView isDescendantOf:self.positioningView.window.contentView]) {
        [self removeAllApplicationEvents];
        [self popoverShowing:NO animated:self.animated];
        
        [self.popoverView removeFromSuperview];
        //        self.popoverView = nil;
        
        if (self.isRelativeToRectOfView == NO) {
            if ([self.positioningVirtualView isDescendantOf:_appMainWindow.contentView]) {
                [self.positioningVirtualView setHidden:YES];
            }
        }
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
    }
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    self.shown = showing;
    
    if (showing == YES) {
        self.popoverView.alphaValue = 1.0f;
        
        if (popoverDidShow != nil) popoverDidShow(self);
    } else {
        if (popoverDidClose != nil) popoverDidClose(self);
    }
}

#pragma mark -
#pragma mark - Display utilities
#pragma mark -
- (NSRect)popoverRectForEdge:(NSRectEdge)popoverEdge {
    NSRect windowRelativeRect = [self.positioningView convertRect:[self.positioningView alignmentRectForFrame:self.positioningRect] toView:nil];
    NSRect positionOnScreenRect = [self.positioningView.window convertRectToScreen:windowRelativeRect];
    
    if (self.isRelativeToRectOfView == NO) {
        windowRelativeRect = [self.positioningVirtualView convertRect:[self.positioningVirtualView alignmentRectForFrame:self.positioningRect] toView:nil];
        positionOnScreenRect = [self.positioningVirtualView.window convertRectToScreen:windowRelativeRect];
    }
    
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
    NSRect applicationScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    NSRect popoverRect = [self popoverRectForEdge:popoverEdge];
    
    return NSContainsRect(applicationScreenRect, popoverRect);
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
    NSRect applicationScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    
    if (proposedRect.origin.y < NSMinY(applicationScreenRect)) {
        proposedRect.origin.y = NSMinY(applicationScreenRect);
    }
    if (proposedRect.origin.x < NSMinX(applicationScreenRect)) {
        proposedRect.origin.x = NSMinX(applicationScreenRect);
    }
    
    if (NSMaxY(proposedRect) > NSMaxY(applicationScreenRect)) {
        proposedRect.origin.y = NSMaxY(applicationScreenRect) - NSHeight(proposedRect);
    }
    if (NSMaxX(proposedRect) > NSMaxX(applicationScreenRect)) {
        proposedRect.origin.x = NSMaxX(applicationScreenRect) - NSWidth(proposedRect);
    }
    
    return proposedRect;
}

- (BOOL)screenRectContainsRectEdge:(NSRectEdge)edge {
    NSRect proposedRect = [self popoverRectForEdge:edge];
    NSRect applicationScreenRect = [_appMainWindow convertRectToScreen:_appMainWindow.contentView.bounds];
    
    BOOL minYInBounds = (edge == NSRectEdgeMinY) && (NSMinY(proposedRect) >= NSMinY(applicationScreenRect));
    BOOL maxYInBounds = (edge == NSRectEdgeMaxY) && (NSMaxY(proposedRect) <= NSMaxY(applicationScreenRect));
    BOOL minXInBounds = (edge == NSRectEdgeMinX) && (NSMinX(proposedRect) >= NSMinX(applicationScreenRect));
    BOOL maxXInBounds = (edge == NSRectEdgeMaxX) && (NSMaxX(proposedRect) <= NSMaxX(applicationScreenRect));
    
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
    BOOL shouldShowAnimated = animated;
    
    if (self.animatedWithContext == YES) {
        if (shouldShowAnimated &&
            ((showing == NO) && (self.popoverMovable == YES) && (self.popoverDidMove == YES)) ) {
            shouldShowAnimated = NO;
            self.popoverDidMove = NO;
        }
        
        if (shouldShowAnimated && (self.applicationWindowDidChange == YES)) {
            shouldShowAnimated = NO;
            self.applicationWindowDidChange = NO;
        }
    }
    
    if (shouldShowAnimated) {
        switch (self.animationBehaviour) {
            case FLOPopoverAnimationBehaviorTransform:
                return;
            case FLOPopoverAnimationBehaviorTransition:
                [self popoverTransitionAnimationShowing:showing];
                return;
            default:
                return;
        }
    }
    
    [self popoverDidFinishShowing:showing];
}

- (void)popoverTransitionAnimationShowing:(BOOL)showing {
    if (self.animatedWithContext == YES) {
        [self popoverTransitionAnimationContextShowing:showing];
    } else {
        [self popoverTransitionAnimationFrameShowing:showing];
    }
}

- (void)popoverTransitionAnimationContextShowing:(BOOL)showing {
    if (self.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        // Make the popover content view display itself for snapshot preparing.
        self.popoverView.alphaValue = 1.0f;
        
        if (showing && (_snapshotView == nil)) {
            //============================================================================================================
            // Create animation view
            //============================================================================================================
            _snapshotView = [[NSView alloc] initWithFrame:self.popoverView.frame];
            // MUST set snapshot view wantsLayer to YES for animation. Without it there is no animation at all.
            _snapshotView.wantsLayer = YES;
            // Wait 10 ms for the popover content view loads its UI in the first time popover opened.
            usleep(10000);
        }
        
        //============================================================================================================
        // Take a snapshot image of the popover content view
        //============================================================================================================
        [_snapshotView setHidden:NO];
        [self takeSnapshotImageFromView:self.popoverView toView:_snapshotView];
        
        if (![_snapshotView isDescendantOf:self.positioningView.window.contentView]) {
            [self.positioningView.window.contentView addSubview:_snapshotView positioned:NSWindowAbove relativeTo:self.popoverView];
        }
        // After snapshot process finished, make the popover content view invisible to start animation.
        self.popoverView.alphaValue = 0.0f;
        
        //============================================================================================================
        // Animation for snapshot view
        //============================================================================================================
        NSRect fromFrame = self.popoverView.frame;
        NSRect toFrame = fromFrame;
        
        [FLOPopoverUtils calculateFromFrame:&fromFrame toFrame:&toFrame withAnimationType:self.animationType showing:showing];
        
        __weak typeof(self) wself = self;
        
        [_snapshotView setFrame:fromFrame];
        [[_snapshotView animator] setFrameOrigin:fromFrame.origin];
        
        [_snapshotView showingAnimated:showing fromPosition:fromFrame.origin toPosition:toFrame.origin completionHandler:^{
            [wself animationContextDidEnd:showing];
        }];
    }
}

- (void)popoverTransitionAnimationFrameShowing:(BOOL)showing {
    if (self.animationBehaviour == FLOPopoverAnimationBehaviorTransition) {
        NSRect fromFrame = self.popoverView.frame;
        NSRect toFrame = fromFrame;
        
        [FLOPopoverUtils calculateFromFrame:&fromFrame toFrame:&toFrame withAnimationType:self.animationType showing:showing];
        
        [self.popoverView showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:self];
    }
}

/**
 * Get snapshot of selected view as bitmap image then add it to the animated view.
 *
 * @param view target view for taking snapshot.
 * @param snapshotView contains the snapshot image.
 */
- (void)takeSnapshotImageFromView:(NSView *)view toView:(NSView *)snapshotView {
    NSImage *image = [FLOExtensionsGraphicsContext snapshotImageFromView:view];
    [snapshotView layer].contents = image;
}

- (void)animationContextDidEnd:(BOOL)showing {
    [self popoverDidFinishShowing:showing];
    
    if ([_snapshotView isDescendantOf:self.positioningView.window.contentView]) {
        [_snapshotView removeFromSuperview];
    }
    
    [_snapshotView setHidden:YES];
}

- (void)setPopoverVisualEffectHiddenIfNeeded:(BOOL)needed {
    [self.contentView.subviews enumerateObjectsUsingBlock:^(NSView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[NSVisualEffectView class]]) {
            view.alphaValue = needed ? 0.0f : 1.0f;
        }
    }];
}

#pragma mark -
#pragma mark - NSAnimationDelegate
#pragma mark -
- (void)animationDidEnd:(NSAnimation *)animation {
    _shown = _popoverTempView == nil;
    
    if (self.shown) {
        _popoverTempView = self.popoverView;
    } else {
        _popoverTempView = nil;
    }
    
    [self popoverDidFinishShowing:_shown];
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
    
    [self removeWindowDidMoveEvent];
    [self registerWindowDidMoveEvent];
    [self removeWindowResizeEvent];
    [self registerWindowResizeEvent];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationEventsMonitor];
    [self removeApplicationActiveNotification];
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
    if (!_applicationEvent) {
        _applicationEvent = [NSEvent addLocalMonitorForEventsMatchingMask:(NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown) handler:^(NSEvent* event) {
            if (self.closesWhenPopoverResignsKey) {
                if (self.popoverView.window != event.window) {
                    [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
                } else {
                    NSPoint eventPoint = [self.popoverView convertPoint:event.locationInWindow fromView:nil];
                    
                    if (NSPointInRect(eventPoint, self.popoverView.frame) == NO) {
                        [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
                    }
                }
            }
            
            return event;
        }];
    }
}

- (void)removeApplicationEventsMonitor {
    if (_applicationEvent) {
        [NSEvent removeMonitor:_applicationEvent];
        
        _applicationEvent = nil;
    }
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
    if (self.shown) {
        [self close];
        return;
    }
}

- (void)closePopover:(NSResponder *)sender completion:(void (^)(void))complete {
    // code ...
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
            self.applicationWindowDidChange = YES;
        }
    }
}

- (void)windowDidResize:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]]) {
        NSWindow *resizedWindow = (NSWindow *) notification.object;
        
        if (resizedWindow == _appMainWindow) {
            NSRect popoverRect = [self popoverRectForEdge:self.preferredEdge];
            popoverRect = [resizedWindow convertRectFromScreen:popoverRect];
            
            CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.popoverVerticalMargins;
            CGFloat deltaHeight = popoverRect.size.height - newHeight;
            CGFloat popoverOriginX = popoverRect.origin.x;
            CGFloat popoverOriginY = popoverRect.origin.y + ((newHeight < self.originalViewSize.height) ? deltaHeight : 0.0f);
            CGFloat popoverHeight = (newHeight < self.originalViewSize.height) ? newHeight : self.originalViewSize.height;
            
            popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, popoverRect.size.width, popoverHeight);
            
            [self.popoverView setFrame:popoverRect];
            
            self.contentSize = self.popoverView.frame.size;
            self.applicationWindowDidChange = YES;
        }
    }
}

#pragma mark -
#pragma mark - FLOPopoverBackgroundViewDelegate
#pragma mark -
- (void)didPopoverMakeMovement {
    self.popoverDidMove = YES;
}

@end
