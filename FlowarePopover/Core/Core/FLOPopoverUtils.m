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
#import "FLOExtensionsNSView.h"

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
    NSMutableDictionary *_observerSuperviewFrames;
    NSMutableDictionary *_observerSuperviewStates;
}

@property (nonatomic, weak, readwrite) NSWindow *mainWindow;

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
    _popover = nil;
    _presentedWindow = nil;
    
    self.contentViewController = nil;
    
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.contentView removeFromSuperview];
    [self.contentView setAlphaValue:1.0];
    self.contentView = nil;
    
    if ((self.positioningAnchorView != self.positioningView) && [self.positioningAnchorView isDescendantOf:self.positioningView]) {
        [self.positioningAnchorView removeFromSuperview];
    }
    
    self.positioningView = nil;
    self.senderView = nil;
    self.positioningAnchorView = nil;
    
    [self.backgroundView setTranslatesAutoresizingMaskIntoConstraints:NO];
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

- (NSRectEdge )preferredEdge {
    return _preferredEdge;
}

- (void)setPresentedWindow:(NSWindow *)presentedWindow {
    _presentedWindow = presentedWindow;
}

- (NSWindow *)presentedWindow {
    return ((_presentedWindow != nil) ? _presentedWindow : [self.positioningView window]);
}

- (void)setObserverFrame:(NSRect)frame forView:(NSView *)observerView {
    if (![observerView isKindOfClass:[NSView class]]) return;
    if (![_observerSuperviews containsObject:observerView]) return;
    
    @synchronized (_observerSuperviewFrames) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        [_observerSuperviewFrames setObject:@(frame) forKey:key];
    }
}

- (NSRect)observerFrameForView:(NSView *)observerView {
    if (![observerView isKindOfClass:[NSView class]]) return NSZeroRect;
    if (![_observerSuperviews containsObject:observerView]) return NSZeroRect;
    
    @synchronized (_observerSuperviewFrames) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        if ([[_observerSuperviewFrames objectForKey:key] isKindOfClass:[NSValue class]]) {
            return [[_observerSuperviewFrames objectForKey:key] rectValue];
        }
        
        return NSZeroRect;
    }
}

- (void)setObserverState:(BOOL)containsRect forView:(NSView *)observerView {
    if (![observerView isKindOfClass:[NSView class]]) return;
    if (![_observerSuperviews containsObject:observerView]) return;
    
    @synchronized (_observerSuperviewStates) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        [_observerSuperviewStates setObject:@(containsRect) forKey:key];
    }
}

- (BOOL)observerStateForView:(NSView *)observerView {
    if (![observerView isKindOfClass:[NSView class]]) return NO;
    if (![_observerSuperviews containsObject:observerView]) return NO;
    
    @synchronized (_observerSuperviewStates) {
        NSValue *key = [NSValue valueWithNonretainedObject:observerView];
        
        if ([[_observerSuperviewStates objectForKey:key] isKindOfClass:[NSNumber class]]) {
            return [[_observerSuperviewStates objectForKey:key] boolValue];
        }
        
        return NO;
    }
}

#pragma mark - Local methods

- (NSRect)containerFrame {
    if (_popover.staysInContainer) {
        NSRect closestSuperviewFrame = [self closestSuperviewFrame];
        
        if (!NSEqualRects(closestSuperviewFrame, NSZeroRect)) {
            return closestSuperviewFrame;
        } else {
            NSDictionary *dictionary = [self closestSuperviewContainsSize];
            
            if (dictionary != nil) {
                return [self observerFrameForView:[dictionary objectForKey:@"observerView"]];
            }
            
            return [self.presentedWindow frame];
        }
        
        return [self.mainWindow frame];
    }
    
    return [[self.mainWindow screen] visibleFrame];
}

- (void)resetScrollingEventReceived {
    _scrollingEventReceived = NO;
}

- (NSRect)popoverOrigin {
    NSRect positionRelativeFrame = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:(_popover.shouldUseRelativeVisibleRect ? [self.positioningAnchorView visibleRect] : self.positioningFrame)] toView:nil];
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
    NSRect frame = [self.positioningView visibleRect];
    
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

