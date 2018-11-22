//
//  FLOPopoverUtils.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverUtils.h"

#import "FLOPopoverBackgroundView.h"

@interface FLOPopoverUtils () <NSWindowDelegate>

@property (nonatomic, strong, readwrite) NSWindow *appMainWindow;

@property (nonatomic, strong, readwrite) NSWindow *topWindow;
@property (nonatomic, strong, readwrite) NSView *topView;

@property (nonatomic, assign, readwrite) BOOL appMainWindowResized;

@end

@implementation FLOPopoverUtils

@synthesize appMainWindow = _appMainWindow;
@synthesize topWindow = _topWindow;
@synthesize topView = _topView;
@synthesize appMainWindowResized = _appMainWindowResized;

#pragma mark - Singleton

+ (FLOPopoverUtils *)sharedInstance {
    static FLOPopoverUtils *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FLOPopoverUtils alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        if ([NSApp mainWindow] != nil) {
            _appMainWindow = [NSApp mainWindow];
        } else {
            _appMainWindow = [[[NSApplication sharedApplication] windows] firstObject];
        }
        
        _anchorPoint = NSMakePoint(0.0, 0.0);
        _animationBehaviour = FLOPopoverAnimationBehaviorTransition;
        _animationType = FLOPopoverAnimationLeftToRight;
        _positioningAnchorType = NSNotFound;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    _appMainWindow = nil;
    
    self.contentViewController = nil;
    self.contentView = nil;
    
    [self.positioningAnchorView removeFromSuperview];
    self.positioningAnchorView = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter/Setter

- (NSWindow *)appMainWindow {
    return _appMainWindow;
}

- (NSWindow *)topWindow {
    return _topWindow;
}

- (NSView *)topView {
    return _topView;
}

- (BOOL)appMainWindowResized {
    return _appMainWindowResized;
}

- (void)setTopmostWindow:(NSWindow *)topmostWindow {
    [FLOPopoverUtils sharedInstance].topWindow = topmostWindow;
}

- (void)setTopmostView:(NSView *)topmostView {
    [FLOPopoverUtils sharedInstance].topView = topmostView;
}

- (void)setAppMainWindowResized:(BOOL)appMainWindowResized {
    _appMainWindowResized = appMainWindowResized;
}

#pragma mark - Local implementations

- (void)windowDidEndResize {
    _appMainWindowResized = NO;
}

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationTransition)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing {
    switch (animationType) {
        case FLOPopoverAnimationLeftToRight:
            if (showing) {
                (*fromFrame).origin.x -= (*toFrame).size.width / 2;
            } else {
                if (forwarding) {
                    (*toFrame).origin.x += (*fromFrame).size.width / 2;
                } else {
                    (*toFrame).origin.x -= (*fromFrame).size.width / 2;
                }
            }
            break;
        case FLOPopoverAnimationRightToLeft:
            if (showing) {
                (*fromFrame).origin.x += (*toFrame).size.width / 2;
            } else {
                if (forwarding) {
                    (*toFrame).origin.x -= (*fromFrame).size.width / 2;
                } else {
                    (*toFrame).origin.x += (*fromFrame).size.width / 2;
                }
            }
            break;
        case FLOPopoverAnimationTopToBottom:
            if (showing) {
                (*fromFrame).origin.y += (*toFrame).size.height / 2;
            } else {
                if (forwarding) {
                    (*toFrame).origin.y -= (*fromFrame).size.height / 2;
                } else {
                    (*toFrame).origin.y += (*fromFrame).size.height / 2;
                }
            }
            break;
        case FLOPopoverAnimationBottomToTop:
            if (showing) {
                (*fromFrame).origin.y -= (*toFrame).size.height / 2;
            } else {
                if (forwarding) {
                    (*toFrame).origin.y += (*fromFrame).size.height / 2;
                } else {
                    (*toFrame).origin.y -= (*fromFrame).size.height / 2;
                }
            }
            break;
        case FLOPopoverAnimationFromMiddle:
            break;
        default:
            break;
    }
}

