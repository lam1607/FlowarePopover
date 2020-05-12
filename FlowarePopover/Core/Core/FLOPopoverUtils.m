//
//  FLOPopoverUtils.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopoverUtils.h"

#import "FLOPopoverProtocols.h"

#import "FLOPopoverView.h"
#import "FLOPopoverWindow.h"
#import "FLOVirtualView.h"


@interface FLOPopoverUtils () {
    __weak id<FLOPopoverProtocols> _popover;
    
    NSRectEdge _preferredEdge;
    NSRectEdge _originalEdge;
    CGPoint _anchorPoint;
    NSRect _positionFrame;
    CGFloat _verticallyAvailableMargin;
    
    BOOL _showsWithVisualEffect;
    NSVisualEffectMaterial _arrowVisualEffectMaterial;
    NSVisualEffectBlendingMode _arrowVisualEffectBlendingMode;
    NSVisualEffectState _arrowVisualEffectState;
    
    BOOL _windowLiveResizeReceived;
    BOOL _scrollingEventReceived;
    BOOL _superviewObserversRegistered;
    
    NSTimer *_closeTimer;
    
    FLOVirtualView *_disableView;
    
    NSMutableArray<NSView *> *_observerSuperviews;
    NSMutableArray<NSClipView *> *_observerClipViews;
    NSMutableArray<NSClipView *> *_registeredViewBoundsObservers;
    NSMutableArray<NSView *> *_registeredSuperviewObservers;
    NSMutableArray<NSView *> *_registeredFrameObservers;
    NSMutableDictionary *_observerClipViewFrames;
    NSMutableDictionary *_observerClipViewStates;
}

@property (nonatomic, strong, readwrite) NSWindow *mainWindow;

@end

@implementation FLOPopoverUtils

@synthesize mainWindow = _mainWindow;
@synthesize presentedWindow = _presentedWindow;

#pragma mark - Initialize

- (instancetype)initWithPopover:(id<FLOPopoverProtocols>)popover {
    if (self = [super init]) {
        _mainWindow = [[[NSApplication sharedApplication] windows] firstObject];
        
        _popover = popover;
        
        _userInteractionEnable = YES;
        _popoverStyle = FLOPopoverStyleNormal;
        
        _showsWithVisualEffect = NO;
        _arrowVisualEffectMaterial = NSVisualEffectMaterialLight;
        _arrowVisualEffectBlendingMode = NSVisualEffectBlendingModeBehindWindow;
        _arrowVisualEffectState = NSVisualEffectStateInactive;
        
        _animatedInAppFrame = NO;
        _popoverMoved = NO;
        _animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        _animationType = FLOPopoverAnimationDefault;
        _relativePositionType = FLOPopoverRelativePositionAutomatic;
        _anchorPoint = NSMakePoint(0.0, 0.0);
        
        _windowLiveResizeReceived = NO;
        _scrollingEventReceived = NO;
        _superviewObserversRegistered = NO;
    }
    
    return self;
}

- (void)dealloc {
    _mainWindow = nil;
    
    self.contentViewController = nil;
    
    if ([self.contentView superview] != nil) {
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

- (NSWindow *)mainWindow {
    return _mainWindow;
}

- (BOOL)isCloseEventReceived {
    return (_closeTimer != nil);
}

- (void)setPresentedWindow:(NSWindow *)presentedWindow {
    _presentedWindow = presentedWindow;
}

- (NSWindow *)presentedWindow {
    return ((_presentedWindow != nil) ? _presentedWindow : [self.positioningView window]);
}

- (void)setObserverFrame:(NSRect)frame forView:(NSClipView *)observerView {
    if (![observerView isKindOfClass:[NSClipView class]]) return;
    if (![_observerClipViews containsObject:observerView]) return;
    
    @synchronized (_observerClipViewFrames) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        [_observerClipViewFrames setObject:@(frame) forKey:key];
    }
}

- (NSRect)observerFrameForView:(NSClipView *)observerView {
    if (![observerView isKindOfClass:[NSClipView class]]) return NSZeroRect;
    if (![_observerClipViews containsObject:observerView]) return NSZeroRect;
    
    @synchronized (_observerClipViewFrames) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        if ([[_observerClipViewFrames objectForKey:key] isKindOfClass:[NSValue class]]) {
            return [[_observerClipViewFrames objectForKey:key] rectValue];
        }
        
        return NSZeroRect;
    }
}

- (void)setObserverState:(BOOL)belongsToScrollView forView:(NSClipView *)observerView {
    if (![observerView isKindOfClass:[NSClipView class]]) return;
    if (![_observerClipViews containsObject:observerView]) return;
    
    @synchronized (_observerClipViewStates) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        [_observerClipViewStates setObject:@(belongsToScrollView) forKey:key];
    }
}

- (BOOL)observerStateForView:(NSClipView *)observerView {
    if (![observerView isKindOfClass:[NSClipView class]]) return NO;
    if (![_observerClipViews containsObject:observerView]) return NO;
    
    @synchronized (_observerClipViewStates) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        if ([[_observerClipViewStates objectForKey:key] isKindOfClass:[NSNumber class]]) {
            return [[_observerClipViewStates objectForKey:key] boolValue];
        }
        
        return NO;
    }
}

#pragma mark - Local methods

