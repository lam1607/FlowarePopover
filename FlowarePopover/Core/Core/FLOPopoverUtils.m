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
#import "FLOVirtualInteractionView.h"


@interface FLOPopoverUtils () {
    NSRectEdge _preferredEdge;
    NSRectEdge _originalEdge;
    CGPoint _anchorPoint;
    NSRect _positionScreenFrame;
    CGFloat _verticallyAvailableMargin;
    
    BOOL _shouldShowArrowWithVisualEffect;
    NSVisualEffectMaterial _arrowVisualEffectMaterial;
    NSVisualEffectBlendingMode _arrowVisualEffectBlendingMode;
    NSVisualEffectState _arrowVisualEffectState;
    
    BOOL _observerViewBoundsDidChange;
    
    FLOVirtualInteractionView *_virtualInteractionView;
    
    NSMutableArray<NSView *> *_observerSuperviews;
    NSMutableArray<NSClipView *> *_observerClipViews;
    NSMutableDictionary *_observerClipViewFrames;
    NSMutableDictionary *_observerClipViewStates;
}

@property (nonatomic, strong, readwrite) NSWindow *mainWindow;
@property (nonatomic, assign, readwrite) BOOL mainWindowResized;

@end

@implementation FLOPopoverUtils

@synthesize mainWindow = _mainWindow;
@synthesize mainWindowResized = _mainWindowResized;
@synthesize presentedWindow = _presentedWindow;

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        _mainWindow = [NSApp mainWindow];
        
        if (_mainWindow == nil) {
            _mainWindow = [[[NSApplication sharedApplication] windows] firstObject];
        }
        
        _userInteractionEnable = YES;
        _popoverStyle = FLOPopoverStyleNormal;
        
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
        _observerViewBoundsDidChange = NO;
    }
    
    return self;
}

- (instancetype)initWithPopover:(id<FLOPopoverProtocols>)popover {
    if (self = [self init]) {
        _popover = popover;
    }
    
    return self;
}

