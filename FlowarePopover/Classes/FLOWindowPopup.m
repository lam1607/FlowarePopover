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

#import "FLOPopoverWindowController.h"

#import "FLOPopoverBackgroundView.h"

#import "FLOPopoverUtils.h"

@interface FLOWindowPopup () <FLOPopoverBackgroundViewDelegate, NSAnimationDelegate> {
    NSWindow *_appMainWindow;
    NSEvent *_applicationEvent;
    NSWindow *_animatedWindow;
    NSWindow *_snapshotWindow;
    NSView *_snapshotView;
    NSWindow *_popoverTempWindow;
}

@property (nonatomic, strong) FLOPopoverWindow *popoverWindow;
@property (nonatomic, assign) NSWindowLevel popoverWindowLevel;
@property (nonatomic, assign) CGFloat popoverVerticalMargins;
@property (nonatomic, assign) BOOL popoverDidMove;

@property (nonatomic, assign) BOOL isRelativeToRectOfView;
@property (nonatomic, strong) NSView *positioningVirtualView;
@property (nonatomic, assign) BOOL shouldUpdatePositioningRect;
@property (nonatomic, assign) BOOL applicationWindowDidChange;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationTransition animationType;

@property (nonatomic, strong) FLOPopoverBackgroundView *backgroundView;
@property (nonatomic, assign) NSRect positioningRect;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic) NSRectEdge preferredEdge;
@property (nonatomic) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic) CGSize originalViewSize;

@end

@implementation FLOWindowPopup

@synthesize popoverDidShow;
@synthesize popoverDidClose;

- (instancetype)initWithContentView:(NSView *)contentView {
    if (self = [super init]) {
        _appMainWindow = [[FLOPopoverUtils sharedInstance] appMainWindow];
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
        _isRelativeToRectOfView = YES;
        _shouldUpdatePositioningRect = NO;
    }
    
    return self;
}

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
        _closesWhenPopoverResignsKey = NO;
        _closesWhenApplicationBecomesInactive = NO;
        _isRelativeToRectOfView = YES;
        _shouldUpdatePositioningRect = NO;
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
    
    [self.popoverWindow close];
    self.popoverWindow = nil;
    
    [_animatedWindow close];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Processes
#pragma mark -
- (BOOL)isShown {
    return self.popoverWindow.isVisible;
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

- (void)setTopMostWindowIfNecessary {
    NSWindow *topWindow = [[FLOPopoverUtils sharedInstance] topWindow];
    NSArray *windowStack = _appMainWindow.childWindows;
    
    if ((topWindow != nil) && [windowStack containsObject:topWindow]) {
        NSWindowLevel topWindowLevel = topWindow.level;
        
        [_appMainWindow removeChildWindow:topWindow];
        [_appMainWindow addChildWindow:topWindow ordered:NSWindowAbove];
        topWindow.level = topWindowLevel;
    }
}

- (void)resetContentViewControllerRect:(NSNotification *)notification {
    self.contentViewController.view.frame = CGRectMake(self.contentViewController.view.frame.origin.x, self.contentViewController.view.frame.origin.y, self.originalViewSize.width, self.originalViewSize.height);
    
    if ([notification.name isEqualToString:NSWindowWillCloseNotification]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
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
            NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.contentView.frame.size : self.contentSize;
            
            CGFloat topContant = visibleRect.size.height + virtualViewHeight - positioningRect.origin.y - contentViewSize.height;
            
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_appMainWindow.contentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:topContant];
            
            if (positioningRect.origin.x > (visibleRect.size.width / 2)) {
                CGFloat trailingContant = visibleRect.size.width + virtualViewWidth - positioningRect.origin.x;
                
                NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_appMainWindow.contentView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.positioningVirtualView
                                                                            attribute:NSLayoutAttributeTrailing
                                                                           multiplier:1
                                                                             constant:trailingContant];
                
                [top setActive:YES];
                [trailing setActive:YES];
                
                [_appMainWindow.contentView addConstraints:@[top, trailing]];
            } else {
                CGFloat leadingContant = positioningRect.origin.x + virtualViewWidth;
                
                NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.positioningVirtualView
                                                                           attribute:NSLayoutAttributeLeading
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:_appMainWindow.contentView
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1
                                                                            constant:leadingContant];
                
                [top setActive:YES];
                [leading setActive:YES];
                
                [_appMainWindow.contentView addConstraints:@[top, leading]];
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
        
        if ((self.shouldUpdatePositioningRect == YES) &&
            (self.positioningVirtualView != nil) && [self.positioningVirtualView isDescendantOf:_appMainWindow.contentView]) {
            CGFloat virtualViewWidth = 1.0f;
            CGFloat virtualViewHeight = 1.0f;
            NSRect visibleRect = [_appMainWindow.contentView visibleRect];
            NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.contentView.frame.size : self.contentSize;
            
            CGFloat topContant = visibleRect.size.height + virtualViewHeight - positioningRect.origin.y - contentViewSize.height;
            CGFloat trailingContant = visibleRect.size.width + virtualViewWidth - positioningRect.origin.x;
            CGFloat leadingContant = positioningRect.origin.x + virtualViewWidth;
            
            for (NSLayoutConstraint *constraint in _appMainWindow.contentView.constraints) {
                if ((constraint.firstItem == self.positioningVirtualView) || (constraint.secondItem == self.positioningVirtualView)) {
                    if (constraint.firstAttribute == NSLayoutAttributeTop) {
                        constraint.constant = topContant;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                        constraint.constant = leadingContant;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeTrailing) {
                        constraint.constant = trailingContant;
                    }
                }
            }
            
            self.shouldUpdatePositioningRect = NO;
            
            [_appMainWindow.contentView setNeedsUpdateConstraints:YES];
            [_appMainWindow.contentView updateConstraints];
            [_appMainWindow.contentView updateConstraintsForSubtreeIfNeeded];
            [_appMainWindow.contentView layoutSubtreeIfNeeded];
        }
        
        [self.positioningVirtualView setHidden:NO];
    }
}