- (NSRect)containerFrame {
    if (_popover.staysInContainer) {
        NSRect closestClipViewFrame = [self closestClipViewFrame];
        
        if (!NSEqualRects(closestClipViewFrame, NSZeroRect)) {
            return closestClipViewFrame;
        } else {
            NSDictionary *dictionary = [self closestClipViewContainsSize];
            
            if (dictionary != nil) {
                return [self observerFrameForView:[dictionary objectForKey:@"observerView"]];
            }
        }
        
        return [self.mainWindow frame];
    }
    
    return [[self.mainWindow screen] visibleFrame];
}

- (void)resetScrollingEventReceived {
    _scrollingEventReceived = NO;
}

- (NSRect)popoverOrigin {
    NSRect positionRelativeFrame = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:((_observerClipViews.count > 0) ? [self.positioningAnchorView visibleRect] : self.positioningFrame)] toView:nil];
    NSRect popoverOrigin = [[self.positioningAnchorView window] convertRectToScreen:positionRelativeFrame];
    
    return popoverOrigin;
}

- (void)updatePositionFrame {
    _positionFrame = [self.positioningView convertRect:[self.positioningView bounds] toView:[self.presentedWindow contentView]];
}

- (NSRect)positionFrame {
    return [self.positioningView convertRect:[self.positioningView bounds] toView:[self.presentedWindow contentView]];
}

- (NSRect)positionScreenFrame {
    NSRect frame = (_observerClipViews.count > 0) ? [self.positioningView visibleRect] : [self.positioningView bounds];
    
    if (!NSEqualRects(frame, NSZeroRect)) {
        NSRect positionRelativeFrame = [self.positioningView convertRect:frame toView:[self.presentedWindow contentView]];
        
        frame = [self.presentedWindow convertRectToScreen:positionRelativeFrame];
    }
    
    return frame;
}