- (void)dealloc {
    _mainWindow = nil;
    
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

- (NSWindow *)mainWindow {
    return _mainWindow;
}

- (BOOL)mainWindowResized {
    return _mainWindowResized;
}

- (void)setMainWindowResized:(BOOL)mainWindowResized {
    _mainWindowResized = mainWindowResized;
}

- (void)setPresentedWindow:(NSWindow *)presentedWindow {
    _presentedWindow = presentedWindow;
}

- (NSWindow *)presentedWindow {
    return ((_presentedWindow != nil) ? _presentedWindow : self.positioningView.window);
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
    return (self.staysInApplicationFrame ? self.mainWindow.frame : self.mainWindow.screen.frame);
}

- (void)mainWindowDidEndResize {
    _mainWindowResized = NO;
}

- (void)resetObserverViewBoundsDidChange {
    _observerViewBoundsDidChange = NO;
}

- (NSRect)popoverOrigin {
    NSRect positionRelativeFrame = [self.positioningAnchorView convertRect:[self.positioningAnchorView alignmentRectForFrame:self.positioningFrame] toView:nil];
    NSRect popoverOrigin = [self.positioningAnchorView.window convertRectToScreen:positionRelativeFrame];
    
    return popoverOrigin;
}

- (void)setPositionScreenFrame {
    NSRect positionWindowFrame = [self.positioningView convertRect:self.positioningView.bounds toView:self.presentedWindow.contentView];
    NSRect positionScreenFrame = [self.presentedWindow convertRectToScreen:positionWindowFrame];
    
    _positionScreenFrame = positionScreenFrame;
}

- (NSRect)getPositionScreenFrame {
    NSRect positionWindowFrame = [self.positioningView convertRect:self.positioningView.bounds toView:self.presentedWindow.contentView];
    NSRect positionScreenFrame = [self.presentedWindow convertRectToScreen:positionWindowFrame];
    
    return positionScreenFrame;
}

- (void)registerObserverView:(NSView *)view selector:(SEL)selector source:(id)source {
    if ([source respondsToSelector:selector]) {
        if ([view isKindOfClass:[NSClipView class]]) {
            [view setPostsBoundsChangedNotifications:YES];
            
            [[NSNotificationCenter defaultCenter] addObserver:source
                                                     selector:selector
                                                         name:NSViewBoundsDidChangeNotification
                                                       object:view];
        } else {
            [view addObserver:source forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
            [view addObserver:source forKeyPath:@"superview" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
        }
    }
}

- (void)setupObserverClipViewValues {
    if (self.popover == nil) return;
    
    NSRect popoverFrame = self.popover.frame;
    
    for (NSClipView *observerView in _observerClipViews) {
        NSRect observerViewFrame = [observerView.window convertRectToScreen:[observerView convertRect:observerView.visibleRect toView:observerView.window.contentView]];
        
        [self setObserverFrame:observerViewFrame forView:observerView];
        [self setObserverState:NSContainsRect(observerViewFrame, popoverFrame) forView:observerView];
    }
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
    if (self.popover == nil) return NSZeroRect;
    
    NSRect popoverFrame = (self.popover.containsArrow) ? [self p_popoverFrame] : [self popoverFrame];
    
    if (self.popover.type == FLOViewPopover) {
        popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
    }
    
    CGFloat popoverOriginX = popoverFrame.origin.x;
    CGFloat popoverOriginY = popoverFrame.origin.y;
    
    if (self.popover.shouldChangeSizeWhenApplicationResizes) {
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

- (void)updateFrameWithContainer:(NSResponder *)container isScrolling:(BOOL)isScrolling {
    if (self.popover == nil) return;
    
    NSRect containerFrame = (container == self.mainWindow) ? self.mainWindow.frame : [self observerFrameForView:(NSClipView *)container];
    
    if (NSEqualRects(containerFrame, NSZeroRect)) return;
    
    NSRect positionScreenFrame = [self getPositionScreenFrame];
    
    if (!NSEqualPoints(_positionScreenFrame.origin, positionScreenFrame.origin)) {
        BOOL containsArrow = self.popover.containsArrow;
        NSRectEdge preferredEdge = _preferredEdge;
        
        // Get the popover frame, maybe the _preferredEdge will be changed when calculates new frame of popover.
        NSRect popoverFrame = (isScrolling ? [self popoverFrameForEdge:_preferredEdge] : (containsArrow ? [self p_popoverFrame] : [self popoverFrame]));
        
        popoverFrame = (NSRect){ .origin = popoverFrame.origin, .size = self.popover.frame.size };
        
        ///
        ///---------------------------------------------------------------------------------------------------------
        /// Update arrow path (hidden or not) if the popover contains arrow as configured when displayed.
        if (containsArrow) {
            // If the positioningView (the sender where arrow is displayed at) move out of containerFrame, we should hide the arrow of popover.
            if (NSEqualRects(NSIntersectionRect(containerFrame, positionScreenFrame), NSZeroRect)) {
                self.backgroundView.arrowSize = NSZeroSize;
                
                [self.backgroundView showArrow:NO];
            } else {
                // If the positioningView (the sender where arrow is displayed at) move inside of containerFrame, we should show the arrow of popover.
                // And also update the arrow position respectively to the new popoverOrigin
                self.backgroundView.arrowSize = self.popover.arrowSize;
                
                if (self.popover.stopsAtContainerBounds || (preferredEdge == _preferredEdge)) {
                    self.backgroundView.popoverOrigin = [self popoverOrigin];
                    
                    [self.backgroundView showArrow:YES];
                } else {
                    [self p_backgroundViewShouldUpdate:YES];
                }
                
                if (preferredEdge != _preferredEdge) {
                    popoverFrame = (isScrolling ? [self popoverFrameForEdge:_preferredEdge] : (containsArrow ? [self p_popoverFrame] : [self popoverFrame]));
                }
            }
        }
        
        BOOL closeIfNeeded = NO;
        
        ///
        ///---------------------------------------------------------------------------------------------------------
        /// Stop the popover when it (or the position view) reach the container bounds.
        if (isScrolling) {
            NSClipView *clipView = (NSClipView *)container;
            BOOL belongsToScrollView = [self observerStateForView:clipView];
            BOOL isNotBelongsToContainer = !NSContainsRect(containerFrame, popoverFrame);
            BOOL isNotContained = ((belongsToScrollView && isNotBelongsToContainer) || (!belongsToScrollView && NSEqualRects(NSIntersectionRect(containerFrame, positionScreenFrame), NSZeroRect)));
            
            closeIfNeeded = (self.popover.closesWhenNotBelongToContainer && isNotContained);
            
            if (!closeIfNeeded) {
                //                [self setObserverState:isNotBelongsToContainer forView:clipView];
                
                if (self.popover.stopsAtContainerBounds && isNotContained) return;
            }
        } else {
            closeIfNeeded = !NSContainsRect(containerFrame, popoverFrame);
        }
        
        ///
        ///---------------------------------------------------------------------------------------------------------
        /// Close the popover if closesWhenNotBelongToContainer is set as YES.
        if (closeIfNeeded && self.popover.closesWhenNotBelongToContainer) {
            [self.popover close];
            
            return;
        }
        
        ///
        ///---------------------------------------------------------------------------------------------------------
        if (self.popover.type == FLOViewPopover) {
            popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
        }
        
        popoverFrame = (NSRect){ .origin = popoverFrame.origin, .size = self.popover.frame.size };
        
        [self.popover updatePopoverFrame:popoverFrame];
        [self setPositionScreenFrame];
    }
}

- (void)updateContentSizeForPopover {
    if (self.popover == nil) return;
    
    if (NSEqualSizes(self.backgroundView.arrowSize, NSZeroSize)) {
        self.contentSize = self.popover.frame.size;
    }
    
    if (!self.popover.containsArrow) {
        if (self.popover.type == FLOWindowPopover) {
            CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentSize popoverEdge:_preferredEdge];
            self.backgroundView.frame = (NSRect){ .size = size };
        }
        
        NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:_preferredEdge];
        self.contentView.frame = contentViewFrame;
    }
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
    return [self windows:parent.childWindows contain:child];
}

- (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window {
    if ([windows containsObject:window]) {
        return YES;
    } else {
        for (NSWindow *item in windows) {
            if ([self windows:item.childWindows contain:window]) {
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
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
        parentView.autoresizesSubviews = YES;
        
        view.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

- (void)addView:(NSView *)view toParent:(NSView *)parentView autoresizingMask:(BOOL)isAutoresizingMask {
    if ((view == nil) || (parentView == nil)) return;
    
    if (![view isDescendantOf:parentView]) {
        [parentView addSubview:view];
        parentView.autoresizesSubviews = YES;
        
        view.translatesAutoresizingMaskIntoConstraints = YES;
    }
    
    if (isAutoresizingMask && [view isDescendantOf:parentView]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        parentView.autoresizesSubviews = YES;
    }
    
    if (isCenterAutoresizingMask && [view isDescendantOf:parentView]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        
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

- (void)registerObserverForClipViews {
    if (self.popover == nil) return;
    
    _observerClipViews = [[NSMutableArray alloc] init];
    _observerClipViewFrames = [[NSMutableDictionary alloc] init];
    _observerClipViewStates = [[NSMutableDictionary alloc] init];
    
    NSView *observerView = [self.positioningAnchorView superview];
    
    while (observerView != nil) {
        if ([observerView isKindOfClass:[NSClipView class]]) {
            [_observerClipViews addObject:(NSClipView *)observerView];
        }
        
        observerView = [observerView superview];
    }
    
    [self setupObserverClipViewValues];
}

#pragma mark - Display utilities

- (void)setupComponentsForPopover {
    if (self.popover == nil) return;
    
    if (NSEqualRects(self.positioningFrame, NSZeroRect)) {
        self.positioningFrame = [self.positioningAnchorView bounds];
    }
    
    self.backgroundView.popoverOrigin = [self popoverOrigin];
    self.originalViewSize = NSEqualSizes(self.originalViewSize, NSZeroSize) ? self.contentView.frame.size : self.originalViewSize;
    self.contentSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.contentView.frame.size : self.contentSize;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSRectEdge popoverEdge = _preferredEdge;
    
    self.backgroundView.borderRadius = self.contentView.layer ? self.contentView.layer.cornerRadius : PopoverBackgroundViewBorderRadius;
    
    [self.backgroundView makeMovable:self.popover.isMovable];
    [self.backgroundView makeDetachable:self.popover.isDetachable];
    
    if (self.popover.shouldShowArrow && (self.positioningView == self.positioningAnchorView)) {
        self.animationBehaviour = FLOPopoverAnimationBehaviorDefault;
        self.animationType = FLOPopoverAnimationDefault;
        
        self.backgroundView.arrowSize = self.popover.arrowSize;
        
        [self.backgroundView showArrow:self.popover.shouldShowArrow];
        [self.backgroundView setArrowColor:self.contentView.layer.backgroundColor];
        
        if (_shouldShowArrowWithVisualEffect) {
            [self.backgroundView showArrowWithVisualEffect:_shouldShowArrowWithVisualEffect material:_arrowVisualEffectMaterial blendingMode:_arrowVisualEffectBlendingMode state:_arrowVisualEffectState];
        }
    } else {
        self.popover.arrowSize = NSZeroSize;
    }
    
    if ([self.popover.representedObject isKindOfClass:[FLOPopoverView class]]) {
        [self.backgroundView showShadow:YES];
    }
    
    if (self.popover.isMovable || self.popover.isDetachable) {
        self.backgroundView.delegate = (id<FLOPopoverViewDelegate>)self.popover;
    }
    
    CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:popoverEdge];
    self.backgroundView.frame = (NSRect){ .size = size };
    self.backgroundView.popoverEdge = popoverEdge;
    
    NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
    self.contentView.frame = contentViewFrame;
    
    NSRect popoverFrame = (self.popover.containsArrow ? [self p_popoverFrame] : [self popoverFrame]);
    
    if ([self.popover.representedObject isKindOfClass:[FLOPopoverView class]]) {
        popoverFrame = [self.presentedWindow convertRectFromScreen:popoverFrame];
    }
    
    // Update arrow edge and content view frame
    if (self.popover.shouldShowArrow && (self.positioningView == self.positioningAnchorView)) {
        [self.backgroundView setAlphaValue:1.0];
        [self p_backgroundViewShouldUpdate:YES];
    }
    
    self.originalViewSize = self.backgroundView.frame.size;
    self.popover.initialFrame = popoverFrame;
    
    [self.popover updatePopoverFrame:popoverFrame];
    
    _verticallyAvailableMargin = self.mainWindow.contentView.visibleRect.size.height + self.popover.bottomOffset - NSMaxY([self.mainWindow convertRectFromScreen:popoverFrame]);
    
    [self setPositionScreenFrame];
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
        if ([_virtualInteractionView isDescendantOf:self.backgroundView]) {
            [_virtualInteractionView removeFromSuperview];
            _virtualInteractionView = nil;
        }
    } else {
        
        if (_virtualInteractionView == nil) {
            _virtualInteractionView = [[FLOVirtualInteractionView alloc] initWithFrame:self.backgroundView.frame];
            [_virtualInteractionView setWantsLayer:YES];
            [_virtualInteractionView.layer setBackgroundColor:[[NSColor.blackColor colorWithAlphaComponent:0.01] CGColor]];
        }
        
        if (![_virtualInteractionView isDescendantOf:self.backgroundView]) {
            [self.backgroundView addSubview:_virtualInteractionView];
        }
    }
}

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    _shouldShowArrowWithVisualEffect = needed;
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

#pragma mark - Shared edge utilities

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
    NSRectEdge edges[] = {NSRectEdgeMinX, NSRectEdgeMaxX, NSRectEdgeMinY, NSRectEdgeMaxY};
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

#pragma mark - Normal edge utilities

- (BOOL)checkPopoverFrameWithEdge:(NSRectEdge)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect frame = [self popoverFrameForEdge:popoverEdge];
    
    return NSContainsRect(containerFrame, frame);
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
    
    if (self.staysInApplicationFrame || !NSEqualSizes(self.backgroundView.arrowSize, NSZeroSize)) {
        while (![self checkPopoverFrameWithEdge:popoverEdge]) {
            popoverEdge = [self containerFrameContainsEdge:_preferredEdge] ? _preferredEdge : [self nextEdgeForEdge:_preferredEdge];
            
            return [self fitFrameToContainer:[self popoverFrameForEdge:popoverEdge]];
        }
    }
    
    return [self popoverFrameForEdge:popoverEdge];
}

#pragma mark - Saving edge utilities

- (void)updatePreferredEdgeForEdge:(NSRectEdge)popoverEdge {
    if ((!self.mainWindowResized || (self.mainWindowResized && [self containerFrameContainsEdge:popoverEdge])) && (_preferredEdge != popoverEdge)) {
        _preferredEdge = popoverEdge;
        
        if (self.popover.containsArrow) {
            [self p_backgroundViewShouldUpdate:YES];
            
            self.originalViewSize = self.backgroundView.frame.size;
        }
    }
}

- (BOOL)p_checkPopoverFrameWithEdge:(NSRectEdge *)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect frame = [self p_popoverFrameForEdge:popoverEdge];
    
    return NSContainsRect(containerFrame, frame);
}

- (NSRect)p_popoverFrameForEdge:(NSRectEdge *)popoverEdge {
    NSRect containerFrame = [self containerFrame];
    NSRect popoverOrigin = [self popoverOrigin];
    
    self.backgroundView.popoverOrigin = popoverOrigin;
    
    NSSize contentViewSize = NSEqualSizes(self.contentSize, NSZeroSize) ? self.originalViewSize : self.contentSize;
    NSPoint anchorPoint = _anchorPoint;
    
    NSSize popoverSize = [self.backgroundView sizeForBackgroundViewWithContentSize:contentViewSize popoverEdge:*popoverEdge];
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
    if (*popoverEdge == NSRectEdgeMinY) {
        CGFloat x0 = NSMinX(popoverOrigin);
        CGFloat x1 = NSMaxX(popoverOrigin) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMinY(popoverOrigin) - popoverSize.height;
        
        if (NSMaxY(frame) < NSMinY(containerFrame)) {
            NSRectEdge nextEdge = [self nextEdgeForEdge:*popoverEdge];
            
            if (nextEdge != *popoverEdge) {
                *popoverEdge = nextEdge;
                
                return [self p_popoverFrameForEdge:popoverEdge];
            }
        }
    } else if (*popoverEdge == NSRectEdgeMaxY) {
        CGFloat x0 = NSMinX(popoverOrigin);
        CGFloat x1 = NSMaxX(popoverOrigin) - contentViewSize.width;
        
        frame.origin.x = x0 + floor((x1 - x0) * anchorPoint.x);
        frame.origin.y = NSMaxY(popoverOrigin);
        
        if (NSMinY(frame) > NSMaxY(containerFrame)) {
            NSRectEdge nextEdge = [self nextEdgeForEdge:*popoverEdge];
            
            if (nextEdge != *popoverEdge) {
                *popoverEdge = nextEdge;
                
                return [self p_popoverFrameForEdge:popoverEdge];
            }
        }
    } else if (*popoverEdge == NSRectEdgeMinX) {
        CGFloat y0 = NSMinY(popoverOrigin);
        CGFloat y1 = NSMaxY(popoverOrigin) - contentViewSize.height;
        
        frame.origin.x = NSMinX(popoverOrigin) - popoverSize.width;
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
        
        if (NSMaxX(frame) < NSMinX(containerFrame)) {
            NSRectEdge nextEdge = [self nextEdgeForEdge:*popoverEdge];
            
            if (nextEdge != *popoverEdge) {
                *popoverEdge = nextEdge;
                
                return [self p_popoverFrameForEdge:popoverEdge];
            }
        }
    } else if (*popoverEdge == NSRectEdgeMaxX) {
        CGFloat y0 = NSMinY(popoverOrigin);
        CGFloat y1 = NSMaxY(popoverOrigin) - contentViewSize.height;
        
        frame.origin.x = NSMaxX(popoverOrigin);
        frame.origin.y = y0 + floor((y1 - y0) * anchorPoint.y);
        
        if (NSMinX(frame) > NSMaxX(containerFrame)) {
            NSRectEdge nextEdge = [self nextEdgeForEdge:*popoverEdge];
            
            if (nextEdge != *popoverEdge) {
                *popoverEdge = nextEdge;
                
                return [self p_popoverFrameForEdge:popoverEdge];
            }
        }
    } else {
        frame = NSZeroRect;
    }
    
    return frame;
}

- (NSRect)p_popoverFrame {
    NSRectEdge popoverEdge = _preferredEdge;
    
    if (self.staysInApplicationFrame || !NSEqualSizes(self.backgroundView.arrowSize, NSZeroSize)) {
        while (![self checkPopoverFrameWithEdge:popoverEdge]) {
            popoverEdge = [self containerFrameContainsEdge:_preferredEdge] ? (((_preferredEdge != _originalEdge) && [self checkPopoverFrameWithEdge:_originalEdge]) ? _originalEdge : _preferredEdge) : [self nextEdgeForEdge:_preferredEdge];
            
            NSRect frame = [self fitFrameToContainer:[self p_popoverFrameForEdge:&popoverEdge]];
            
            [self updatePreferredEdgeForEdge:popoverEdge];
            
            return frame;
        }
        
        NSRectEdge originalEdge = _originalEdge;
        
        if ((_preferredEdge != _originalEdge) && [self checkPopoverFrameWithEdge:originalEdge]) {
            _preferredEdge = _originalEdge;
            
            return [self p_popoverFrame];
        }
    }
    
    NSRect frame = [self p_popoverFrameForEdge:&popoverEdge];
    
    [self updatePreferredEdgeForEdge:popoverEdge];
    
    return frame;
}

- (void)p_backgroundViewShouldUpdate:(BOOL)updated {
    if (updated) {
        NSRectEdge popoverEdge = _preferredEdge;
        CGSize size = [self.backgroundView sizeForBackgroundViewWithContentSize:self.contentView.frame.size popoverEdge:popoverEdge];
        self.backgroundView.frame = (NSRect){ .size = size };
        self.backgroundView.popoverEdge = popoverEdge;
        self.backgroundView.needsDisplay = YES;
        
        NSRect contentViewFrame = [self.backgroundView contentViewFrameForBackgroundFrame:self.backgroundView.bounds popoverEdge:popoverEdge];
        self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
        self.contentView.frame = contentViewFrame;
    }
}

#pragma mark - Event monitor

- (void)registerApplicationActiveNotification {
    if (self.popover == nil) return;
    
    if (self.popover.closesWhenApplicationBecomesInactive) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(eventObserver_applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
}

- (void)removeApplicationActiveNotification {
    if (self.popover == nil) return;
    
    if (self.popover.closesWhenApplicationBecomesInactive) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:NSApplicationDidResignActiveNotification object:NSApp];
        
        self.popover.closesWhenApplicationBecomesInactive = NO;
    }
}

- (void)registerSuperviewObservers {
    if (self.popoverStyle != FLOPopoverStyleNormal) return;
    if (self.popover == nil) return;
    
    if (self.popover.shouldRegisterSuperviewObservers) {
        SEL selector = @selector(eventObserver_viewBoundsDidChange:);
        
        _observerSuperviews = [[NSMutableArray alloc] init];
        
        [_observerSuperviews addObject:self.positioningAnchorView];
        
        [self registerObserverView:self.positioningAnchorView selector:selector source:self];
        
        NSView *observerView = [self.positioningAnchorView superview];
        
        while (observerView != nil) {
            if ([observerView isKindOfClass:[NSView class]]) {
                [_observerSuperviews addObject:observerView];
                
                [self registerObserverView:observerView selector:selector source:self];
            }
            
            observerView = [observerView superview];
        }
    }
    
    if (self.popover.closesWhenApplicationResizes) {
        [self.mainWindow.contentView addObserver:self forKeyPath:@"frame"
                                         options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                                         context:NULL];
    }
}

- (void)unregisterSuperviewObservers {
    if (self.popoverStyle != FLOPopoverStyleNormal) return;
    if (self.popover == nil) return;
    
    if (self.popover.shouldRegisterSuperviewObservers) {
        for (NSView *observerView in _observerSuperviews) {
            @try {
                if ([observerView isKindOfClass:[NSClipView class]]) {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:observerView];
                } else {
                    [observerView removeObserver:self forKeyPath:@"frame"];
                    [observerView removeObserver:self forKeyPath:@"superview"];
                }
            } @catch (NSException *exception) {
                NSLog(@"%s-[%d] exception - reason = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason);
            }
        }
        
        _observerSuperviews = nil;
    }
    
    if (self.popover.closesWhenApplicationResizes) {
        [self.mainWindow.contentView removeObserver:self forKeyPath:@"frame"];
    }
}

- (void)registerWindowEvents {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowDidResize:) name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventObserver_windowWillClose:) name:NSWindowWillCloseNotification object:nil];
}

- (void)removeWindowEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:nil];
}