- (void)setupObserverSuperviewValues {
    if (_popover == nil) return;
    
    NSRect popoverFrame = _popover.frame;
    
    if (NSEqualRects(popoverFrame, NSZeroRect)) {
        popoverFrame = [self popoverFrameForEdge:_preferredEdge];
    }
    
    for (NSView *observerView in _observerSuperviews) {
        NSRect observerViewFrame = [observerView.window convertRectToScreen:[observerView convertRect:observerView.visibleRect toView:[observerView.window contentView]]];
        BOOL containsRect = NSContainsRect(observerViewFrame, popoverFrame);
        
        [self setObserverFrame:observerViewFrame forView:observerView];
        [self setObserverState:containsRect forView:observerView];
    }
}

- (void)registerObserverForSuperviews {
    if (_popover == nil) return;
    if (!_popover.shouldRegisterSuperviewObservers) return;
    
    _observerClipViews = [[NSMutableArray alloc] init];
    _observerSuperviewFrames = [[NSMutableDictionary alloc] init];
    _observerSuperviewStates = [[NSMutableDictionary alloc] init];
    
    for (NSView *observerView in _observerSuperviews) {
        if ([observerView isKindOfClass:[NSClipView class]] && ![_observerClipViews containsObject:(NSClipView *)observerView]) {
            [_observerClipViews addObject:(NSClipView *)observerView];
        }
    }
    
    [self setupObserverSuperviewValues];
}

- (NSRect)closestSuperviewFrame {
    NSRect frame = NSZeroRect;
    
    for (NSView *observerView in _observerSuperviews) {
        BOOL containsRect = [self observerStateForView:observerView];
        
        if (containsRect) {
            frame = [self observerFrameForView:observerView];
            break;
        }
    }
    
    return frame;
}

- (NSDictionary *)closestSuperviewContainsSize {
    NSSize size = NSZeroSize;
    NSSize popoverSize = _popover.frame.size;
    
    if (NSEqualSizes(popoverSize, NSZeroSize)) return nil;
    
    NSView *superview = nil;
    
    for (NSView *observerView in _observerSuperviews) {
        size = [self observerFrameForView:observerView].size;
        
        if (NSContainsRect((NSRect){ .size = size }, (NSRect){ .size = popoverSize })) {
            superview = observerView;
            
            break;
        } else {
            size = NSZeroSize;
        }
    }
    
    return ((superview != nil) && !NSEqualSizes(size, NSZeroSize)) ? @{@"observerView": superview, @"size": @(size)} : nil;
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
            
            if ((observerSuperview != changingSuperview) && ![_observerSuperviews containsObject:changingSuperview]) {
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
    
    __weak typeof(self) wself = self;
    __weak id<FLOPopoverProtocols> popover = _popover;
    
    [self setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        NSRect positionScreenFrame = [this positionScreenFrame];
        NSRectEdge preferredEdge = this->_preferredEdge;
        
        /// Get the popover frame, maybe the _preferredEdge will be changed
        /// when calculates new frame of popover.
        NSRect popoverFrame = [this popoverFrame];
        
        /// Update arrow path (hidden or not) if the popover contains arrow
        /// as configured when displayed.
        if (popover.containsArrow) {
            // Should [invalidateShadow] before set arrow hidden or visible.
            [popover invalidateShadow];
            
            /// If the positioningView (the sender where arrow is displayed at)
            /// move out of containerFrame, we should hide the arrow of popover.
            if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
                [this.backgroundView setArrow:NO];
            } else {
                /// If the positioningView (the sender where arrow is displayed at) move inside
                /// of containerFrame, we should show the arrow of popover.
                /// And also update the arrow position respectively to the new popoverOrigin
                [this.backgroundView setPopoverOrigin:[this popoverOrigin]];
                
                if (preferredEdge == this->_preferredEdge) {
                    [this.backgroundView setArrow:YES];
                } else {
                    [this updateBackgroundView:YES redrawn:YES];
                    
                    /// Must update the popover frame here in case of changing the preferredEdge
                    /// to update the popover size and arrow origin correctly
                    this.originalViewSize = [this.backgroundView frame].size;
                    
                    popoverFrame = [this popoverFrame];
                }
            }
        }
        
        BOOL closeIfNeeded = NO;
        /// Stop the popover when it (or the position view) reach the container bounds.
        NSRect closestSuperviewFrame = [this closestSuperviewFrame];
        BOOL isNotContained = NSEqualRects(positionScreenFrame, NSZeroRect);
        
        if (popover.staysInScreen || popover.staysInContainer || popover.closesWhenNotBelongToContainer) {
            if (!isNotContained) {
                if (popover.staysInContainer || popover.closesWhenNotBelongToContainer) {
                    if (NSEqualRects(closestSuperviewFrame, NSZeroRect)) {
                        isNotContained = !NSContainsRect((popover.staysInContainer ? [this.mainWindow frame] : [[this.mainWindow screen] visibleFrame]), popoverFrame);
                    } else {
                        isNotContained = !NSContainsRect(closestSuperviewFrame, popoverFrame);
                    }
                } else {
                    isNotContained = !NSContainsRect((popover.staysInContainer ? [this.mainWindow frame] : [[this.mainWindow screen] visibleFrame]), popoverFrame);
                }
            }
            
            closeIfNeeded = (popover.closesWhenNotBelongToContainer && isNotContained);
        }
        
        if (!closeIfNeeded && popover.stopsAtContainerBounds && isNotContained) return;
        
        /// Close the popover if closesWhenNotBelongToContainer is set as YES.
        if (closeIfNeeded && popover.closesWhenNotBelongToContainer) {
            [popover close];
            return;
        }
        
        /// Update
        if (popover.type == FLOViewPopover) {
            popoverFrame = [this.presentedWindow convertRectFromScreen:popoverFrame];
        }
        
        [popover updateFrame:popoverFrame];
        [this updatePositionFrame];
        [this setupObserverSuperviewValues];
    }];
}