- (void)registerObserverView:(NSView *)view selector:(SEL)selector source:(id)source {
    if ([source respondsToSelector:selector]) {
        if ([view isKindOfClass:[NSClipView class]]) {
            if (_popover.shouldRegisterSuperviewObservers) {
                [view setPostsBoundsChangedNotifications:YES];
                
                [[NSNotificationCenter defaultCenter] addObserver:source
                                                         selector:selector
                                                             name:NSViewBoundsDidChangeNotification
                                                           object:view];
                
                if (![_registeredViewBoundsObservers containsObject:(NSClipView *)view]) {
                    [_registeredViewBoundsObservers addObject:(NSClipView *)view];
                }
            }
        } else {
            [view addObserver:source forKeyPath:@"superview" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
            
            if (![_registeredSuperviewObservers containsObject:view]) {
                [_registeredSuperviewObservers addObject:view];
            }
            
            if (_popover.shouldRegisterSuperviewObservers) {
                [view addObserver:source forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
                
                if (![_registeredFrameObservers containsObject:view]) {
                    [_registeredFrameObservers addObject:view];
                }
            }
        }
    }
}

- (void)setupObserverClipViewValues {
    if (_popover == nil) return;
    
    NSRect popoverFrame = _popover.frame;
    
    for (NSClipView *observerView in _observerClipViews) {
        NSRect observerViewFrame = [observerView.window convertRectToScreen:[observerView convertRect:observerView.visibleRect toView:[observerView.window contentView]]];
        
        [self setObserverFrame:observerViewFrame forView:observerView];
        [self setObserverState:NSContainsRect(observerViewFrame, popoverFrame) forView:observerView];
    }
}

- (void)registerObserverForClipViews {
    if (_popover == nil) return;
    
    _observerClipViews = [[NSMutableArray alloc] init];
    _observerClipViewFrames = [[NSMutableDictionary alloc] init];
    _observerClipViewStates = [[NSMutableDictionary alloc] init];
    
    for (NSView *observerView in _observerSuperviews) {
        if ([observerView isKindOfClass:[NSClipView class]] && ![_observerClipViews containsObject:(NSClipView *)observerView]) {
            [_observerClipViews addObject:(NSClipView *)observerView];
        }
    }
    
    [self setupObserverClipViewValues];
}

- (NSRect)closestClipViewFrame {
    NSRect frame = NSZeroRect;
    
    for (NSClipView *observerView in _observerClipViews) {
        BOOL belongsToScrollView = [self observerStateForView:observerView];
        
        if (belongsToScrollView) {
            frame = [self observerFrameForView:observerView];
            break;
        }
    }
    
    return frame;
}

- (NSDictionary *)closestClipViewContainsSize {
    NSSize size = NSZeroSize;
    NSSize popoverSize = _popover.frame.size;
    
    if (NSEqualSizes(popoverSize, NSZeroSize)) return nil;
    
    NSClipView *clipView = nil;
    
    for (NSClipView *observerView in _observerClipViews) {
        size = [self observerFrameForView:observerView].size;
        
        if (NSContainsRect((NSRect){ .size = size }, (NSRect){ .size = popoverSize })) {
            clipView = observerView;
            
            break;
        } else {
            size = NSZeroSize;
        }
    }
    
    return ((clipView != nil) && !NSEqualSizes(size, NSZeroSize)) ? @{@"observerView": clipView, @"size": @(size)} : nil;
}

- (BOOL)popoverShouldCloseForChangedView:(NSView *)changedView {
    if (![changedView.window isVisible]) return YES;
    
    if ([_observerSuperviews containsObject:changedView]) {
        if ((changedView != self.positioningAnchorView) && ![self.positioningAnchorView isDescendantOf:changedView]) {
            return YES;
        }
        
        NSInteger index = [_observerSuperviews indexOfObject:changedView];
        
        if (index < (_observerSuperviews.count - 1)) {
            NSView *observerSuperview = [_observerSuperviews objectAtIndex:(index + 1)];
            NSView *changingSuperview = [changedView superview];
            
            if (observerSuperview != changingSuperview) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSRect)popoverFrameWithResizingWindow:(NSWindow *)resizedWindow {
    if (_popover == nil) return NSZeroRect;
    
    NSRect popoverFrame = [self popoverFrame];
    
    if (_popover.type == FLOViewPopover) {
        popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
    }
    
    CGFloat popoverOriginX = popoverFrame.origin.x;
    CGFloat popoverOriginY = popoverFrame.origin.y;
    
    if (_popover.shouldChangeSizeWhenApplicationResizes) {
        CGFloat newHeight = resizedWindow.contentView.visibleRect.size.height - _verticallyAvailableMargin;
        CGFloat deltaHeight = popoverFrame.size.height - newHeight;
        CGFloat popoverHeight = newHeight;
        
        popoverOriginY = popoverFrame.origin.y + deltaHeight;
        
        popoverFrame = NSMakeRect(popoverOriginX, popoverOriginY, popoverFrame.size.width, popoverHeight);
    } else {
        popoverFrame = NSMakeRect(popoverOriginX, popoverOriginY, self.originalViewSize.width, self.originalViewSize.height);
    }
    
    return popoverFrame;
}

- (void)updateFrameWhileScrolling:(BOOL)isScrolling container:(NSView *)container {
    if (_popover == nil) return;
    
    NSRect positionScreenFrame = [self positionScreenFrame];
    NSRectEdge preferredEdge = _preferredEdge;
    
    /// Get the popover frame, maybe the _preferredEdge will be changed
    /// when calculates new frame of popover.
    NSRect popoverFrame = [self popoverFrame];
    
    /// Update arrow path (hidden or not) if the popover contains arrow
    /// as configured when displayed.
    if (_popover.containsArrow) {
        // Should [invalidateShadow] before set arrow hidden or visible.
        [_popover invalidateShadow];
        
        /// If the positioningView (the sender where arrow is displayed at)
        /// move out of containerFrame, we should hide the arrow of popover.
        if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
            [self.backgroundView setArrow:NO];
        } else {
            /// If the positioningView (the sender where arrow is displayed at) move inside
            /// of containerFrame, we should show the arrow of popover.
            /// And also update the arrow position respectively to the new popoverOrigin
            [self.backgroundView setPopoverOrigin:[self popoverOrigin]];
            
            if (preferredEdge == _preferredEdge) {
                [self.backgroundView setArrow:YES];
            } else {
                [self updateBackgroundView:YES redrawn:YES];
                
                /// Must update the popover frame here in case of changing the preferredEdge
                /// to update the popover size and arrow origin correctly
                self.originalViewSize = self.backgroundView.frame.size;
                
                popoverFrame = [self popoverFrame];
            }
        }
    }
    
    BOOL closeIfNeeded = NO;
    
    /// Stop the popover when it (or the position view) reach the container bounds.
    NSRect closestClipViewFrame = [self closestClipViewFrame];
    BOOL isNotContained = NSEqualRects(positionScreenFrame, NSZeroRect);
    
    if (!isNotContained) {
        if (_popover.staysInContainer || _popover.closesWhenNotBelongToContainer) {
            if (NSEqualRects(closestClipViewFrame, NSZeroRect)) {
                isNotContained = !NSContainsRect((_popover.staysInContainer ? self.mainWindow.frame : self.mainWindow.screen.visibleFrame), popoverFrame);
            } else {
                isNotContained = !NSContainsRect(closestClipViewFrame, popoverFrame);
            }
        } else {
            isNotContained = !NSContainsRect((_popover.staysInContainer ? self.mainWindow.frame : self.mainWindow.screen.visibleFrame), popoverFrame);
        }
    }
    
    closeIfNeeded = (_popover.closesWhenNotBelongToContainer && isNotContained);
    
    if (!closeIfNeeded && _popover.stopsAtContainerBounds && isNotContained) return;
    
    /// Close the popover if closesWhenNotBelongToContainer is set as YES.
    if (closeIfNeeded && _popover.closesWhenNotBelongToContainer) {
        [_popover close];
        
        return;
    }
    
    /// Update
    if (_popover.type == FLOViewPopover) {
        popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
    }
    
    [_popover updateFrame:popoverFrame];
    
    [self updatePositionFrame];
    [self setupObserverClipViewValues];
}

- (void)updateContentSizeForPopover {
    if (_popover == nil) return;
    
    if (!_popover.containsArrow) {
        // Should update the contentSize when popover frame's size changed.
        self.contentSize = _popover.frame.size;
        
        if (_popover.type == FLOWindowPopover) {
            CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentSize popoverEdge:_preferredEdge];
            
            [self.backgroundView setFrame:(NSRect){ .size = size }];
        }
        
        [self.contentView setFrame:[self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:_preferredEdge]];
    }
}

- (void)invalidateCloseTimer {
    if (_closeTimer) {
        [_closeTimer invalidate];
        
        _closeTimer = nil;
    }
}

#pragma mark - Utilities

- (NSMutableArray<NSClipView *> *)observerClipViews {
    return _observerClipViews;
}

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
    if (showing || (!showing && forwarding)) {
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

- (BOOL)treeOfView:(NSView *)view containsPosition:(NSPoint)position {
    NSRect relativeRect = [view convertRect:[view alignmentRectForFrame:[view bounds]] toView:nil];
    NSRect viewRect = [view.window convertRectToScreen:relativeRect];
    
    if (NSPointInRect(position, viewRect)) {
        return YES;
    } else {
        for (NSView *item in [view subviews]) {
            if ([self treeOfView:item containsPosition:position]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)view:(NSView *)parent contains:(NSView *)child {
    return [self views:[parent subviews] contain:child];
}

- (BOOL)views:(NSArray *)views contain:(NSView *)view {
    if ([views containsObject:view]) {
        return YES;
    } else {
        for (NSView *item in views) {
            if ([self views:[item subviews] contain:view]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)window:(NSWindow *)parent contains:(NSWindow *)child {
    return [self windows:[parent childWindows] contain:child];
}

- (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window {
    if ([windows containsObject:window]) {
        return YES;
    } else {
        for (NSWindow *item in windows) {
            if ([self windows:[item childWindows] contain:window]) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (NSVisualEffectView *)contentViewDidContainVisualEffect {
    for (NSView *view in [self.contentView subviews]) {
        if ([view isKindOfClass:[NSVisualEffectView class]]) {
            return (NSVisualEffectView *)view;
        }
    }
    
    return nil;
}

- (void)addView:(NSView *)view toParent:(NSView *)parentView {
    if ((view == nil) || (parentView == nil)) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
        [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    }
}

- (void)addView:(NSView *)view toParent:(NSView *)parentView autoresizingMask:(BOOL)isAutoresizingMask {
    if ((view == nil) || (parentView == nil)) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
        [view setTranslatesAutoresizingMaskIntoConstraints:YES];
    }
    
    if (isAutoresizingMask && [view isDescendantOf:parentView]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(view)]];
        
        [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(view)]];
        
        [parentView layoutSubtreeIfNeeded];
    }
}

- (void)addView:(NSView *)view toParent:(NSView *)parentView centerAutoresizingMask:(BOOL)isCenterAutoresizingMask {
    if ((view == nil) || (parentView == nil)) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
    }
    
    if (isCenterAutoresizingMask && [view isDescendantOf:parentView]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:parentView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:0
                                                                  toItem:view
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
        
        [parentView addConstraint:[NSLayoutConstraint constraintWithItem:parentView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:0
                                                                  toItem:view
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
        
        NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:view
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:CGRectGetWidth(view.frame)];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:CGRectGetHeight(view.frame)];
        
        [width setActive:YES];
        [height setActive:YES];
        
        [view addConstraints:@[width, height]];
        
        [parentView layoutSubtreeIfNeeded];
    }
}

- (void)setupAutoresizingMaskIfNeeded:(BOOL)needed {
    if (self.needsAutoresizingMask) {
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self.backgroundView setTranslatesAutoresizingMaskIntoConstraints:YES];
        
        if (needed) {
            [self.contentView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
            [self.backgroundView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin)];
        } else {
            [self.contentView setAutoresizingMask:NSViewNotSizable];
            [self.backgroundView setAutoresizingMask:NSViewNotSizable];
        }
    }
}

- (void)closePopoverWithTimerIfNeeded {
    if (_popover == nil) return;
    
    if (_popover.isShowing) {
        if (_closeTimer == nil) {
            _closeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                           target:self
                                                         selector:@selector(closePopoverWithTimerIfNeeded) userInfo:nil repeats:YES];
        }
    } else {
        [self invalidateCloseTimer];
        [_popover close];
    }
}

- (void)invalidateArrowPathColor {
    if (_popover == nil) return;
    
    if (_popover.containsArrow) {
        [self.backgroundView setArrowColor:[[self.contentView layer] backgroundColor]];
    }
}

#pragma mark - Display utilities

- (void)setResponder {
    if (_popover == nil) return;
    
    NSResponder *representedObject = _popover.representedObject;
    
    if ([representedObject isKindOfClass:[FLOPopoverView class]]) {
        [(FLOPopoverView *)representedObject setResponder:_popover];
    } else if ([representedObject isKindOfClass:[FLOPopoverWindow class]]) {
        [(FLOPopoverWindow *)representedObject setResponder:_popover];
    } else {
    }
    
    [self.backgroundView setResponder:_popover];
}

- (void)setupComponentsForPopover:(BOOL)observerNeeded {
    if (_popover == nil) return;
    
    if (NSEqualRects(self.positioningFrame, NSZeroRect)) {
        self.positioningFrame = [self.positioningAnchorView visibleRect];
    }
    
    [self.backgroundView setPopoverOrigin:[self popoverOrigin]];
    self.originalViewSize = NSEqualSizes(self.originalViewSize, NSZeroSize) ? self.contentView.frame.size : self.originalViewSize;
    self.contentSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.contentView.frame.size : self.contentSize;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSRectEdge popoverEdge = _preferredEdge;
    
    [self.backgroundView setBorderRadius:([self.contentView layer] ? [[self.contentView layer] cornerRadius] : kFlowarePopover_BorderRadius)];
    [self.backgroundView setMovable:_popover.isMovable];
    [self.backgroundView setDetachable:_popover.isDetachable];
    
    if (_popover.shouldShowArrow && (self.positioningView == self.positioningAnchorView)) {
        self.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.animationType = FLOPopoverAnimationDefault;
        
        [self.backgroundView setArrowSize:_popover.arrowSize];
        [self.backgroundView setArrow:_popover.shouldShowArrow];
        [self.backgroundView setArrowColor:[[self.contentView layer] backgroundColor]];
        
        if (_showsWithVisualEffect) {
            [self.backgroundView setVisualEffect:_showsWithVisualEffect material:_arrowVisualEffectMaterial blendingMode:_arrowVisualEffectBlendingMode state:_arrowVisualEffectState];
        }
    } else {
        [_popover setArrowSize:NSZeroSize];
    }
    
    [self.backgroundView setShadow:(_popover.type == FLOViewPopover)];
    
    if (_popover.isMovable || _popover.isDetachable) {
        self.backgroundView.delegate = (id<FLOPopoverViewDelegate>)_popover;
    }
    
    CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    
    [self.backgroundView setFrame:(NSRect){ .size = size }];
    [self.backgroundView setPopoverEdge:popoverEdge];
    
    NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:[self.backgroundView bounds] popoverEdge:popoverEdge];
    [self.contentView setFrame:contentViewFrame];
    
    NSRect popoverFrame = [self popoverFrame];
    
    if (_popover.type == FLOViewPopover) {
        popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
    }
    
    // Update arrow edge and content view frame
    if (_popover.shouldShowArrow && (self.positioningView == self.positioningAnchorView)) {
        [self.backgroundView setAlphaValue:1.0];
        [self updateBackgroundView:YES redrawn:YES];
    }
    
    self.originalViewSize = self.backgroundView.frame.size;
    
    [_popover setInitialFrame:popoverFrame];
    [_popover updateFrame:popoverFrame];
    // Should [invalidateShadow] here in case of calling this [setupComponentsForPopover:] method
    // from [updatePopoverFrame]
    [_popover invalidateShadow];
    
    _verticallyAvailableMargin = [[self.mainWindow contentView] visibleRect].size.height + _popover.bottomOffset - NSMaxY([self.mainWindow convertRectFromScreen:popoverFrame]);
    
    [self updatePositionFrame];
    
    if (observerNeeded) {
        [self registerObserverForClipViews];
    }
}

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType {
    switch (edgeType) {
        case FLOPopoverEdgeTypeAboveLeftEdge:
            _preferredEdge = NSRectEdgeMaxY;
            _anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeAboveRightEdge:
            _preferredEdge = NSRectEdgeMaxY;
            _anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeBelowLeftEdge:
            _preferredEdge = NSRectEdgeMinY;
            _anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeBelowRightEdge:
            _preferredEdge = NSRectEdgeMinY;
            _anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeBackwardBottomEdge:
            _preferredEdge = NSRectEdgeMinX;
            _anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeBackwardTopEdge:
            _preferredEdge = NSRectEdgeMinX;
            _anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeForwardBottomEdge:
            _preferredEdge = NSRectEdgeMaxX;
            _anchorPoint = NSMakePoint(0.0, 0.0);
            break;
        case FLOPopoverEdgeTypeForwardTopEdge:
            _preferredEdge = NSRectEdgeMaxX;
            _anchorPoint = NSMakePoint(1.0, 1.0);
            break;
        case FLOPopoverEdgeTypeAboveCenter:
            _preferredEdge = NSRectEdgeMaxY;
            _anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeBelowCenter:
            _preferredEdge = NSRectEdgeMinY;
            _anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeBackwardCenter:
            _preferredEdge = NSRectEdgeMinX;
            _anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        case FLOPopoverEdgeTypeForwardCenter:
            _preferredEdge = NSRectEdgeMaxX;
            _anchorPoint = NSMakePoint(0.5, 0.5);
            break;
        default:
            _preferredEdge = NSRectEdgeMinY;
            _anchorPoint = NSMakePoint(1.0, 1.0);
            break;
    }
    
    _originalEdge = _preferredEdge;
}

- (void)setUserInteractionEnable:(BOOL)isEnable {
    _userInteractionEnable = isEnable;
    
    self.backgroundView.userInteractionEnable = isEnable;
    
    if (isEnable) {
        if ([_disableView isDescendantOf:self.backgroundView]) {
            [_disableView removeFromSuperview];
            _disableView = nil;
        }
    } else {
        FLOVirtualView *disableView = _disableView;
        
        if (disableView == nil) {
            disableView = [[FLOVirtualView alloc] initWithFrame:self.backgroundView.frame type:FLOVirtualViewDisable];
        }
        
        if (![disableView isDescendantOf:self.backgroundView]) {
            [self.backgroundView addSubview:disableView];
            
            [disableView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[disableView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:NSDictionaryOfVariableBindings(disableView)]];
            
            [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[disableView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:NSDictionaryOfVariableBindings(disableView)]];
            
            _disableView = disableView;
        }
    }
}

- (void)showWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    _showsWithVisualEffect = needed;
    _arrowVisualEffectMaterial = material;
    _arrowVisualEffectBlendingMode = blendingMode;
    _arrowVisualEffectState = state;
}

- (NSDictionary *)relativePositionValuesForView:(NSView *)view rect:(NSRect)rect {
    NSMutableDictionary *relativePositionValues = [[NSMutableDictionary alloc] init];
    
    FLOPopoverRelativePositionType relativeType = FLOPopoverRelativePositionTopLeading;
    NSPoint relativePosition;
    CGFloat posX = 0.0;
    CGFloat posY = 0.0;
    
    NSRect viewScreenRect = [view.window convertRectToScreen:[view convertRect:view.bounds toView:[view.window contentView]]];
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
    [anchorView setWantsLayer:YES];
    [[anchorView layer] setBackgroundColor:[[NSColor clearColor] CGColor]];
    [anchorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
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

#pragma mark - Popover utilities

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

- (NSRectEdge)nextEdgeForEdge:(NSRectEdge)popoverEdge {
    NSRectEdge nextEdge = popoverEdge;
    NSRectEdge edges[] = { NSRectEdgeMinX, NSRectEdgeMinY, NSRectEdgeMaxX, NSRectEdgeMaxY };
    NSInteger edgesNumber = sizeof(edges) / sizeof(NSRectEdgeMinX);
    
    for (NSInteger idx = 0; idx < edgesNumber; ++idx) {
        NSRectEdge edge = edges[idx];
        
        if (edge == popoverEdge) continue;
        
        if ([self containerFrameContainsEdge:edge]) {
            nextEdge = edge;
            break;
        }
    }
    
    return nextEdge;
}

- (BOOL)checkPopoverFrameWithEdge:(NSRectEdge)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect frame = [self popoverFrameForEdge:popoverEdge];
    
    return NSContainsRect(containerFrame, frame);
}

- (void)updatePreferredEdgeForEdge:(NSRectEdge)popoverEdge {
    if ((!_windowLiveResizeReceived || (_windowLiveResizeReceived && [self containerFrameContainsEdge:popoverEdge])) && (_preferredEdge != popoverEdge)) {
        _preferredEdge = popoverEdge;
        
        if (_popover.containsArrow) {
            [self updateBackgroundView:YES redrawn:NO];
            
            self.originalViewSize = self.backgroundView.frame.size;
        }
    }
}

- (NSRect)popoverFrameForEdge:(NSRectEdge)popoverEdge {
    NSRect popoverOrigin = [self popoverOrigin];
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSPoint anchorPoint = _anchorPoint;
    
    NSSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    NSRect frame = NSMakeRect(0.0, 0.0, popoverSize.width, popoverSize.height);
    
    // In all the cases below, find the minimum and maximum position of the
    // popover and then use the anchor point to determine where the popover
    // should be between these two locations.
    //
    // `x0` indicates the x origin of the popover if `_anchorPoint.x` is
    // 0 and aligns the left edge of the popover to the left edge of the
    // origin view. `x1` is the x origin if `_anchorPoint.x` is 1 and
    // aligns the right edge of the popover to the right edge of the origin
    // view. The anchor point determines where the popover should be between
    // these extremes.
    if (popoverEdge == NSRectEdgeMinY) {
        CGFloat x0 = NSMinX(popoverOrigin);
        CGFloat x1 = NSMaxX(popoverOrigin) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMinY(popoverOrigin) - popoverSize.height;
    } else if (popoverEdge == NSRectEdgeMaxY) {
        CGFloat x0 = NSMinX(popoverOrigin);
        CGFloat x1 = NSMaxX(popoverOrigin) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMaxY(popoverOrigin);
    } else if (popoverEdge == NSRectEdgeMinX) {
        CGFloat y0 = NSMinY(popoverOrigin);
        CGFloat y1 = NSMaxY(popoverOrigin) - contentViewSize.height;
        
        frame.origin.x = NSMinX(popoverOrigin) - popoverSize.width;
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else if (popoverEdge == NSRectEdgeMaxX) {
        CGFloat y0 = NSMinY(popoverOrigin);
        CGFloat y1 = NSMaxY(popoverOrigin) - contentViewSize.height;
        
        frame.origin.x = NSMaxX(popoverOrigin);
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
    } else {
        frame = NSZeroRect;
    }
    
    return frame;
}

- (NSRect)popoverFrame {
    NSRectEdge popoverEdge = _preferredEdge;
    
    if (_popover.staysInContainer || _popover.containsArrow) {
        NSUInteger count = 0;
        
        while (![self checkPopoverFrameWithEdge:popoverEdge]) {
            if (count >= 4) {
                popoverEdge = [self containerFrameContainsEdge:_preferredEdge] ? ((!_scrollingEventReceived && (_preferredEdge != _originalEdge) && [self checkPopoverFrameWithEdge:_originalEdge]) ? _originalEdge : _preferredEdge) : [self nextEdgeForEdge:_preferredEdge];
                
                NSRect frame = [self fitFrameToContainer:[self popoverFrameForEdge:popoverEdge]];
                
                [self updatePreferredEdgeForEdge:popoverEdge];
                
                return frame;
            }
            
            popoverEdge = [self containerFrameContainsEdge:popoverEdge] ? popoverEdge : [self nextEdgeForEdge:popoverEdge];
            
            ++count;
        }
        
        if (!_scrollingEventReceived && (_preferredEdge != _originalEdge) && [self checkPopoverFrameWithEdge:_originalEdge]) {
            _preferredEdge = _originalEdge;
            
            return [self popoverFrame];
        }
    }
    
    NSRect frame = [self popoverFrameForEdge:popoverEdge];
    
    [self updatePreferredEdgeForEdge:popoverEdge];
    
    return frame;
}

- (void)updateBackgroundView:(BOOL)updated redrawn:(BOOL)redrawn {
    if (updated) {
        NSRectEdge popoverEdge = _preferredEdge;
        CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentView.frame.size popoverEdge:popoverEdge];
        
        [self.backgroundView setFrame:((_popover.type == FLOViewPopover) ? (NSRect){ .origin = _popover.frame.origin, .size = size } : (NSRect){ .size = size })];
        [self.backgroundView setPopoverEdge:popoverEdge];
        
        NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:[self.backgroundView bounds] popoverEdge:popoverEdge];
        
        [self.contentView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self.contentView setFrame:contentViewFrame];
        
        if (redrawn) {
            [self.backgroundView setNeedsDisplay:YES];
        }
    }
}

#pragma mark - Event monitor

- (void)registerForApplicationEvents {
    [self registerApplicationActiveNotification];
    [self registerSuperviewObservers];
    [self registerWindowEvents];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationActiveNotification];
    [self unregisterSuperviewObservers];
    [self removeWindowEvents];
}

- (void)registerApplicationActiveNotification {
    if (_popover == nil) return;
    if (!_popover.closesWhenApplicationBecomesInactive) return;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(eventObserver_applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
}

- (void)removeApplicationActiveNotification {
    if (_popover == nil) return;
    if (!_popover.closesWhenApplicationBecomesInactive) return;
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
}

- (void)registerSuperviewObservers {
    if (_popoverStyle != FLOPopoverStyleNormal) return;
    if (_popover == nil) return;
    
    @autoreleasepool {
        SEL selector = @selector(eventObserver_viewBoundsDidChange:);
        
        _observerSuperviews = [[NSMutableArray alloc] init];
        
        _registeredViewBoundsObservers = [[NSMutableArray alloc] init];
        _registeredSuperviewObservers = [[NSMutableArray alloc] init];
        _registeredFrameObservers = [[NSMutableArray alloc] init];
        
        [_observerSuperviews addObject:self.positioningAnchorView];
        
        [self registerObserverView:self.positioningAnchorView selector:selector source:self];
        
        NSMutableArray *observerClipViews = [[NSMutableArray alloc] init];
        NSView *observerView = [self.positioningAnchorView superview];
        
        while (observerView != nil) {
            if ([observerView isKindOfClass:[NSView class]]) {
                if (![_observerSuperviews containsObject:observerView]) {
                    [_observerSuperviews addObject:observerView];
                    
                    [self registerObserverView:observerView selector:selector source:self];
                }
                
                if ([observerView isKindOfClass:[FLOPopoverView class]]) {
                    id<FLOPopoverProtocols> responder = ((FLOPopoverView *)observerView).responder;
                    
                    if ((responder != nil) && (responder.observerClipViews.count > 0)) {
                        for (NSClipView *clipView in responder.observerClipViews) {
                            if (![observerClipViews containsObject:clipView]) {
                                [observerClipViews addObject:clipView];
                            }
                        }
                    }
                }
            }
            
            observerView = [observerView superview];
        }
        
        for (NSClipView *clipView in observerClipViews) {
            if (![_observerSuperviews containsObject:clipView]) {
                [_observerSuperviews addObject:clipView];
                
                [self registerObserverView:clipView selector:selector source:self];
            }
        }
        
        _superviewObserversRegistered = (_registeredViewBoundsObservers.count > 0) || (_registeredSuperviewObservers.count > 0) || (_registeredFrameObservers.count > 0);
    }
}

- (void)unregisterSuperviewObservers {
    if (!_superviewObserversRegistered) return;
    
    for (NSView *observerView in _registeredViewBoundsObservers) {
        if ([observerView isKindOfClass:[NSClipView class]]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:observerView];
        }
    }
    
    for (NSView *observerView in _registeredSuperviewObservers) {
        [observerView removeObserver:self forKeyPath:@"superview"];
    }
    
    for (NSView *observerView in _registeredFrameObservers) {
        [observerView removeObserver:self forKeyPath:@"frame"];
    }
    
    _observerSuperviews = nil;
    _registeredViewBoundsObservers = nil;
    _registeredSuperviewObservers = nil;
    _registeredFrameObservers = nil;
}

- (void)registerWindowEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowWillStartLiveResize:) name:NSWindowWillStartLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowDidEndLiveResize:) name:NSWindowDidEndLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowDidMove:) name:NSWindowDidMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}

