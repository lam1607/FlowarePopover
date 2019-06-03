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
        
        _shouldShowArrowWithVisualEffect = NO;
        _arrowVisualEffectMaterial = NSVisualEffectMaterialLight;
        _arrowVisualEffectBlendingMode = NSVisualEffectBlendingModeBehindWindow;
        _arrowVisualEffectState = NSVisualEffectStateInactive;
        
        _staysInApplicationFrame = NO;
        _animatedInAppFrame = NO;
        _popoverMoved = NO;
        _animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        _animationType = FLOPopoverAnimationDefault;
        _relativePositionType = FLOPopoverRelativePositionAutomatic;
        _anchorPoint = NSMakePoint(0.0, 0.0);
        _containerBoundsChangedByNotification = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    _appMainWindow = nil;
    
    self.contentViewController = nil;
    
    if (self.contentView.superview != nil) {
        [self.contentView removeFromSuperview];
    }
    
    self.contentView = nil;
    
    if ((self.positioningAnchorView != self.positioningView) && [self.positioningAnchorView isDescendantOf:self.positioningView]) {
        [self.positioningAnchorView removeFromSuperview];
    }
    
    self.positioningView = nil;
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

#pragma mark - Local methods

- (NSRect)containerFrame {
    return (self.staysInApplicationFrame ? [FLOPopoverUtils sharedInstance].appMainWindow.frame : [FLOPopoverUtils sharedInstance].appMainWindow.screen.frame);
}

- (void)windowDidEndResize {
    _appMainWindowResized = NO;
}

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing {
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
        default:
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
    }
}

- (void)calculateTransitionFrame:(NSRect *)transitionFrame fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing {
    if (showing || ((showing == NO) && forwarding)) {
        if (animationType == FLOPopoverAnimationBottomToTop) {
            *transitionFrame = NSMakeRect(fromFrame.origin.x, fromFrame.origin.y, toFrame.size.width, NSMaxY(toFrame) - NSMinY(fromFrame));
        } else if (animationType == FLOPopoverAnimationTopToBottom) {
            *transitionFrame = NSMakeRect(toFrame.origin.x, toFrame.origin.y, toFrame.size.width, NSMaxY(fromFrame) - NSMinY(toFrame));
        } else if (animationType == FLOPopoverAnimationRightToLeft) {
            *transitionFrame = NSMakeRect(toFrame.origin.x, toFrame.origin.y, NSMaxX(fromFrame) - NSMinX(toFrame), toFrame.size.height);
        } else {
            *transitionFrame = NSMakeRect(fromFrame.origin.x, fromFrame.origin.y, NSMaxX(toFrame) - NSMinX(fromFrame), toFrame.size.height);
        }
    } else {
        if (animationType == FLOPopoverAnimationBottomToTop) {
            *transitionFrame = NSMakeRect(toFrame.origin.x, toFrame.origin.y, toFrame.size.width, NSMaxY(fromFrame) - NSMinY(toFrame));
        } else if (animationType == FLOPopoverAnimationTopToBottom) {
            *transitionFrame = NSMakeRect(fromFrame.origin.x, fromFrame.origin.y, toFrame.size.width, NSMaxY(toFrame) - NSMinY(fromFrame));
        } else if (animationType == FLOPopoverAnimationRightToLeft) {
            *transitionFrame = NSMakeRect(fromFrame.origin.x, fromFrame.origin.y, NSMaxX(toFrame) - NSMinX(fromFrame), toFrame.size.height);
        } else {
            *transitionFrame = NSMakeRect(toFrame.origin.x, toFrame.origin.y, NSMaxX(fromFrame) - NSMinX(toFrame), toFrame.size.height);
        }
    }
}