- (void)updateContentSizeForPopover {
    if (_popover == nil) return;
    
    if (!_popover.containsArrow) {
        __weak typeof(self) wself = self;
        __weak id<FLOPopoverProtocols> popover = _popover;
        
        [self setLocalUpdatedBlock:^{
            __strong typeof(self) this = wself;
            
            // Should update the contentSize when popover frame's size changed.
            this.contentSize = popover.frame.size;
            
            if (popover.type == FLOWindowPopover) {
                CGSize size = [this.backgroundView sizeForBackgroundViewWithContentSize:this.contentSize popoverEdge:this->_preferredEdge];
                
                [this.backgroundView setFrameSize:size];
            }
            
            [this updateContentViewFrameInsets:this->_preferredEdge];
        }];
    }
}

- (void)invalidateCloseTimer {
    if (_closeTimer) {
        [_closeTimer invalidate];
        
        _closeTimer = nil;
    }
}

#pragma mark - Utilities

- (NSMutableArray<NSView *> *)observerSuperviews {
    return _observerSuperviews;
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

- (void)updateContentViewFrameInsets:(NSRectEdge)popoverEdge {
    __weak typeof(self) wself = self;
    
    [self setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        NSRect contentViewFrame = [this.backgroundView contentViewFrameForBackgroundFrame:[this.backgroundView bounds] popoverEdge:popoverEdge];
        NSEdgeInsets contentInsets = [this.contentView contentInsetsWithFrame:contentViewFrame];
        [this.contentView setFrame:contentViewFrame];
        [this.contentView updateConstraintsWithInsets:contentInsets];
    }];
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

- (void)setLocalUpdatedBlock:(void(^)(void))block {
    BOOL isLocalUpdated = _popover.localUpdated;
    
    // If the localUpdated value is already changed in the root block.
    // Should ignore here, until the root block finishes and updates later.
    if (!isLocalUpdated) {
        [_popover setLocalUpdated:YES];
    }
    
    if (block != nil) {
        block();
    }
    
    // If the localUpdated value is already changed in the root block.
    // Should ignore here, until the root block finishes and updates later.
    if (!isLocalUpdated) {
        [_popover setLocalUpdated:NO];
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
    __weak typeof(self) wself = self;
    __weak id<FLOPopoverProtocols> popover = _popover;
    
    [self setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        if (popover == nil) return;
        
        if (NSEqualRects(this.positioningFrame, NSZeroRect)) {
            this.positioningFrame = [this.positioningAnchorView visibleRect];
        }
        
        [this.backgroundView setPopoverOrigin:[this popoverOrigin]];
        this.originalViewSize = NSEqualSizes(this.originalViewSize, NSZeroSize) ? this.contentView.frame.size : this.originalViewSize;
        this.contentSize = NSEqualSizes(this.contentSize, NSZeroSize) ? this.contentView.frame.size : this.contentSize;
        
        NSSize contentViewSize = NSEqualSizes(this.contentSize, NSZeroSize) ? this.originalViewSize : this.contentSize;
        NSRectEdge popoverEdge = this->_preferredEdge;
        
        [this.backgroundView setBorderRadius:([this.contentView layer] ? [[this.contentView layer] cornerRadius] : kFlowarePopover_BorderRadius)];
        [this.backgroundView setMovable:popover.isMovable];
        [this.backgroundView setDetachable:popover.isDetachable];
        
        if (popover.shouldShowArrow && (this.positioningView == this.positioningAnchorView)) {
            this.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
            this.animationType = FLOPopoverAnimationDefault;
            
            [this.backgroundView setArrowSize:popover.arrowSize];
            [this.backgroundView setArrow:popover.shouldShowArrow];
            [this.backgroundView setArrowColor:[[this.contentView layer] backgroundColor]];
            
            if (this->_showsWithVisualEffect) {
                [this.backgroundView setVisualEffect:this->_showsWithVisualEffect material:this->_arrowVisualEffectMaterial blendingMode:this->_arrowVisualEffectBlendingMode state:this->_arrowVisualEffectState];
            }
        } else {
            [popover setArrowSize:NSZeroSize];
        }
        
        [this.backgroundView setShadow:(popover.type == FLOViewPopover)];
        
        if (popover.isMovable || popover.isDetachable) {
            this.backgroundView.delegate = (id<FLOPopoverViewDelegate>)popover;
        }
        
        CGSize size = [this.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
        
        [this.backgroundView setFrameSize:size];
        [this.backgroundView setPopoverEdge:popoverEdge];
        [this updateContentViewFrameInsets:popoverEdge];
        
        NSRect popoverFrame = [this popoverFrame];
        
        if (popover.type == FLOViewPopover) {
            popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
        }
        
        // Update arrow edge and content view frame
        if (popover.shouldShowArrow && (this.positioningView == this.positioningAnchorView)) {
            [this.backgroundView setAlphaValue:1.0];
            [this updateBackgroundView:YES redrawn:YES];
        }
        
        this.originalViewSize = this.backgroundView.frame.size;
        
        [popover setInitialFrame:popoverFrame];
        [popover updateFrame:popoverFrame];
        // Should [invalidateShadow] here in case of calling this [setupComponentsForPopover:] method
        // from [updatePopoverFrame]
        [popover invalidateShadow];
        
        this->_verticallyAvailableMargin = [[this.mainWindow contentView] visibleRect].size.height + popover.bottomOffset - NSMaxY([this.mainWindow convertRectFromScreen:popoverFrame]);
        
        [this updatePositionFrame];
        
        if (observerNeeded && popover.shouldRegisterSuperviewObservers) {
            [this setupObserverSuperviewValues];
            [this setupComponentsForPopover:NO];
        }
    }];
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
            [disableView addAutoResize:YES toParent:self.backgroundView];
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

- (void)setupRelativePosition:(NSPoint)position type:(FLOPopoverRelativePositionType)relativeType forAnchorView:(NSView *)anchorView parent:(NSView *)parentView {
    if ((anchorView != nil) && (anchorView != parentView) && [anchorView isDescendantOf:parentView]) {
        [anchorView removeConstraints];
        
        CGFloat posX = position.x;
        CGFloat posY = position.y;
        
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
    }
}

- (NSView *)anchorViewWithRelativePosition:(NSPoint)position type:(FLOPopoverRelativePositionType)relativeType parent:(NSView *)parentView {
    NSView *anchorView = [[NSView alloc] initWithFrame:NSZeroRect];
    [anchorView setWantsLayer:YES];
    [[anchorView layer] setBackgroundColor:[[NSColor clearColor] CGColor]];
    [anchorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [parentView addSubview:anchorView];
    
    [self setupRelativePosition:position type:relativeType forAnchorView:anchorView parent:parentView];
    
    return anchorView;
}

- (void)anchorView:(NSView *)anchorView shouldUpdate:(BOOL)shouldUpdate position:(NSPoint)position inParent:(NSView *)parentView {
    if (shouldUpdate && (anchorView != nil) && (anchorView != parentView) && [anchorView isDescendantOf:parentView]) {
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
        
        [parentView updateConstraints];
        [parentView updateConstraintsForSubtreeIfNeeded];
        [parentView layoutSubtreeIfNeeded];
    }
}

- (void)validateAnchorView:(NSView *)anchorView position:(NSPoint)position inParent:(NSView *)parentView withPositioningRect:(NSRect)positioningRect {
    BOOL shouldUpdate = NO;
    
    CGFloat posX = position.x;
    CGFloat posY = position.y;
    
    if ((anchorView != nil) && (anchorView != parentView) && [anchorView isDescendantOf:parentView]) {
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
    
    if ((relativeType != self.relativePositionType) && (positioningView != self.positioningAnchorView) && [self.positioningAnchorView isDescendantOf:positioningView]) {
        self.relativePositionType = relativeType;
        
        [self setupRelativePosition:relativePosition type:relativeType forAnchorView:self.positioningAnchorView parent:positioningView];
    }
    
    if (self.positioningAnchorView == nil) {
        self.positioningAnchorView = [self anchorViewWithRelativePosition:relativePosition type:relativeType parent:positioningView];
        
        [positioningView updateConstraints];
        [positioningView updateConstraintsForSubtreeIfNeeded];
        [positioningView layoutSubtreeIfNeeded];
    }
    
    if ((positioningView != self.positioningAnchorView) && [self.positioningAnchorView isDescendantOf:positioningView]) {
        if (shouldUpdatePosition) {
            [self anchorView:self.positioningAnchorView shouldUpdate:shouldUpdatePosition position:relativePosition inParent:positioningView];
        }
        
        [self validateAnchorView:self.positioningAnchorView position:relativePosition inParent:positioningView withPositioningRect:positioningRect];
        
        [self.positioningAnchorView setHidden:NO];
    }
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
    NSRectEdge edgeMinX[] = { NSRectEdgeMinX, NSRectEdgeMaxX, NSRectEdgeMinY, NSRectEdgeMaxY };
    NSRectEdge edgeMaxX[] = { NSRectEdgeMaxX, NSRectEdgeMinX, NSRectEdgeMaxY, NSRectEdgeMinY };
    NSRectEdge edgeMinY[] = { NSRectEdgeMinY, NSRectEdgeMaxY, NSRectEdgeMinX, NSRectEdgeMaxX };
    NSRectEdge edgeMaxY[] = { NSRectEdgeMaxY, NSRectEdgeMinY, NSRectEdgeMaxX, NSRectEdgeMinX };
    NSRectEdge *edges = (popoverEdge == NSRectEdgeMinX) ? edgeMinX : ((popoverEdge == NSRectEdgeMaxX) ? edgeMaxX : ((popoverEdge == NSRectEdgeMinY) ? edgeMinY : edgeMaxY));
    NSInteger edgesNumber = sizeof(edgeMinX) / sizeof(edgeMinX[0]);
    
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
            __weak typeof(self) wself = self;
            
            [self setLocalUpdatedBlock:^{
                __strong typeof(self) this = wself;
                
                [this updateBackgroundView:YES redrawn:NO];
                
                this.originalViewSize = [this.backgroundView frame].size;
            }];
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
    
    if (_popover.staysInScreen || _popover.staysInContainer) {
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
        CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentSize popoverEdge:popoverEdge];
        
        [self.backgroundView setFrame:((_popover.type == FLOViewPopover) ? (NSRect){ .origin = _popover.frame.origin, .size = size } : (NSRect){ .size = size })];
        [self.backgroundView setPopoverEdge:popoverEdge];
        [self updateContentViewFrameInsets:popoverEdge];
        
        if (redrawn) {
            [self.backgroundView setNeedsDisplay:YES];
        }
    }
}

#pragma mark - Event monitor

- (void)registerForApplicationEvents {
    [self registerApplicationActiveNotification];
    [self registerSuperviewObservers];
    [self registerContentViewEvents];
    [self registerWindowEvents];
}

- (void)removeAllApplicationEvents {
    [self removeApplicationActiveNotification];
    [self removeSuperviewObservers];
    [self removeContentViewEvents];
    [self removeWindowEvents];
}

- (void)registerApplicationActiveNotification {
    if (_popover == nil) return;
    if (!_popover.closesWhenApplicationBecomesInactive) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
}

- (void)removeApplicationActiveNotification {
    if (_popover == nil) return;
    if (!_popover.closesWhenApplicationBecomesInactive) return;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
}

- (void)registerSuperviewObservers {
    if (_popoverStyle != FLOPopoverStyleNormal) return;
    if (_popover == nil) return;
    
    @autoreleasepool {
        SEL selector = @selector(notification_viewBoundsDidChange:);
        
        _observerSuperviews = [[NSMutableArray alloc] init];
        
        _registeredViewBoundsObservers = [[NSMutableArray alloc] init];
        _registeredSuperviewObservers = [[NSMutableArray alloc] init];
        _registeredFrameObservers = [[NSMutableArray alloc] init];
        
        [_observerSuperviews addObject:self.positioningAnchorView];
        
        [self registerObserverView:self.positioningAnchorView selector:selector source:self];
        
        NSView *observerView = [self.positioningAnchorView superview];
        
        while (observerView != nil) {
            if ([observerView isKindOfClass:[NSView class]]) {
                if (![_observerSuperviews containsObject:observerView]) {
                    [_observerSuperviews addObject:observerView];
                    
                    [self registerObserverView:observerView selector:selector source:self];
                }
            }
            
            observerView = [observerView superview];
        }
        
        [self registerObserverForSuperviews];
        
        _superviewObserversRegistered = (_registeredViewBoundsObservers.count > 0) || (_registeredSuperviewObservers.count > 0) || (_registeredFrameObservers.count > 0);
    }
}

- (void)removeSuperviewObservers {
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
    
    [_observerSuperviews removeAllObjects];
    [_observerClipViews removeAllObjects];
    [_registeredViewBoundsObservers removeAllObjects];
    [_registeredSuperviewObservers removeAllObjects];
    [_registeredFrameObservers removeAllObjects];
    [_observerSuperviewFrames removeAllObjects];
    [_observerSuperviewStates removeAllObjects];
    
    _observerSuperviews = nil;
    _observerClipViews = nil;
    _registeredViewBoundsObservers = nil;
    _registeredSuperviewObservers = nil;
    _registeredFrameObservers = nil;
    _observerSuperviewFrames = nil;
    _observerSuperviewStates = nil;
    _superviewObserversRegistered = NO;
}

- (void)registerContentViewEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:self.contentView];
}

- (void)removeContentViewEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:self.contentView];
}

