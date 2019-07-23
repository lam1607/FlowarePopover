//
//  FLOPopover.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopover.h"

#import "FLOPopoverProtocols.h"
#import "FLOViewPopup.h"
#import "FLOWindowPopup.h"


@interface FLOPopover () {
    id<FLOPopoverProtocols> _popover;
    
    NSTimer *_timeIntervalTimer;
}

@property (nonatomic, strong, readwrite) NSView *contentView;
@property (nonatomic, strong, readwrite) NSViewController *contentViewController;
@property (nonatomic, assign, readwrite) FLOPopoverType type;
@property (nonatomic, assign, readwrite) BOOL isMoved;

@end

@implementation FLOPopover

@synthesize type = _type;

#pragma mark - Inits

- (instancetype)initWithContentView:(NSView *)contentView {
    return [self initWithContentView:contentView type:FLOWindowPopover];
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController {
    return [self initWithContentViewController:contentViewController type:FLOWindowPopover];
}

- (instancetype)initWithContentView:(NSView *)contentView type:(FLOPopoverType)type {
    if (self = [super init]) {
        self.contentView = contentView;
        self.type = type;
    }
    
    return self;
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController type:(FLOPopoverType)type {
    if (self = [super init]) {
        self.contentViewController = contentViewController;
        self.type = type;
    }
    
    return self;
}

- (void)dealloc {
    _popover = nil;
    
    self.contentView = nil;
    self.contentViewController = nil;
}

#pragma mark - Getter/Setter

- (NSView *)contentView {
    return _contentView;
}

- (NSViewController *)contentViewController {
    return _contentViewController;
}

- (FLOPopoverType)type {
    return _type;
}

- (NSRect)frame {
    return [_popover frame];
}

- (BOOL)isShown {
    return [_popover isShown];
}

- (BOOL)isCloseEventReceived {
    return _popover.isCloseEventReceived;
}

- (void)setType:(FLOPopoverType)type {
    _type = type;
    
    switch (type) {
        case FLOWindowPopover:
            [self setupPopupWindow];
            break;
        case FLOViewPopover:
            [self setupPopupView];
            break;
        default:
            // default is FLOWindowPopover
            break;
    }
}

- (void)setShouldShowArrow:(BOOL)needed {
    _shouldShowArrow = needed;
    
    _popover.shouldShowArrow = needed;
}

- (void)setArrowSize:(NSSize)arrowSize {
    _arrowSize = arrowSize;
    
    _popover.arrowSize = arrowSize;
}

- (void)setAnimated:(BOOL)animated {
    _animated = animated;
    
    _popover.animated = animated;
}

- (void)setAnimatedForwarding:(BOOL)animatedForwarding {
    _animatedForwarding = animatedForwarding;
    
    _popover.animatedForwarding = animatedForwarding;
}

- (void)setBottomOffset:(CGFloat)bottomOffset {
    _bottomOffset = bottomOffset;
    
    _popover.bottomOffset = bottomOffset;
}

- (void)setStopsAtContainerBounds:(BOOL)stopsAtContainerBounds {
    _stopsAtContainerBounds = stopsAtContainerBounds;
    
    _popover.stopsAtContainerBounds = stopsAtContainerBounds;
}

- (void)setStaysInContainer:(BOOL)staysInContainer {
    _staysInContainer = staysInContainer;
    
    _popover.staysInContainer = staysInContainer;
}

- (void)setUpdatesFrameWhileShowing:(BOOL)updatesFrameWhileShowing {
    _updatesFrameWhileShowing = updatesFrameWhileShowing;
    
    _popover.updatesFrameWhileShowing = updatesFrameWhileShowing;
}

- (void)setShouldRegisterSuperviewObservers:(BOOL)shouldRegisterSuperviewObservers {
    _shouldRegisterSuperviewObservers = shouldRegisterSuperviewObservers;
    
    _popover.shouldRegisterSuperviewObservers = shouldRegisterSuperviewObservers;
}

- (void)setShouldChangeSizeWhenApplicationResizes:(BOOL)shouldChangeSizeWhenApplicationResizes {
    _shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    
    _popover.shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
}

- (void)setClosesWhenPopoverResignsKey:(BOOL)closeWhenResign {
    _closesWhenPopoverResignsKey = closeWhenResign;
    
    _popover.closesWhenPopoverResignsKey = closeWhenResign;
}

- (void)setClosesWhenApplicationBecomesInactive:(BOOL)closeWhenInactive {
    _closesWhenApplicationBecomesInactive = closeWhenInactive;
    
    _popover.closesWhenApplicationBecomesInactive = closeWhenInactive;
}

- (void)setClosesWhenApplicationResizes:(BOOL)closesWhenApplicationResizes {
    _closesWhenApplicationResizes = closesWhenApplicationResizes;
    
    _popover.closesWhenApplicationResizes = closesWhenApplicationResizes;
}

- (void)setClosesWhenNotBelongToContainer:(BOOL)closesWhenNotBelongToContainer {
    _closesWhenNotBelongToContainer = closesWhenNotBelongToContainer;
    
    _popover.closesWhenNotBelongToContainer = closesWhenNotBelongToContainer;
}

- (void)setClosesWhenReceivesEvent:(BOOL)closesWhenReceivesEvent {
    _closesWhenReceivesEvent = closesWhenReceivesEvent;
    
    _popover.closesWhenReceivesEvent = closesWhenReceivesEvent;
}

- (void)setClosesAfterTimeInterval:(NSTimeInterval)closesAfterTimeInterval {
    _closesAfterTimeInterval = closesAfterTimeInterval;
    
    [self cancelCloseAfterTimeInterval];
    [self closeAfterTimeInterval];
}

- (void)setIsMovable:(BOOL)isMovable {
    _isMovable = isMovable;
    
    _popover.isMovable = isMovable;
}

- (void)setIsDetachable:(BOOL)isDetachable {
    _isDetachable = isDetachable;
    
    _popover.isMovable = isDetachable;
    _popover.isDetachable = isDetachable;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
    
    _popover.tag = tag;
}

/**
 * Make transition animation by moving frame of the popover instead of using CALayer.
 */
- (void)setAnimatedByMovingFrame:(BOOL)animatedByMovingFrame {
    _animatedByMovingFrame = animatedByMovingFrame;
    
    _popover.animatedByMovingFrame = animatedByMovingFrame;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    
    _popover.animationDuration = animationDuration;
}

- (void)setNeedsAutoresizingMask:(BOOL)needsAutoresizingMask {
    _needsAutoresizingMask = needsAutoresizingMask;
    
    _popover.needsAutoresizingMask = needsAutoresizingMask;
}

- (void)setResignsFieldsOnClosing:(BOOL)resignsFieldsOnClosing {
    _resignsFieldsOnClosing = resignsFieldsOnClosing;
    
    if ([_popover respondsToSelector:@selector(setResignsFieldsOnClosing:)]) {
        _popover.resignsFieldsOnClosing = resignsFieldsOnClosing;
    }
}

- (void)setBecomesKeyAfterDisplaying:(BOOL)becomesKeyAfterDisplaying {
    _becomesKeyAfterDisplaying = becomesKeyAfterDisplaying;
    
    if ([_popover respondsToSelector:@selector(setBecomesKeyAfterDisplaying:)]) {
        _popover.becomesKeyAfterDisplaying = becomesKeyAfterDisplaying;
    }
}

- (void)setBecomesKeyOnMouseOver:(BOOL)becomesKeyOnMouseOver {
    _becomesKeyOnMouseOver = becomesKeyOnMouseOver;
    
    if ([_popover respondsToSelector:@selector(setBecomesKeyOnMouseOver:)]) {
        _popover.becomesKeyOnMouseOver = becomesKeyOnMouseOver;
    }
}

- (void)setCanBecomeKey:(BOOL)canBecomeKey {
    _canBecomeKey = canBecomeKey;
    
    if ([_popover respondsToSelector:@selector(setCanBecomeKey:)]) {
        _popover.canBecomeKey = canBecomeKey;
    }
}

#pragma mark - Local implementations

- (void)setupPopupView {
    if (_popover == nil) {
        if (self.contentView != nil) {
            _popover = [[FLOViewPopup alloc] initWithContentView:self.contentView];
        } else if (self.contentViewController != nil) {
            _popover = [[FLOViewPopup alloc] initWithContentViewController:self.contentViewController];
        }
        
        if (_popover != nil) {
            [self bindEventsForPopover:_popover];
        }
    }
}

- (void)setupPopupWindow {
    if (_popover == nil) {
        if (self.contentView != nil) {
            _popover = [[FLOWindowPopup alloc] initWithContentView:self.contentView];
        } else if (self.contentViewController != nil) {
            _popover = [[FLOWindowPopup alloc] initWithContentViewController:self.contentViewController];
        }
        
        if (_popover != nil) {
            [self bindEventsForPopover:_popover];
        }
    }
}

- (void)closeAfterTimeInterval {
    if (self.closesAfterTimeInterval > 0) {
        [self performSelector:@selector(close) withObject:nil afterDelay:self.closesAfterTimeInterval];
        
        if (_timeIntervalTimer == nil) {
            _timeIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(closeAfterTimeInterval) userInfo:nil repeats:YES];
        }
    }
}

- (void)cancelCloseAfterTimeInterval {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
}

- (void)invalidateTimeIntervalTimer {
    if (_timeIntervalTimer) {
        [_timeIntervalTimer invalidate];
        
        _timeIntervalTimer = nil;
    }
}

#pragma mark - Binding events

- (void)bindEventsForPopover:(id<FLOPopoverProtocols>)target {
    __weak typeof(self) wself = self;
    __weak typeof(target) wtarget = target;
    
    target.willShowBlock = ^(id<FLOPopoverProtocols> popover) {
        if ((popover == wtarget) && [wself.delegate respondsToSelector:@selector(floPopoverWillShow:)]) {
            [wself.delegate floPopoverWillShow:wself];
        }
    };
    
    target.didShowBlock = ^(id<FLOPopoverProtocols> popover) {
        if (popover == wtarget) {
            if (wself.closesAfterTimeInterval > 0) {
                [wself closeAfterTimeInterval];
            }
            
            if ([wself.delegate respondsToSelector:@selector(floPopoverDidShow:)]) {
                [wself.delegate floPopoverDidShow:wself];
            }
        }
    };
    
    target.willCloseBlock = ^(id<FLOPopoverProtocols> popover) {
        if (popover == wtarget) {
            wself.isMoved = NO;
            
            if ([wself.delegate respondsToSelector:@selector(floPopoverWillClose:)]) {
                [wself.delegate floPopoverWillClose:wself];
            }
        }
    };
    
    target.didCloseBlock = ^(id<FLOPopoverProtocols> popover) {
        if (popover == wtarget) {
            if (wself.closesAfterTimeInterval > 0) {
                wself.closesAfterTimeInterval = 0.0;
                
                [wself invalidateTimeIntervalTimer];
            }
            
            if ([wself.delegate respondsToSelector:@selector(floPopoverDidClose:)]) {
                [wself.delegate floPopoverDidClose:wself];
            }
        }
    };
    
    target.didMoveBlock = ^(id<FLOPopoverProtocols> popover) {
        if (popover == wtarget) {
            wself.isMoved = YES;
            
            if (wself.disableTimeIntervalOnMoving && (wself.closesAfterTimeInterval > 0)) {
                wself.closesAfterTimeInterval = 0.0;
                
                [wself invalidateTimeIntervalTimer];
                
                [NSObject cancelPreviousPerformRequestsWithTarget:wself selector:@selector(close) object:nil];
            }
        }
    };
    
    target.didDetachBlock = ^(id<FLOPopoverProtocols> popover) {
        if (popover == wtarget) {
            wself.animated = NO;
        }
    };
}

#pragma mark - Display

/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level {
    if ([_popover respondsToSelector:@selector(setPopoverLevel:)]) {
        [_popover setPopoverLevel:level];
    }
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType {
    [self setAnimationBehaviour:animationBehaviour type:animationType animatedInAppFrame:NO];
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInAppFrame:(BOOL)animatedInAppFrame {
    [_popover setAnimationBehaviour:animationBehaviour type:animationType animatedInAppFrame:animatedInAppFrame];
}

/**
 * Update the popover to new contentView while it's displaying.
 *
 * @param contentView the new content view needs displayed on the popover.
 */
- (void)setPopoverContentView:(NSView *)contentView {
    self.contentView = contentView;
    
    [_popover setPopoverContentView:contentView];
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    self.contentViewController = contentViewController;
    
    [_popover setPopoverContentViewController:contentViewController];
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    [_popover setPopoverContentViewSize:newSize];
}

- (void)setPopoverPositioningRect:(NSRect)rect {
    [_popover setPopoverPositioningRect:rect];
}

- (void)setPopoverPositioningView:(NSView *)positioningView positioningRect:(NSRect)rect; {
    [_popover setPopoverPositioningView:positioningView positioningRect:rect];
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
    [_popover setPopoverContentViewSize:newSize positioningRect:rect];
}

- (void)setUserInteractionEnable:(BOOL)isEnable {
    if ([_popover respondsToSelector:@selector(setUserInteractionEnable:)]) {
        [_popover setUserInteractionEnable:isEnable];
    }
}

- (void)shouldShowArrowWithVisualEffect:(BOOL)needed material:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    [_popover shouldShowArrowWithVisualEffect:needed material:material blendingMode:blendingMode state:state];
}

/**
 * Sticking rect: Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 *
 * @note rect is bounds of positioningView (should be visibleRect of positioningView).
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    [_popover showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    
    [self invalidateTimeIntervalTimer];
    [self cancelCloseAfterTimeInterval];
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @warning If you provide the wrong positioningView (sender) view, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect {
    [self showRelativeToView:positioningView withRect:rect sender:positioningView relativePositionType:FLOPopoverRelativePositionAutomatic];
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param relativePositionType the specific position that the popover should be displayed relatively to positioningView.
 *
 * @note positioningView is also a sender that sends event for showing the popover (positioningView ≡ sender).
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @note If relativePositionType is FLOPopoverRelativePositionAutomatic. It means that the anchor view constraints will be calculated automatically based on the given frame.
 * @warning If you provide the wrong positioningView, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect relativePositionType:(FLOPopoverRelativePositionType)relativePositionType {
    [self showRelativeToView:positioningView withRect:rect sender:positioningView relativePositionType:relativePositionType];
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param sender view that sends event for showing the popover.
 *
 * @note positioningView and sender are different together.
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @warning If you provide the wrong positioningView, sender, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender {
    [self showRelativeToView:positioningView withRect:rect sender:sender relativePositionType:FLOPopoverRelativePositionAutomatic];
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param sender view that sends event for showing the popover.
 * @param relativePositionType the specific position that the popover should be displayed relatively to positioningView.
 *
 * @note positioningView and sender are different together.
 * @note rect MUST be a value on screen rect (MUST convert to screen rect by [convertRectToScreen:] method).
 * @note If relativePositionType is FLOPopoverRelativePositionAutomatic. It means that the anchor view constraints will be calculated automatically based on the given frame.
 * @warning If you provide the wrong positioningView, sender, or rect, it will lead the strange behaviour on showing.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect sender:(NSView *)sender relativePositionType:(FLOPopoverRelativePositionType)relativePositionType {
    [_popover showRelativeToView:positioningView withRect:rect sender:sender relativePositionType:relativePositionType edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    
    [self invalidateTimeIntervalTimer];
    [self cancelCloseAfterTimeInterval];
}

/**
 * Display popover as system alert style for presented window.
 *
 * @param presentedWindow the target window that the popover will be alerted on.
 */
- (void)showWithAlertStyleForWindow:(NSWindow *)presentedWindow {
    if ([_popover respondsToSelector:@selector(showWithAlertStyleForWindow:)]) {
        [_popover showWithAlertStyleForWindow:presentedWindow];
        
        [self invalidateTimeIntervalTimer];
        [self cancelCloseAfterTimeInterval];
    }
}

- (void)close {
    [_popover close];
}

@end