- (void)calculateStartPosition:(NSPoint *)startPosition endPosition:(NSPoint *)endPosition layerFrame:(NSRect)layerFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing {
    if (animationType == FLOPopoverAnimationBottomToTop) {
        if (showing) {
            (*endPosition).y -= layerFrame.size.height / 2;
        } else {
            (*startPosition).y -= layerFrame.size.height / 2;
        }
    } else if (animationType == FLOPopoverAnimationTopToBottom) {
        if (showing) {
            (*endPosition).y += layerFrame.size.height / 2;
        } else {
            (*startPosition).y += layerFrame.size.height / 2;
        }
    } else if (animationType == FLOPopoverAnimationRightToLeft) {
        if (showing) {
            (*startPosition).x += layerFrame.size.width / 2;
        } else {
            (*endPosition).x += layerFrame.size.width / 2;
        }
    } else {
        if (showing) {
            (*startPosition).x -= layerFrame.size.width / 2;
        } else {
            (*endPosition).x -= layerFrame.size.width / 2;
        }
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

- (NSVisualEffectView *)contentViewDidContainVisualEffect {
    for (NSView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[NSVisualEffectView class]]) {
            return (NSVisualEffectView *)view;
        }
    }
    
    return nil;
}

- (void)addView:(NSView *)view toParent:(NSView *)parentView {
    if ((view == nil) || (parentView == nil)) return;
    
    if ([view isDescendantOf:parentView] == NO) {
        [parentView addSubview:view];
        parentView.autoresizesSubviews = YES;
        
        view.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

- (void)setupAutoresizingMaskIfNeeded:(BOOL)needed {
    if (self.needAutoresizingMask) {
        self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = YES;
        
        if (needed) {
            self.contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
            self.backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        } else {
            self.contentView.autoresizingMask = NSViewNotSizable;
            self.backgroundView.autoresizingMask = NSViewNotSizable;
        }
    }
}

- (void)resetContainerBoundsChangedByNotification {
    self.containerBoundsChangedByNotification = NO;
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

- (NSDictionary *)relativePositionValuesForView:(NSView *)view rect:(NSRect)rect {
    NSMutableDictionary *relativePositionValues = [[NSMutableDictionary alloc] init];
    
    FLOPopoverRelativePositionType relativeType = FLOPopoverRelativePositionTopLeading;
    NSPoint relativePosition;
    CGFloat posX = 0.0;
    CGFloat posY = 0.0;
    
    NSRect viewScreenRect = [view.window convertRectToScreen:[view convertRect:view.bounds toView:view.window.contentView]];
    CGFloat viewMinX = NSMinX(viewScreenRect);
    CGFloat viewMaxX = NSMaxX(viewScreenRect);
    CGFloat viewMinY = NSMinY(viewScreenRect);
    CGFloat viewMaxY = NSMaxY(viewScreenRect);
    NSPoint viewCenter = NSMakePoint(viewMinX + (viewScreenRect.size.width / 2), viewMinY + (viewScreenRect.size.height / 2));
    
    // We display the popover as the given frame (not on sticking sender as [showRelativeToRect:ofView:edgeType:].
    // But the idea as the same with the sticking sender displaying. Therefore, we calculate position (posX, posY) of the anchor view
    // for displaying the popover relatively to the anchor view (as sticking view). That's why we must use the NSMaxY(rect) for calculations.
    if (self.relativePositionType == FLOPopoverRelativePositionAutomatic) {
        if (NSMaxY(rect) >= viewCenter.y) {
            // Top
            if (rect.origin.x <= viewCenter.x) {
                // Leading
                relativeType = FLOPopoverRelativePositionTopLeading;
                
                posX = rect.origin.x - viewMinX;
            } else {
                // Trailing
                relativeType = FLOPopoverRelativePositionTopTrailing;
                
                posX = viewMaxX - rect.origin.x;
            }
            
            posY = viewMaxY - NSMaxY(rect);
        } else {
            // Bottom
            if (rect.origin.x <= viewCenter.x) {
                // Leading
                relativeType = FLOPopoverRelativePositionBottomLeading;
                
                posX = rect.origin.x - viewMinX;
            } else {
                // Trailing
                relativeType = FLOPopoverRelativePositionBottomTrailing;
                
                posX = viewMaxX - rect.origin.x;
            }
            
            posY = NSMaxY(rect) - viewMinY;
        }
    } else {
        relativeType = self.relativePositionType;
        
        if ((self.relativePositionType == FLOPopoverRelativePositionTopLeading) || (self.relativePositionType == FLOPopoverRelativePositionTopTrailing)) {
            // Top
            if (self.relativePositionType == FLOPopoverRelativePositionTopLeading) {
                // Leading
                posX = rect.origin.x - viewMinX;
            } else {
                // Trailing
                posX = viewMaxX - rect.origin.x;
            }
            
            posY = viewMaxY - NSMaxY(rect);
        } else {
            // Bottom
            if (self.relativePositionType == FLOPopoverRelativePositionBottomLeading) {
                // Leading
                posX = rect.origin.x - viewMinX;
            } else {
                // Trailing
                posX = viewMaxX - rect.origin.x;
            }
            
            posY = NSMaxY(rect) - viewMinY;
        }
    }
    
    relativePosition = NSMakePoint(posX, posY);
    
    [relativePositionValues setObject:@(relativeType) forKey:@"type"];
    [relativePositionValues setObject:@(relativePosition) forKey:@"position"];
    
    return relativePositionValues;
}

- (NSView *)anchorViewWithRelativePosition:(NSPoint)position type:(FLOPopoverRelativePositionType)relativeType parent:(NSView *)parentView {
    CGFloat posX = position.x;
    CGFloat posY = position.y;
    
    NSView *anchorView = [[NSView alloc] initWithFrame:NSZeroRect];
    
    anchorView.wantsLayer = YES;
    anchorView.layer.backgroundColor = [NSColor.clearColor CGColor];
    anchorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [parentView addSubview:anchorView];
    
    if (relativeType == FLOPopoverRelativePositionTopLeading) {
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:anchorView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parentView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:posY];
        
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:anchorView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:posX];
        
        [top setActive:YES];
        [leading setActive:YES];
        
        [parentView addConstraints:@[top, leading]];
    } else if (relativeType == FLOPopoverRelativePositionTopTrailing) {
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:anchorView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:parentView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:posY];
        
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:parentView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:anchorView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:posX];
        
        [top setActive:YES];
        [trailing setActive:YES];
        
        [parentView addConstraints:@[top, trailing]];
    } else if (relativeType == FLOPopoverRelativePositionBottomLeading) {
        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:anchorView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:posX];
        
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:parentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:anchorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:posY];
        
        [leading setActive:YES];
        [bottom setActive:YES];
        
        [parentView addConstraints:@[leading, bottom]];
    } else {
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:parentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:anchorView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:posY];
        
        NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:parentView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:anchorView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:posX];
        
        [bottom setActive:YES];
        [trailing setActive:YES];
        
        [parentView addConstraints:@[bottom, trailing]];
    }
    
    CGFloat anchorViewWidth = 1.0;
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:anchorView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1
                                                              constant:anchorViewWidth];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:anchorView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1
                                                               constant:anchorViewWidth];
    
    [width setActive:YES];
    [height setActive:YES];
    
    [anchorView addConstraints:@[width, height]];
    [anchorView setHidden:NO];
    
    return anchorView;
}