- (void)registerWindowEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_windowWillStartLiveResize:) name:NSWindowWillStartLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_windowDidEndLiveResize:) name:NSWindowDidEndLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_windowDidMove:) name:NSWindowDidMoveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification_windowWillClose:) name:NSWindowWillCloseNotification object:nil];
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
            [self setupObserverSuperviewValues];
            [self updateFrameWhileScrolling:NO container:view];
        }
    }
}

- (void)notification_viewBoundsDidChange:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSViewBoundsDidChangeNotification] && [notification.object isKindOfClass:[NSClipView class]] && [_observerClipViews containsObject:notification.object])) return;
    if (_popover == nil) return;
    
    NSClipView *clipView = (NSClipView *)notification.object;
    
    if (!_popover.isShowing && !_popover.isClosing && [self.positioningAnchorView isDescendantOf:clipView]) {
        _scrollingEventReceived = YES;
        
        [self updateFrameWhileScrolling:YES container:clipView];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetScrollingEventReceived) object:nil];
        [self performSelector:@selector(resetScrollingEventReceived) withObject:nil afterDelay:0.5];
    }
}

- (void)notification_viewFrameDidChange:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSViewFrameDidChangeNotification] && (notification.object == self.contentView))) return;
    if (_popover == nil) return;
    if (_popover.localUpdated) return;
    
    NSRect newFrame = [self.contentView frame];
    
    if (((NSWidth(newFrame) > 0) && (NSHeight(newFrame) > 0)) && !NSEqualSizes(newFrame.size, self.contentSize)) {
        BOOL updatesFrameWhileShowing = _popover.updatesFrameWhileShowing;
        
        if ((self.animationBehaviour == FLOPopoverAnimationBehaviorDefault) && (self.animationType == FLOPopoverAnimationDefault)) {
            _popover.updatesFrameWhileShowing = YES;
        }
        
        [_popover setPopoverContentViewSize:newFrame.size];
        _popover.updatesFrameWhileShowing = updatesFrameWhileShowing;
    }
}