- (void)removeWindowEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillStartLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEndLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
}

#pragma mark - Event handling

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![object isKindOfClass:[NSView class]]) return;
    if (_popoverStyle != FLOPopoverStyleNormal) return;
    if (_popover == nil) return;
    
    NSView *view = (NSView *)object;
    
    if ([self.positioningView isDescendantOf:view] && [keyPath isEqualToString:@"superview"]) {
        if ([self popoverShouldCloseForChangedView:view]) {
            [self closePopoverWithTimerIfNeeded];
            
            return;
        }
    }
    
    if (_windowLiveResizeReceived) {
        if (_popover.closesWhenPopoverResignsKey || _popover.closesWhenApplicationResizes) {
            [self closePopoverWithTimerIfNeeded];
        }
        
        return;
    }
    
    if (_popover.shouldRegisterSuperviewObservers && [keyPath isEqualToString:@"frame"]) {
        if ([self popoverShouldCloseForChangedView:view]) {
            [self closePopoverWithTimerIfNeeded];
            
            return;
        }
        
        if (!_popover.isShowing && !_popover.isClosing && [self.positioningAnchorView isDescendantOf:view]) {
            [self setupObserverClipViewValues];
            [self updateFrameWhileScrolling:NO container:view];
        }
    }
}

- (void)eventObserver_viewBoundsDidChange:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSViewBoundsDidChangeNotification] && [notification.object isKindOfClass:[NSClipView class]] && [_observerClipViews containsObject:notification.object])) return;
    if (_popover == nil) return;
    
    if (!_popover.isShowing && !_popover.isClosing && [self.positioningAnchorView isDescendantOf:(NSClipView *)notification.object]) {
        _scrollingEventReceived = YES;
        
        [self updateFrameWhileScrolling:YES container:nil];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetScrollingEventReceived) object:nil];
        [self performSelector:@selector(resetScrollingEventReceived) withObject:nil afterDelay:0.5];
    }
}