- (void)anchorView:(NSView *)anchorView shouldUpdate:(BOOL)shouldUpdate position:(NSPoint)position inParent:(NSView *)parentView {
    if (shouldUpdate && (anchorView != nil) && [anchorView isDescendantOf:parentView]) {
        CGFloat posX = position.x;
        CGFloat posY = position.y;
        
        for (NSLayoutConstraint *constraint in parentView.constraints) {
            if ((constraint.firstItem == anchorView) || (constraint.secondItem == anchorView)) {
                if (constraint.isActive && ((constraint.firstAttribute == NSLayoutAttributeLeading) || (constraint.firstAttribute == NSLayoutAttributeTrailing))) {
                    constraint.constant = posX;
                }
                
                if (constraint.isActive && ((constraint.firstAttribute == NSLayoutAttributeTop) || (constraint.firstAttribute == NSLayoutAttributeBottom))) {
                    constraint.constant = posY;
                }
            }
        }
        
        [parentView setNeedsUpdateConstraints:YES];
        [parentView updateConstraints];
        [parentView updateConstraintsForSubtreeIfNeeded];
        [parentView layoutSubtreeIfNeeded];
    }
}

- (void)validateAnchorView:(NSView *)anchorView position:(NSPoint)position inParent:(NSView *)parentView withPositioningRect:(NSRect)positioningRect {
    BOOL shouldUpdate = NO;
    
    CGFloat posX = position.x;
    CGFloat posY = position.y;
    
    if ((anchorView != nil) && [anchorView isDescendantOf:parentView]) {
        NSRect anchorViewFrame = [anchorView.window convertRectToScreen:[anchorView convertRect:anchorView.bounds toView:anchorView.window.contentView]];
        
        if ((anchorViewFrame.origin.x != positioningRect.origin.x) || (anchorViewFrame.origin.y != NSMaxY(positioningRect))) {
            shouldUpdate = YES;
            
            if (anchorViewFrame.origin.x != positioningRect.origin.x) {
                posX += anchorViewFrame.origin.x - positioningRect.origin.x;
            }
            
            if (anchorViewFrame.origin.y != NSMaxY(positioningRect)) {
                posY += anchorViewFrame.origin.y - NSMaxY(positioningRect);
            }
        }
    }
    
    if (shouldUpdate) {
        [self anchorView:anchorView shouldUpdate:shouldUpdate position:NSMakePoint(posX, posY) inParent:parentView];
    }
}

- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition {
    NSDictionary *relativePositionValues = [self relativePositionValuesForView:positioningView rect:positioningRect];
    FLOPopoverRelativePositionType relativeType = [[relativePositionValues objectForKey:@"type"] integerValue];
    NSPoint relativePosition = [[relativePositionValues objectForKey:@"position"] pointValue];
    
    if (self.positioningAnchorView == nil) {
        self.positioningAnchorView = [self anchorViewWithRelativePosition:relativePosition type:relativeType parent:positioningView];
        
        [positioningView setNeedsUpdateConstraints:YES];
        [positioningView updateConstraints];
        [positioningView updateConstraintsForSubtreeIfNeeded];
        [positioningView layoutSubtreeIfNeeded];
    }
    
    if (shouldUpdatePosition) {
        [self anchorView:self.positioningAnchorView shouldUpdate:shouldUpdatePosition position:relativePosition inParent:positioningView];
    }
    
    [self validateAnchorView:self.positioningAnchorView position:relativePosition inParent:positioningView withPositioningRect:positioningRect];
    
    [self.positioningAnchorView setHidden:NO];
}

#pragma mark - Normal display utilities

- (NSRect)popoverFrameForEdge:(NSRectEdge)popoverEdge {
    NSRect positionRelativeFrame = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:self.positioningFrame] toView:nil];
    NSRect positionScreenFrame = [self.positioningAnchorView.window convertRectToScreen:positionRelativeFrame];
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSPoint anchorPoint = self.anchorPoint;
    
    NSSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    NSRect frame = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
    
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
        CGFloat x0 = NSMinX(positionScreenFrame);
        CGFloat x1 = NSMaxX(positionScreenFrame) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMinY(positionScreenFrame) - popoverSize.height;
    } else if (popoverEdge == NSRectEdgeMaxY) {
        CGFloat x0 = NSMinX(positionScreenFrame);
        CGFloat x1 = NSMaxX(positionScreenFrame) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMaxY(positionScreenFrame);
    } else if (popoverEdge == NSRectEdgeMinX) {
        CGFloat y0 = NSMinY(positionScreenFrame);
        CGFloat y1 = NSMaxY(positionScreenFrame) - contentViewSize.height;
        
        frame.origin.x = NSMinX(positionScreenFrame) - popoverSize.width;
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else if (popoverEdge == NSRectEdgeMaxX) {
        CGFloat y0 = NSMinY(positionScreenFrame);
        CGFloat y1 = NSMaxY(positionScreenFrame) - contentViewSize.height;
        
        frame.origin.x = NSMaxX(positionScreenFrame);
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else {
        frame = NSZeroRect;
    }
    
    return frame;
}

- (BOOL)checkPopoverFrameWithEdge:(NSRectEdge)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect frame = [self popoverFrameForEdge:popoverEdge];
    
    return NSContainsRect(containerFrame, frame);
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

- (NSRect)fitFrameToContainer:(NSRect)proposedFrame {
    NSRect containerFrame = [self containerFrame];
    
    if (proposedFrame.origin.y < NSMinY(containerFrame)) {
        proposedFrame.origin.y = NSMinY(containerFrame);
    }
    if (proposedFrame.origin.x < NSMinX(containerFrame)) {
        proposedFrame.origin.x = NSMinX(containerFrame);
    }
    
    if (NSMaxY(proposedFrame) > NSMaxY(containerFrame)) {
        proposedFrame.origin.y = NSMaxY(containerFrame) - NSHeight(proposedFrame);
    }
    if (NSMaxX(proposedFrame) > NSMaxX(containerFrame)) {
        proposedFrame.origin.x = NSMaxX(containerFrame) - NSWidth(proposedFrame);
    }
    
    return proposedFrame;
}

- (BOOL)containerFrameContainsEdge:(NSRectEdge)edge {
    NSRect frame = [self popoverFrameForEdge:edge];
    NSRect containerFrame = [self containerFrame];
    
    BOOL minYInBounds = (edge == NSRectEdgeMinY) && (NSMinY(frame) >= NSMinY(containerFrame));
    BOOL maxYInBounds = (edge == NSRectEdgeMaxY) && (NSMaxY(frame) <= NSMaxY(containerFrame));
    BOOL minXInBounds = (edge == NSRectEdgeMinX) && (NSMinX(frame) >= NSMinX(containerFrame));
    BOOL maxXInBounds = (edge == NSRectEdgeMaxX) && (NSMaxX(frame) <= NSMaxX(containerFrame));
    
    return minYInBounds || maxYInBounds || minXInBounds || maxXInBounds;
}

- (NSRect)popoverFrame {
    NSRectEdge popoverEdge = self.preferredEdge;
    
    while (![self checkPopoverFrameWithEdge:popoverEdge]) {
        popoverEdge = [self containerFrameContainsEdge:self.preferredEdge] ? self.preferredEdge : [self nextEdgeForEdge:self.preferredEdge];
        
        return [self fitFrameToContainer:[self popoverFrameForEdge:popoverEdge]];
    }
    
    return [self popoverFrameForEdge:popoverEdge];
}

#pragma mark - Saving edge utilities

- (NSRect)p_popoverFrameForEdge:(NSRectEdge *)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect positionRelativeFrame = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:self.positioningFrame] toView:nil];
    NSRect positionScreenFrame = [self.positioningAnchorView.window convertRectToScreen:positionRelativeFrame];
    
    self.backgroundView.popoverOrigin = positionScreenFrame;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSPoint anchorPoint = self.anchorPoint;
    
    NSSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:*popoverEdge];
    NSRect frame = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
    
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
    if (*popoverEdge == NSRectEdgeMinY) {
        CGFloat x0 = NSMinX(positionScreenFrame);
        CGFloat x1 = NSMaxX(positionScreenFrame) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMinY(positionScreenFrame) - popoverSize.height;
        
        if (NSMaxY(frame) < NSMinY(containerFrame)) {
            *popoverEdge = NSRectEdgeMaxY;
            
            return [self p_popoverFrameForEdge:popoverEdge];
        }
    } else if (*popoverEdge == NSRectEdgeMaxY) {
        CGFloat x0 = NSMinX(positionScreenFrame);
        CGFloat x1 = NSMaxX(positionScreenFrame) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMaxY(positionScreenFrame);
        
        if (NSMinY(frame) > NSMaxY(containerFrame)) {
            *popoverEdge = NSRectEdgeMinY;
            
            return [self p_popoverFrameForEdge:popoverEdge];
        }
    } else if (*popoverEdge == NSRectEdgeMinX) {
        CGFloat y0 = NSMinY(positionScreenFrame);
        CGFloat y1 = NSMaxY(positionScreenFrame) - contentViewSize.height;
        
        frame.origin.x = NSMinX(positionScreenFrame) - popoverSize.width;
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
        
        if (NSMaxX(frame) < NSMinX(containerFrame)) {
            *popoverEdge = NSRectEdgeMaxX;
            
            return [self p_popoverFrameForEdge:popoverEdge];
        }
    } else if (*popoverEdge == NSRectEdgeMaxX) {
        CGFloat y0 = NSMinY(positionScreenFrame);
        CGFloat y1 = NSMaxY(positionScreenFrame) - contentViewSize.height;
        
        frame.origin.x = NSMaxX(positionScreenFrame);
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
        
        if (NSMinX(frame) > NSMaxX(containerFrame)) {
            *popoverEdge = NSRectEdgeMinX;
            
            return [self p_popoverFrameForEdge:popoverEdge];
        }
    } else {
        frame = NSZeroRect;
    }
    
    return frame;
}