- (void)notification_applicationDidResignActive:(NSNotification *)notification {
    if (![notification.name isEqualToString:NSApplicationDidResignActiveNotification]) return;
    if (_popover == nil) return;
    
    [_popover close];
}

- (void)notification_windowWillStartLiveResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowWillStartLiveResizeNotification] && (notification.object == self.mainWindow))) return;
    
    _windowLiveResizeReceived = YES;
}

- (void)notification_windowDidEndLiveResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidEndLiveResizeNotification] && (notification.object == self.mainWindow))) return;
    
    _windowLiveResizeReceived = NO;
}

- (void)notification_windowDidResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]])) return;
    if (_popover == nil) return;
    if (!_popover.updatesFrameWhenApplicationResizes) return;
    if (_popover.isShowing || _popover.isClosing) return;
    
    NSWindow *window = (NSWindow *)notification.object;
    
    __weak typeof(self) wself = self;
    __weak id<FLOPopoverProtocols> popover = _popover;
    
    [self setLocalUpdatedBlock:^{
        __strong typeof(self) this = wself;
        
        if (this->_popoverStyle == FLOPopoverStyleAlert) {
            if (window == this.presentedWindow) {
                [popover updatePopoverFrame];
            }
        } else {
            if ((popover.closesWhenPopoverResignsKey || popover.closesWhenApplicationResizes) && (window == self.mainWindow)) {
                [this closePopoverWithTimerIfNeeded];
            }
            
            BOOL shouldUpdateFrame = ((window == this.mainWindow) && !(popover.closesWhenPopoverResignsKey || popover.closesWhenApplicationResizes));
            
            if (!shouldUpdateFrame) return;
            
            NSRectEdge preferredEdge = this->_preferredEdge;
            NSRect popoverFrame = [this popoverFrameWithResizingWindow:window];
            
            // Update arrow edge and content view frame
            if (popover.containsArrow) {
                NSRect positionScreenFrame = [this positionScreenFrame];
                
                // Should [invalidateShadow] before set arrow hidden or visible.
                [popover invalidateShadow];
                
                if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
                    // If the positioningView (the sender where arrow is displayed at)
                    // move out of containerFrame, we should hide the arrow of popover.
                    [this.backgroundView setArrow:NO];
                } else {
                    [this.backgroundView setPopoverOrigin:[this popoverOrigin]];
                    
                    if (preferredEdge == this->_preferredEdge) {
                        [this.backgroundView setArrow:YES];
                    } else {
                        [this updateBackgroundView:YES redrawn:YES];
                        
                        // Must update the popover frame here in case of changing the preferredEdge
                        // to update the popover size and arrow origin correctly
                        this.originalViewSize = this.backgroundView.frame.size;
                        
                        popoverFrame = [this popoverFrameWithResizingWindow:window];
                    }
                }
            }
            
            [popover updateFrame:popoverFrame];
            [this updateContentSizeForPopover];
            [this updatePositionFrame];
            [this setupObserverSuperviewValues];
        }
    }];
}