#pragma mark - Event handling

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.popoverStyle != FLOPopoverStyleNormal) return;
    if (self.popover == nil) return;
    
    if (self.popover.shouldRegisterSuperviewObservers) {
        if ([keyPath isEqualToString:@"superview"] && [object isKindOfClass:[NSView class]]) {
            NSView *view = (NSView *)object;
            
            if ([self popoverShouldCloseForChangedView:view]) {
                [self.popover closePopover:nil];
                
                return;
            }
        }
    }
    
    if ([self mainWindowResized]) {
        NSEvent *event = [NSApp currentEvent];
        
        if (event.type != NSEventTypeLeftMouseDragged) {
            [self updateFrameWithContainer:self.mainWindow isScrolling:NO];
        }
        
        return;
    }
    
    if ([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[NSView class]]) {
        NSView *view = (NSView *)object;
        
        if (view == self.mainWindow.contentView) {
            [self setMainWindowResized:YES];
            
            if (self.popover.closesWhenPopoverResignsKey || self.popover.closesWhenApplicationResizes) {
                [self.popover closePopover:nil];
            }
            
            return;
        }
        
        if (self.popover.shouldRegisterSuperviewObservers) {
            if ([self popoverShouldCloseForChangedView:view]) {
                [self.popover closePopover:nil];
                
                return;
            }
            
            if (!self.popover.popoverShowing && !self.popover.popoverClosing && [self.positioningAnchorView isDescendantOf:view] && !_observerViewBoundsDidChange) {
                [self updateFrameWithContainer:self.mainWindow isScrolling:NO];
            }
        }
    }
}