- (BOOL)p_checkPopoverFrameWithEdge:(NSRectEdge *)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect frame = [self p_popoverFrameForEdge:popoverEdge];
    
    return NSContainsRect(containerFrame, frame);
}

- (NSRectEdge)p_nextEdgeForEdge:(NSRectEdge)currentEdge {
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

- (NSRect)p_fitFrameToContainer:(NSRect)proposedFrame {
    NSRect containerFrame = [self containerFrame];
    
    if (proposedFrame.origin.y < NSMinY(containerFrame)) {
        proposedFrame.origin.y = NSMinY(containerFrame);
    }
    
    if (proposedFrame.origin.x < NSMinX(containerFrame)) {
        proposedFrame.origin.x = NSMinX(containerFrame);
    }
    
    if (NSMaxY(proposedFrame) > NSMaxY(containerFrame)) {
        proposedFrame.origin.y = NSMaxY(containerFrame) - NSHeight(proposedFrame);
    }
    
    if (NSMaxX(proposedFrame) > NSMaxX(containerFrame)) {
        proposedFrame.origin.x = NSMaxX(containerFrame) - NSWidth(proposedFrame);
    }
    
    return proposedFrame;
}

- (BOOL)p_containerFrameContainsEdge:(NSRectEdge)edge {
    NSRect frame = [self p_popoverFrameForEdge:&edge];
    NSRect containerFrame = [self containerFrame];
    
    BOOL minYInBounds = (edge == NSRectEdgeMinY) && (NSMinY(frame) >= NSMinY(containerFrame));
    BOOL maxYInBounds = (edge == NSRectEdgeMaxY) && (NSMaxY(frame) <= NSMaxY(containerFrame));
    BOOL minXInBounds = (edge == NSRectEdgeMinX) && (NSMinX(frame) >= NSMinX(containerFrame));
    BOOL maxXInBounds = (edge == NSRectEdgeMaxX) && (NSMaxX(frame) <= NSMaxX(containerFrame));
    
    return minYInBounds || maxYInBounds || minXInBounds || maxXInBounds;
}

- (NSRect)p_popoverFrame {
    NSRectEdge popoverEdge = self.preferredEdge;
    
    while (![self p_checkPopoverFrameWithEdge:&popoverEdge]) {
        popoverEdge = [self p_containerFrameContainsEdge:self.preferredEdge] ? self.preferredEdge : [self p_nextEdgeForEdge:self.preferredEdge];
        
        NSRect frame = [self p_fitFrameToContainer:[self p_popoverFrameForEdge:&popoverEdge]];
        
        if (self.preferredEdge != popoverEdge) {
            self.preferredEdge = popoverEdge;
            self.originalViewSize = frame.size;
        }
        
        return frame;
    }
    
    NSRect frame = [self p_popoverFrameForEdge:&popoverEdge];
    
    if (self.preferredEdge != popoverEdge) {
        self.preferredEdge = popoverEdge;
        self.originalViewSize = frame.size;
    }
    
    return frame;
}

- (void)p_backgroundViewShouldUpdate:(BOOL)updated {
    if (updated) {
        NSRectEdge popoverEdge = self.preferredEdge;
        CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentView.frame.size popoverEdge:popoverEdge];
        self.backgroundView.frame = (NSRect){ .size = size };
        self.backgroundView.popoverEdge = popoverEdge;
        self.backgroundView.needsDisplay = YES;
        
        NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
        self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
        self.contentView.frame = contentViewFrame;
    }
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