- (void)notification_windowDidMove:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidMoveNotification] && (notification.object == self.mainWindow))) return;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setupObserverSuperviewValues) object:nil];
    [self performSelector:@selector(setupObserverSuperviewValues) withObject:nil afterDelay:0.25];
    
    // Should update arrow origin in case of changing
    if (_popover.containsArrow) {
        __weak typeof(self) wself = self;
        __weak id<FLOPopoverProtocols> popover = _popover;
        
        [self setLocalUpdatedBlock:^{
            __strong typeof(self) this = wself;
            
            if (popover.staysInScreen || popover.staysInContainer) {
                NSRect positionScreenFrame = [this positionScreenFrame];
                
                if (NSEqualRects(positionScreenFrame, NSZeroRect)) {
                    // If the positioningView (the sender where arrow is displayed at)
                    // move out of containerFrame, we should hide the arrow of popover.
                    [this.backgroundView setArrow:NO];
                } else {
                    [this.backgroundView setPopoverOrigin:[this popoverOrigin]];
                    [this updateBackgroundView:YES redrawn:YES];
                }
            } else {
                [this.backgroundView setPopoverOrigin:[this popoverOrigin]];
                [this updateBackgroundView:YES redrawn:YES];
            }
        }];
    }
}

- (void)notification_windowWillClose:(NSNotification *)notification {
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