#pragma mark -
#pragma mark - Display
#pragma mark -
/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level {
    self.popoverWindowLevel = level;
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType {
    self.animationBehaviour = animationBehaviour;
    self.animationType = animationType;
}

- (void)rearrangePopoverWithNewContentViewFrame:(NSRect)newFrame {
    self.originalViewSize = newFrame.size;
    self.contentSize = newFrame.size;
    
    if (self.shown) {
        [self showIfNeeded:NO];
    }
}

- (void)rearrangePopoverWithNewContentViewFrame:(NSRect)newFrame positioningRect:(NSRect)rect; {
    self.originalViewSize = newFrame.size;
    self.contentSize = newFrame.size;
    
    if (NSEqualPoints(rect.origin, self.positioningRect.origin) == NO) {
        self.shouldUpdatePositioningRect = YES;
    }
    
    [self setupPositioningVirtualViewWithView:self.positioningView positioningRect:rect];
    
    self.positioningRect = (self.positioningVirtualView != nil) ? self.positioningVirtualView.bounds : NSZeroRect;
    
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
    [self.backgroundView setWindowDetachable:self.popoverShouldDetach];
    
    if (self.isRelativeToRectOfView) {
        [self.backgroundView setShouldShowArrow:self.shouldShowArrow];
        [self.backgroundView setArrowColor:self.contentView.layer.backgroundColor];
    }
    
    if (self.popoverMovable || self.popoverShouldDetach) {
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
    
    if (self.popoverWindow == nil) {
        self.popoverWindow = [[FLOPopoverWindow alloc] initWithContentRect:popoverScreenRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        self.popoverWindow.hasShadow = YES;
        self.popoverWindow.releasedWhenClosed = NO;
        self.popoverWindow.opaque = NO;
        self.popoverWindow.backgroundColor = NSColor.clearColor;
        self.popoverWindow.contentView = self.backgroundView;
    }
    
    [self.popoverWindow setFrame:popoverScreenRect display:NO];
    
    if (![self.positioningView.window.childWindows containsObject:self.popoverWindow]) {
        [self.positioningView.window addChildWindow:self.popoverWindow ordered:NSWindowAbove];
    }
    
    self.popoverWindow.level = self.popoverWindowLevel;
    
    self.popoverVerticalMargins = _appMainWindow.contentView.visibleRect.size.height + FLO_CONST_POPOVER_BOTTOM_OFFSET - NSMaxY([_appMainWindow convertRectFromScreen:popoverScreenRect]);
    
    if (needed) {
        _popoverTempWindow = self.popoverWindow;
        
        if (self.alwaysOnTop) {
            [[FLOPopoverUtils sharedInstance] setTopmostWindow:self.popoverWindow];
        }
        
        [self setTopMostWindowIfNecessary];
        
        [self popoverShowing:YES animated:self.animated];
    }
}

- (void)close {
    if (!self.shown) return;
    
    _popoverTempWindow = nil;
    
    [self removeAllApplicationEvents];
    [self popoverShowing:NO animated:self.animated];
    
    [self.positioningView.window removeChildWindow:self.popoverWindow];
    [self.popoverWindow close];
    
    if (self.isRelativeToRectOfView == NO) {
        if ([self.positioningVirtualView isDescendantOf:_appMainWindow.contentView]) {
            [self.positioningVirtualView setHidden:YES];
        }
    }
    
    [self resetContentViewControllerRect:nil];
}

- (void)popoverDidFinishShowing:(BOOL)showing {
    if (showing == YES) {
        [self.popoverWindow makeKeyAndOrderFront:nil];
        self.popoverWindow.alphaValue = 1.0f;
        
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
    NSRect returnRect = NSMakeRect(0.0f, 0.0f, popoverSize.width, popoverSize.height);
    
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
    NSRect screenRect = self.positioningView.window.screen.visibleFrame;
    NSRect popoverRect = [self popoverRectForEdge:popoverEdge];
    
    return NSContainsRect(screenRect, popoverRect);
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
    NSRect screenRect = self.positioningView.window.screen.visibleFrame;
    
    if (proposedRect.origin.y < NSMinY(screenRect)) {
        proposedRect.origin.y = NSMinY(screenRect);
    }
    if (proposedRect.origin.x < NSMinX(screenRect)) {
        proposedRect.origin.x = NSMinX(screenRect);
    }
    
    if (NSMaxY(proposedRect) > NSMaxY(screenRect)) {
        proposedRect.origin.y = NSMaxY(screenRect) - NSHeight(proposedRect);
    }
    if (NSMaxX(proposedRect) > NSMaxX(screenRect)) {
        proposedRect.origin.x = NSMaxX(screenRect) - NSWidth(proposedRect);
    }
    
    return proposedRect;
}

- (BOOL)screenRectContainsRectEdge:(NSRectEdge)edge {
    NSRect proposedRect = [self popoverRectForEdge:edge];
    NSRect screenRect = self.positioningView.window.screen.visibleFrame;
    
    BOOL minYInBounds = (edge == NSRectEdgeMinY) && (NSMinY(proposedRect) >= NSMinY(screenRect));
    BOOL maxYInBounds = (edge == NSRectEdgeMaxY) && (NSMaxY(proposedRect) <= NSMaxY(screenRect));
    BOOL minXInBounds = (edge == NSRectEdgeMinX) && (NSMinX(proposedRect) >= NSMinX(screenRect));
    BOOL maxXInBounds = (edge == NSRectEdgeMaxX) && (NSMaxX(proposedRect) <= NSMaxX(screenRect));
    
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
            ((showing == NO) && ((self.popoverMovable == YES) || (self.popoverShouldDetach == YES)) && (self.popoverDidMove == YES))) {
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
        if (_animatedWindow == nil) {
            //============================================================================================================
            // Create animation window
            //============================================================================================================
            _animatedWindow = [[FLOPopoverUtils sharedInstance] animatedWindow];
        }
        
        if (![self.popoverWindow.childWindows containsObject:_animatedWindow]) {
            [self.popoverWindow addChildWindow:_animatedWindow ordered:NSWindowAbove];
        }
        
        // Make the popover window display itself for snapshot preparing.
        self.popoverWindow.alphaValue = 1.0f;
        
        if (showing && (_snapshotView == nil)) {
            //============================================================================================================
            // Create animation view
            //============================================================================================================
            _snapshotView = [[NSView alloc] initWithFrame:[_animatedWindow convertRectFromScreen:self.popoverWindow.frame]];
            // MUST set snapshot view wantsLayer to YES for animation. Without it there is no animation at all.
            _snapshotView.wantsLayer = YES;
            // Wait 10 ms for the popover content view loads its UI in the first time popover opened.
            usleep(10000);
        }
        
        //============================================================================================================
        // Take a snapshot image of the popover content view
        //============================================================================================================
        [_snapshotView setHidden:NO];
        [self takeSnapshotImageFromView:self.popoverWindow.contentView toView:_snapshotView];
        
        if (![_snapshotView isDescendantOf:_animatedWindow.contentView]) {
            [_animatedWindow.contentView addSubview:_snapshotView positioned:NSWindowAbove relativeTo:nil];
        }
        // After snapshot process finished, make the popover window invisible to start animation.
        self.popoverWindow.alphaValue = 0.0f;
        
        [_animatedWindow makeKeyAndOrderFront:nil];
        
        //============================================================================================================
        // Animation for snapshot view
        //============================================================================================================
        NSRect fromFrame = [_animatedWindow convertRectFromScreen:self.popoverWindow.frame];
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
        NSRect fromFrame = self.popoverWindow.frame;
        NSRect toFrame = fromFrame;
        
        [FLOPopoverUtils calculateFromFrame:&fromFrame toFrame:&toFrame withAnimationType:self.animationType showing:showing];
        
        [self.popoverWindow showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:self];
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
    
    if ([_snapshotView isDescendantOf:_animatedWindow.contentView]) {
        [_snapshotView removeFromSuperview];
    }
    
    [_snapshotView setHidden:YES];
    
    if ([self.popoverWindow.childWindows containsObject:_animatedWindow]) {
        [self.popoverWindow removeChildWindow:_animatedWindow];
    }
    
    [_animatedWindow close];
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
    BOOL showing = _popoverTempWindow != nil;
    
    [self popoverDidFinishShowing:showing];
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
                if (self.popoverWindow != event.window) {
                    [self performSelector:@selector(close) withObject:nil afterDelay:0.1f];
                } else {
                    NSPoint eventPoint = [self.popoverWindow.contentView convertPoint:event.locationInWindow fromView:nil];
                    
                    if (NSPointInRect(eventPoint, self.popoverWindow.contentView.bounds) == NO) {
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
        if (notification.object == self.popoverWindow) {
            return;
        }
        
        NSWindow *resizedWindow = (NSWindow *) notification.object;
        NSRect popoverRect = [self popoverRectForEdge:self.preferredEdge];
        
        if (resizedWindow == _appMainWindow) {
            CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - self.popoverVerticalMargins;
            CGFloat deltaHeight = popoverRect.size.height - newHeight;
            CGFloat popoverOriginX = popoverRect.origin.x;
            CGFloat popoverOriginY = popoverRect.origin.y + ((newHeight < self.originalViewSize.height) ? deltaHeight : 0.0f);
            CGFloat popoverHeight = (newHeight < self.originalViewSize.height) ? newHeight : self.originalViewSize.height;
            
            popoverRect = NSMakeRect(popoverOriginX, popoverOriginY, popoverRect.size.width, popoverHeight);
            
            [self.popoverWindow setFrame:popoverRect display:YES];
        } else {
            [self.popoverWindow setFrameOrigin:popoverRect.origin];
        }
        
        self.contentSize = self.popoverWindow.frame.size;
        self.applicationWindowDidChange = YES;
    }
}

#pragma mark -
#pragma mark - FLOPopoverBackgroundViewDelegate
#pragma mark -
- (void)didPopoverMakeMovement {
    self.popoverDidMove = YES;
}

- (void)didPopoverBecomeDetachableWindow:(NSWindow *)detachedWindow {
    if (detachedWindow == self.popoverWindow) {
        if ([self.positioningView.window.childWindows containsObject:detachedWindow]) {
            [self.positioningView.window removeChildWindow:self.popoverWindow];
            
            NSView *contentView = self.popoverWindow.contentView;
            NSRect windowRect = self.popoverWindow.frame;
            NSUInteger styleMask = NSWindowStyleMaskTitled + NSWindowStyleMaskClosable;
            
            NSWindow *temp = [[NSWindow alloc] initWithContentRect:windowRect styleMask:styleMask backing:NSBackingStoreBuffered defer:YES];
            NSRect detachableWindowRect = [temp frameRectForContentRect:windowRect];
            
            contentView.wantsLayer = YES;
            contentView.layer.cornerRadius = 0.0f;
            [self.popoverWindow setStyleMask:styleMask];
            [self.popoverWindow setFrame:detachableWindowRect display:YES];
            [self.popoverWindow makeKeyAndOrderFront:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetContentViewControllerRect:) name:NSWindowWillCloseNotification object:nil];
        }
    }
}

@end