- (BOOL)didTheTreeOfView:(NSView *)view containPosition:(NSPoint)position {
    NSRect relativeRect = [view convertRect:[view alignmentRectForFrame:[view bounds]] toView:nil];
    NSRect viewRect = [view.window convertRectToScreen:relativeRect];
    
    if (NSPointInRect(position, viewRect)) {
        return YES;
    } else {
        for (NSView *item in [view subviews]) {
            if ([self didTheTreeOfView:item containPosition:position]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)didView:(NSView *)parent contain:(NSView *)child {
    return [self didViews:[parent subviews] contain:child];
}

- (BOOL)didViews:(NSArray *)views contain:(NSView *)view {
    if ([views containsObject:view]) {
        return YES;
    } else {
        for (NSView *item in views) {
            if ([self didViews:[item subviews] contain:view]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)didWindow:(NSWindow *)parent contain:(NSWindow *)child {
    return [self didWindows:parent.childWindows contain:child];
}

- (BOOL)didWindows:(NSArray *)windows contain:(NSWindow *)window {
    if ([windows containsObject:window]) {
        return YES;
    } else {
        for (NSWindow *item in windows) {
            if ([self didWindows:item.childWindows contain:window]) {
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark - Display utilities

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    switch (edgeType) {
        case FLOPopoverEdgeTypeAboveLeftEdge:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeAboveRightEdge:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeBelowLeftEdge:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeBelowRightEdge:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeBackwardBottomEdge:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeBackwardTopEdge:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeForwardBottomEdge:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeForwardTopEdge:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeAboveCenter:
            self.preferredEdge = NSRectEdgeMaxY;
            self.anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeBelowCenter:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeBackwardCenter:
            self.preferredEdge = NSRectEdgeMinX;
            self.anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeForwardCenter:
            self.preferredEdge = NSRectEdgeMaxX;
            self.anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        default:
            self.preferredEdge = NSRectEdgeMinY;
            self.anchorPoint = NSMakePoint(1.0, 1.0);
            break;
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    if (self.positioningAnchorType == NSNotFound) return;
    
    NSRect positioningInWindowRect = [positioningView convertRect:positioningView.bounds toView:positioningView.window.contentView];
    
    CGFloat posX = positioningInWindowRect.origin.x;
    CGFloat posY = positioningInWindowRect.origin.y;
    
    if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingPositive) ||
        (self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingNegative) ||
        (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingPositive) ||
        (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingNegative)) {
        posX = fabs(positioningInWindowRect.origin.x - NSMinX(positioningRect));
        posY = fabs(NSMaxY(positioningInWindowRect) - NSMaxY(positioningRect));
        
        if (self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingNegative) {
            posX = -posX;
        } else if (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingPositive) {
            posY = -posY;
        } else if (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingNegative) {
            posX = -posX;
            posY = -posY;
        }
    } else if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingPositive) ||
               (self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingNegative) ||
               (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingPositive) ||
               (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingNegative)) {
        posX = fabs(NSMaxX(positioningInWindowRect) - NSMinX(positioningRect));
        posY = fabs(NSMaxY(positioningInWindowRect) - NSMaxY(positioningRect));
        
        if (self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingNegative) {
            posX = -posX;
        } else if (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingPositive) {
            posY = -posY;
        } else if (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingNegative) {
            posX = -posX;
            posY = -posY;
        }
    } else if ((self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingPositive) ||
               (self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingNegative) ||
               (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingPositive) ||
               (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingNegative)) {
        posX = fabs(NSMaxX(positioningInWindowRect) - NSMinX(positioningRect));
        posY = fabs(positioningInWindowRect.origin.y - NSMaxY(positioningRect));
        
        if (self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingNegative) {
            posX = -posX;
        } else if (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingPositive) {
            posY = -posY;
        } else if (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingNegative) {
            posX = -posX;
            posY = -posY;
        }
    } else {
        posX = fabs(positioningInWindowRect.origin.x - NSMinX(positioningRect));
        posY = fabs(positioningInWindowRect.origin.y - NSMaxY(positioningRect));
        
        if (self.positioningAnchorType == FLOPopoverAnchorBottomPositiveLeadingNegative) {
            posX = -posX;
        } else if (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeLeadingPositive) {
            posY = -posY;
        } else if (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeLeadingNegative) {
            posX = -posX;
            posY = -posY;
        }
    }
    
    if (self.positioningAnchorView == nil) {
        self.positioningAnchorView = [[NSView alloc] initWithFrame:NSZeroRect];
        
        self.positioningAnchorView.wantsLayer = YES;
        self.positioningAnchorView.layer.backgroundColor = [NSColor.clearColor CGColor];
        self.positioningAnchorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [positioningView addSubview:self.positioningAnchorView];
        
        if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingPositive) ||
            (self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingNegative) ||
            (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingPositive) ||
            (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingNegative)) {
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:positioningView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:posY];
            
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:positioningView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:posX];
            
            [top setActive:YES];
            [leading setActive:YES];
            
            [positioningView addConstraints:@[top, leading]];
        } else if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingPositive) ||
                   (self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingNegative) ||
                   (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingPositive) ||
                   (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingNegative)) {
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:positioningView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:posY];
            
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:positioningView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.positioningAnchorView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:posX];
            
            [top setActive:YES];
            [trailing setActive:YES];
            
            [positioningView addConstraints:@[top, trailing]];
        } else if ((self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingPositive) ||
                   (self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingNegative) ||
                   (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingPositive) ||
                   (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingNegative)) {
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:positioningView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.positioningAnchorView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:posY];
            
            NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:positioningView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.positioningAnchorView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:posX];
            
            [bottom setActive:YES];
            [trailing setActive:YES];
            
            [positioningView addConstraints:@[bottom, trailing]];
        } else {
            NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.positioningAnchorView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:positioningView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:posX];
            
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:positioningView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.positioningAnchorView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:posY];
            
            [leading setActive:YES];
            [bottom setActive:YES];
            
            [positioningView addConstraints:@[leading, bottom]];
        }
        
        CGFloat anchorViewWidth = 1.0;
        
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
                if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingPositive) ||
                    (self.positioningAnchorType == FLOPopoverAnchorTopPositiveLeadingNegative) ||
                    (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingPositive) ||
                    (self.positioningAnchorType == FLOPopoverAnchorTopNegativeLeadingNegative)) {
                    if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                        constraint.constant = posX;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeTop) {
                        constraint.constant = posY;
                    }
                } else if ((self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingPositive) ||
                           (self.positioningAnchorType == FLOPopoverAnchorTopPositiveTrailingNegative) ||
                           (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingPositive) ||
                           (self.positioningAnchorType == FLOPopoverAnchorTopNegativeTrailingNegative)) {
                    if (constraint.firstAttribute == NSLayoutAttributeTrailing) {
                        constraint.constant = posX;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeTop) {
                        constraint.constant = posY;
                    }
                } else if ((self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingPositive) ||
                           (self.positioningAnchorType == FLOPopoverAnchorBottomPositiveTrailingNegative) ||
                           (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingPositive) ||
                           (self.positioningAnchorType == FLOPopoverAnchorBottomNegativeTrailingNegative)) {
                    if (constraint.firstAttribute == NSLayoutAttributeTrailing) {
                        constraint.constant = posX;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeBottom) {
                        constraint.constant = posY;
                    }
                } else {
                    if (constraint.firstAttribute == NSLayoutAttributeLeading) {
                        constraint.constant = posX;
                    }
                    
                    if (constraint.firstAttribute == NSLayoutAttributeBottom) {
                        constraint.constant = posY;
                    }
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

#pragma mark - NSWindowDelegate

- (void)windowDidResize:(NSNotification *)notification {
    if ([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]]) {
        NSWindow *resizedWindow = (NSWindow *)notification.object;
        
        if (resizedWindow == self.appMainWindow) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(windowDidEndResize) object:nil];
            [self performSelector:@selector(windowDidEndResize) withObject:nil afterDelay:0.5];
        }
    }
}

@end