- (void)eventObserver_applicationDidResignActive:(NSNotification *)notification {
    if (![notification.name isEqualToString:NSApplicationDidResignActiveNotification]) return;
    if (_popover == nil) return;
    
    [_popover close];
}

- (void)eventObserver_windowWillStartLiveResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowWillStartLiveResizeNotification] && (notification.object == self.mainWindow))) return;
    
    _windowLiveResizeReceived = YES;
}

- (void)eventObserver_windowDidEndLiveResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidEndLiveResizeNotification] && (notification.object == self.mainWindow))) return;
    
    _windowLiveResizeReceived = NO;
}

- (void)eventObserver_windowDidResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]])) return;
    if (_popover == nil) return;
    if (!_popover.updatesFrameWhenApplicationResizes) return;
    if (_popover.isShowing || _popover.isClosing) return;
    
    NSWindow *window = (NSWindow *)notification.object;
    
    if ((_popoverStyle == FLOPopoverStyleAlert) && (window == self.presentedWindow)) {
        if (_popover.type == FLOWindowPopover) {
            NSRect frame = [self.presentedWindow contentRectForFrameRect:self.presentedWindow.frame];
            
            [_popover updateFrame:frame];
        }
        
        return;
    }
    
    if ((_popover.closesWhenPopoverResignsKey || _popover.closesWhenApplicationResizes) && (window == self.mainWindow)) {
        [self closePopoverWithTimerIfNeeded];
    }
    
    if (!((window == self.mainWindow) && !(_popover.closesWhenPopoverResignsKey || _popover.closesWhenApplicationResizes))) return;
    
    NSRectEdge preferredEdge = _preferredEdge;
    NSRect popoverFrame = [self popoverFrameWithResizingWindow:window];
    
    // Update arrow edge and content view frame
    if (_popover.containsArrow) {
        NSRect positionScreenFrame = [self positionScreenFrame];
        
        // Should [invalidateShadow] before set arrow hidden or visible.
        [_popover invalidateShadow];
        
        if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
            // If the positioningView (the sender where arrow is displayed at)
            // move out of containerFrame, we should hide the arrow of popover.
            [self.backgroundView setArrow:NO];
        } else {
            [self.backgroundView setPopoverOrigin:[self popoverOrigin]];
            
            if (preferredEdge == _preferredEdge) {
                [self.backgroundView setArrow:YES];
            } else {
                [self updateBackgroundView:YES redrawn:YES];
                
                // Must update the popover frame here in case of changing the preferredEdge
                // to update the popover size and arrow origin correctly
                self.originalViewSize = self.backgroundView.frame.size;
                
                popoverFrame = [self popoverFrameWithResizingWindow:window];
            }
        }
    }
    
    [_popover updateFrame:popoverFrame];
    
    [self updateContentSizeForPopover];
    [self updatePositionFrame];
    [self setupObserverClipViewValues];
}