- (void)eventObserver_viewBoundsDidChange:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSViewBoundsDidChangeNotification] && [notification.object isKindOfClass:[NSClipView class]] && [_observerClipViews containsObject:notification.object])) return;
    if (self.popover == nil) return;
    
    NSClipView *clipView = (NSClipView *)notification.object;
    
    if (!self.popover.popoverShowing && !self.popover.popoverClosing && [self.positioningAnchorView isDescendantOf:clipView]) {
        _observerViewBoundsDidChange = YES;
        
        [self updateFrameWithContainer:clipView isScrolling:YES];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetObserverViewBoundsDidChange) object:nil];
        [self performSelector:@selector(resetObserverViewBoundsDidChange) withObject:nil afterDelay:1.0];
    }
}

- (void)eventObserver_applicationDidResignActive:(NSNotification *)notification {
    if (![notification.name isEqualToString:NSApplicationDidResignActiveNotification]) return;
    if (self.popover == nil) return;
    
    [self.popover close];
}

- (void)eventObserver_windowDidResize:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowDidResizeNotification] && [notification.object isKindOfClass:[NSWindow class]])) return;
    if (self.popover == nil) return;
    
    NSWindow *resizedWindow = (NSWindow *)notification.object;
    
    if (resizedWindow == self.mainWindow) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mainWindowDidEndResize) object:nil];
        [self performSelector:@selector(mainWindowDidEndResize) withObject:nil afterDelay:0.5];
    }
    
    if (!self.popover.popoverShowing && !self.popover.popoverClosing) {
        if ((self.popoverStyle == FLOPopoverStyleAlert) && (resizedWindow == self.presentedWindow)) {
            if (self.popover.type == FLOWindowPopover) {
                NSRect frame = [self.presentedWindow contentRectForFrameRect:self.presentedWindow.frame];
                
                [self.popover updatePopoverFrame:frame];
            }
        } else if ((resizedWindow == self.mainWindow) && !self.popover.closesWhenApplicationResizes) {
            NSRectEdge preferredEdge = _preferredEdge;
            
            NSRect popoverFrame = [self popoverFrameWithResizingWindow:resizedWindow];
            
            // Update arrow edge and content view frame
            BOOL containsArrow = self.popover.containsArrow;
            
            if (containsArrow) {
                NSRect positionScreenFrame = [self getPositionScreenFrame];
                
                positionScreenFrame = NSMakeRect(positionScreenFrame.origin.x, positionScreenFrame.origin.y, 1.0, 1.0);
                
                if (self.popover.stopsAtContainerBounds && !NSContainsRect(resizedWindow.frame, positionScreenFrame)) {
                    // If the positioningView (the sender where arrow is displayed at) move out of containerFrame, we should hide the arrow of popover.
                    if (containsArrow) {
                        self.backgroundView.arrowSize = NSZeroSize;
                        [self.backgroundView showArrow:NO];
                    }
                } else {
                    self.backgroundView.arrowSize = self.popover.arrowSize;
                    
                    [self p_backgroundViewShouldUpdate:YES];
                    
                    if (preferredEdge != _preferredEdge) {
                        self.originalViewSize = self.backgroundView.frame.size;
                        
                        popoverFrame = [self popoverFrameWithResizingWindow:resizedWindow];
                    }
                }
            }
            
            [self.popover updatePopoverFrame:popoverFrame];
            
            [self updateContentSizeForPopover];
            [self setPositionScreenFrame];
            [self setupObserverClipViewValues];
        }
    }
}

- (void)eventObserver_windowWillClose:(NSNotification *)notification {
    if (!([notification.name isEqualToString:NSWindowWillCloseNotification] && [notification.object isKindOfClass:[NSWindow class]])) return;
    if (!([self.popover.representedObject isKindOfClass:[FLOPopoverView class]] || [self.popover.representedObject isKindOfClass:[FLOPopoverWindow class]])) return;
    
    NSWindow *window = (NSWindow *)notification.object;
    BOOL closeNeeded = NO;
    
    if ([self.popover.representedObject isKindOfClass:[FLOPopoverView class]]) {
        FLOPopoverView *popoverView = (FLOPopoverView *)self.popover.representedObject;
        
        closeNeeded = [popoverView isDescendantOf:window.contentView];
    } else {
        FLOPopoverWindow *popoverWindow = (FLOPopoverWindow *)self.popover.representedObject;
        
        closeNeeded = ((window != popoverWindow) && [self window:window contains:popoverWindow]);
    }
    
    if (closeNeeded) {
        [self.popover closePopoverWhileAnimatingIfNeeded:YES];
    }
}

@end