- (void)eventObserver_windowDidMove:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidMoveNotification] && (notification.object == self.mainWindow))) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupObserverClipViewValues) object:nil];
    [self performSelector:@selector(setupObserverClipViewValues) withObject:nil afterDelay:0.25];
    
    // Should update arrow origin in case of changing
    if (_popover.containsArrow) {
        if (_popover.staysInContainer) {
            NSRect positionScreenFrame = [self positionScreenFrame];
            
            if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
                // If the positioningView (the sender where arrow is displayed at)
                // move out of containerFrame, we should hide the arrow of popover.
                [self.backgroundView setArrow:NO];
            } else {
                [self.backgroundView setPopoverOrigin:[self popoverOrigin]];
                [self updateBackgroundView:YES redrawn:YES];
            }
        } else {
            [self.backgroundView setPopoverOrigin:[self popoverOrigin]];
            [self updateBackgroundView:YES redrawn:YES];
        }
    }
}

- (void)eventObserver_windowWillClose:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowWillCloseNotification] && [notification.object isKindOfClass:[NSWindow class]])) return;
    if (!([_popover.representedObject isKindOfClass:[FLOPopoverView class]] || [_popover.representedObject isKindOfClass:[FLOPopoverWindow class]])) return;
    
    NSWindow *window = (NSWindow *)notification.object;
    BOOL closeNeeded = NO;
    
    if ([_popover.representedObject isKindOfClass:[FLOPopoverView class]]) {
        FLOPopoverView *popoverView = (FLOPopoverView *)_popover.representedObject;
        
        closeNeeded = [popoverView isDescendantOf:[window contentView]];
    } else {
        FLOPopoverWindow *popoverWindow = (FLOPopoverWindow *)_popover.representedObject;
        
        closeNeeded = ((window != popoverWindow) && [self window:window contains:popoverWindow]);
    }
    
    if (closeNeeded) {
        [self closePopoverWithTimerIfNeeded];
    }
}

@end
