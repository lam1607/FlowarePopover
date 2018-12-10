//
//  FLOPopover.m
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOPopover.h"

#import "FLOViewPopup.h"
#import "FLOWindowPopup.h"

#pragma mark - FLOPopoverView

@implementation FLOPopoverView

@synthesize tag = _tag;

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
    }
    
    return self;
}

@end

#pragma mark - FLOPopoverWindow

@implementation FLOPopoverWindow

- (instancetype)init {
    if (self = [super init]) {
        _tag = -1;
    }
    
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return self.canBecomeKey;
}

@end

#pragma mark - FLOPopover

@interface FLOPopover ()

@property (nonatomic, strong) FLOWindowPopup<FLOPopoverService> *windowPopup;
@property (nonatomic, strong) FLOViewPopup<FLOPopoverService> *viewPopup;

@property (nonatomic, strong, readwrite) NSView *contentView;
@property (nonatomic, strong, readwrite) NSViewController *contentViewController;
@property (nonatomic, assign, readwrite) FLOPopoverType type;

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
    self.windowPopup = nil;
    self.viewPopup = nil;
    
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
    if (self.type == FLOWindowPopover) {
        return [self.windowPopup frame];
    }
    
    return [self.viewPopup frame];
}

- (BOOL)isShown {
    if (self.type == FLOWindowPopover) {
        return [self.windowPopup isShown];
    }
    
    return [self.viewPopup isShown];
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
            // default is FLOViewPopover
            break;
    }
}

- (void)setAlwaysOnTop:(BOOL)alwaysOnTop {
    [self restartPopupIfNeeded];
    
    _alwaysOnTop = alwaysOnTop;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.alwaysOnTop = alwaysOnTop;
    } else {
        self.viewPopup.alwaysOnTop = alwaysOnTop;
    }
}

- (void)setShouldShowArrow:(BOOL)needed {
    [self restartPopupIfNeeded];
    
    _shouldShowArrow = needed;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.shouldShowArrow = needed;
    } else {
        self.viewPopup.shouldShowArrow = needed;
    }
}

- (void)setAnimated:(BOOL)animated {
    [self restartPopupIfNeeded];
    
    _animated = animated;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animated = animated;
    } else {
        self.viewPopup.animated = animated;
    }
}

- (void)setAnimatedForwarding:(BOOL)animatedForwarding {
    [self restartPopupIfNeeded];
    
    _animatedForwarding = animatedForwarding;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animatedForwarding = animatedForwarding;
    } else {
        self.viewPopup.animatedForwarding = animatedForwarding;
    }
}

- (void)setStaysInApplicationRect:(BOOL)staysInApplicationRect {
    _staysInApplicationRect = staysInApplicationRect;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.staysInApplicationRect = staysInApplicationRect;
    } else {
        self.viewPopup.staysInApplicationRect = staysInApplicationRect;
    }
}

- (void)setUpdatesFrameWhileShowing:(BOOL)updatesFrameWhileShowing {
    _updatesFrameWhileShowing = updatesFrameWhileShowing;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.updatesFrameWhileShowing = updatesFrameWhileShowing;
    } else {
        self.viewPopup.updatesFrameWhileShowing = updatesFrameWhileShowing;
    }
}

- (void)setShouldRegisterSuperviewObservers:(BOOL)shouldRegisterSuperviewObservers {
    [self restartPopupIfNeeded];
    
    _shouldRegisterSuperviewObservers = shouldRegisterSuperviewObservers;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.shouldRegisterSuperviewObservers = shouldRegisterSuperviewObservers;
    } else {
        self.viewPopup.shouldRegisterSuperviewObservers = shouldRegisterSuperviewObservers;
    }
}

- (void)setShouldChangeSizeWhenApplicationResizes:(BOOL)shouldChangeSizeWhenApplicationResizes {
    [self restartPopupIfNeeded];
    
    _shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    } else {
        self.viewPopup.shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    }
}

- (void)setClosesWhenPopoverResignsKey:(BOOL)closeWhenResign {
    [self restartPopupIfNeeded];
    
    _closesWhenPopoverResignsKey = closeWhenResign;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenPopoverResignsKey = closeWhenResign;
    } else {
        self.viewPopup.closesWhenPopoverResignsKey = closeWhenResign;
    }
}

- (void)setClosesWhenApplicationBecomesInactive:(BOOL)closeWhenInactive {
    [self restartPopupIfNeeded];
    
    _closesWhenApplicationBecomesInactive = closeWhenInactive;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
    } else {
        self.viewPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
    }
}

- (void)setClosesWhenApplicationResizes:(BOOL)closesWhenApplicationResizes {
    [self restartPopupIfNeeded];
    
    _closesWhenApplicationResizes = closesWhenApplicationResizes;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
    } else {
        self.viewPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
    }
}

- (void)setClosesAfterTimeInterval:(NSTimeInterval)closesAfterTimeInterval {
    [self restartPopupIfNeeded];
    
    _closesAfterTimeInterval = closesAfterTimeInterval;
    
    [self closeAfterTimeInterval];
}

/**
 * Make Popover window key as possible when mouse entered to popover.
 * @note Becareful when using this property. If you have some views also implemented the
 * [mouseEntered:], [mouseExited:] methods. It might lead some unexpected behaviours.
 */
- (void)setMakeKeyWindowOnMouseEvents:(BOOL)makeKeyWindowOnMouseEvents {
    _makeKeyWindowOnMouseEvents = makeKeyWindowOnMouseEvents;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.makeKeyWindowOnMouseEvents = makeKeyWindowOnMouseEvents;
    } else {
        self.viewPopup.makeKeyWindowOnMouseEvents = makeKeyWindowOnMouseEvents;
    }
}

- (void)setIsMovable:(BOOL)isMovable {
    [self restartPopupIfNeeded];
    
    _isMovable = isMovable;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.isMovable = isMovable;
    } else {
        self.viewPopup.isMovable = isMovable;
    }
}

- (void)setIsDetachable:(BOOL)isDetachable {
    [self restartPopupIfNeeded];
    
    _isDetachable = isDetachable;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.isMovable = isDetachable;
        self.windowPopup.isDetachable = isDetachable;
    } else {
        self.viewPopup.isMovable = isDetachable;
        self.viewPopup.isDetachable = isDetachable;
    }
}

- (void)setCanBecomeKey:(BOOL)canBecomeKey {
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        _canBecomeKey = canBecomeKey;
        
        self.windowPopup.canBecomeKey = canBecomeKey;
    }
}

- (void)setTag:(NSInteger)tag {
    [self restartPopupIfNeeded];
    
    _tag = tag;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.tag = tag;
    } else {
        self.viewPopup.tag = tag;
    }
}

/**
 * Make transition animation by moving frame of the popover instead of using CALayer.
 */
- (void)setAnimatedByMovingFrame:(BOOL)animatedByMovingFrame {
    [self restartPopupIfNeeded];
    
    _animatedByMovingFrame = animatedByMovingFrame;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animatedByMovingFrame = animatedByMovingFrame;
    } else {
        self.viewPopup.animatedByMovingFrame = animatedByMovingFrame;
    }
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    [self restartPopupIfNeeded];
    
    _animationDuration = animationDuration;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animationDuration = animationDuration;
    } else {
        self.viewPopup.animationDuration = animationDuration;
    }
}

#pragma mark - Local implementations

- (void)setupPopupView {
    if (self.viewPopup == nil) {
        self.viewPopup = [[FLOViewPopup alloc] initWithContentView:self.contentViewController.view];
        [self bindEventsForPopover:self.viewPopup];
    }
}

- (void)setupPopupWindow {
    if (self.windowPopup == nil) {
        self.windowPopup = [[FLOWindowPopup alloc] initWithContentViewController:self.contentViewController];
        [self bindEventsForPopover:self.windowPopup];
    }
}

- (void)restartPopupIfNeeded {
    switch (self.type) {
        case FLOWindowPopover:
            if (self.windowPopup == nil) {
                [self setupPopupWindow];
                [self restorePopupValues:self.windowPopup];
            }
            break;
        case FLOViewPopover:
            if (self.viewPopup == nil) {
                [self setupPopupView];
                [self restorePopupValues:self.viewPopup];
            }
            break;
        default:
            // default is FLOViewPopover
            break;
    }
}

- (void)storePopupValues:(NSResponder *)popover {
    if ([popover isKindOfClass:[FLOViewPopup class]] && (self.type == FLOViewPopover)) {
        FLOViewPopup *viewPopup = (FLOViewPopup *)popover;
        
        self.alwaysOnTop = viewPopup.alwaysOnTop;
        self.shouldShowArrow = viewPopup.shouldShowArrow;
        self.animated = viewPopup.animated;
        self.animatedForwarding = viewPopup.animatedForwarding;
        self.staysInApplicationRect = viewPopup.staysInApplicationRect;
        self.updatesFrameWhileShowing = viewPopup.updatesFrameWhileShowing;
        self.makeKeyWindowOnMouseEvents = viewPopup.makeKeyWindowOnMouseEvents;
        self.shouldRegisterSuperviewObservers = viewPopup.shouldRegisterSuperviewObservers;
        self.shouldChangeSizeWhenApplicationResizes = viewPopup.shouldChangeSizeWhenApplicationResizes;
        self.closesWhenPopoverResignsKey = viewPopup.closesWhenPopoverResignsKey;
        self.closesWhenApplicationBecomesInactive = viewPopup.closesWhenApplicationBecomesInactive;
        self.closesWhenApplicationResizes = viewPopup.closesWhenApplicationResizes;
        self.isMovable = viewPopup.isMovable;
        self.isDetachable = viewPopup.isDetachable;
        self.tag = viewPopup.tag;
        self.animatedByMovingFrame = viewPopup.animatedByMovingFrame;
        self.animationDuration = viewPopup.animationDuration;
        
        self.viewPopup = nil;
    } else if ([popover isKindOfClass:[FLOWindowPopup class]] && (self.type == FLOWindowPopover)) {
        FLOWindowPopup *windowPopup = (FLOWindowPopup *)popover;
        
        self.alwaysOnTop = windowPopup.alwaysOnTop;
        self.shouldShowArrow = windowPopup.shouldShowArrow;
        self.animated = windowPopup.animated;
        self.animatedForwarding = windowPopup.animatedForwarding;
        self.staysInApplicationRect = windowPopup.staysInApplicationRect;
        self.updatesFrameWhileShowing = windowPopup.updatesFrameWhileShowing;
        self.makeKeyWindowOnMouseEvents = windowPopup.makeKeyWindowOnMouseEvents;
        self.shouldRegisterSuperviewObservers = windowPopup.shouldRegisterSuperviewObservers;
        self.shouldChangeSizeWhenApplicationResizes = windowPopup.shouldChangeSizeWhenApplicationResizes;
        self.closesWhenPopoverResignsKey = windowPopup.closesWhenPopoverResignsKey;
        self.closesWhenApplicationBecomesInactive = windowPopup.closesWhenApplicationBecomesInactive;
        self.closesWhenApplicationResizes = windowPopup.closesWhenApplicationResizes;
        self.isMovable = windowPopup.isMovable;
        self.isDetachable = windowPopup.isDetachable;
        self.canBecomeKey = windowPopup.canBecomeKey;
        self.tag = windowPopup.tag;
        self.animatedByMovingFrame = windowPopup.animatedByMovingFrame;
        self.animationDuration = windowPopup.animationDuration;
        
        self.windowPopup = nil;
    }
}

- (void)restorePopupValues:(NSResponder *)popover {
    if ([popover isKindOfClass:[FLOViewPopup class]] && (self.type == FLOViewPopover)) {
        FLOViewPopup *viewPopup = (FLOViewPopup *)popover;
        
        viewPopup.alwaysOnTop = self.alwaysOnTop;
        viewPopup.shouldShowArrow = self.shouldShowArrow;
        viewPopup.animated = self.animated;
        viewPopup.animatedForwarding = self.animatedForwarding;
        viewPopup.staysInApplicationRect = self.staysInApplicationRect;
        viewPopup.updatesFrameWhileShowing = self.updatesFrameWhileShowing;
        viewPopup.makeKeyWindowOnMouseEvents = self.makeKeyWindowOnMouseEvents;
        viewPopup.shouldRegisterSuperviewObservers = self.shouldRegisterSuperviewObservers;
        viewPopup.shouldChangeSizeWhenApplicationResizes = self.shouldChangeSizeWhenApplicationResizes;
        viewPopup.closesWhenPopoverResignsKey = self.closesWhenPopoverResignsKey;
        viewPopup.closesWhenApplicationBecomesInactive = self.closesWhenApplicationBecomesInactive;
        viewPopup.closesWhenApplicationResizes = self.closesWhenApplicationResizes;
        viewPopup.isMovable = self.isMovable;
        viewPopup.isDetachable = self.isDetachable;
        viewPopup.tag = self.tag;
        viewPopup.animatedByMovingFrame = self.animatedByMovingFrame;
        viewPopup.animationDuration = self.animationDuration;
    } else if ([popover isKindOfClass:[FLOWindowPopup class]] && (self.type == FLOWindowPopover)) {
        FLOWindowPopup *windowPopup = (FLOWindowPopup *)popover;
        
        windowPopup.alwaysOnTop = self.alwaysOnTop;
        windowPopup.shouldShowArrow = self.shouldShowArrow;
        windowPopup.animated = self.animated;
        windowPopup.animatedForwarding = self.animatedForwarding;
        windowPopup.staysInApplicationRect = self.staysInApplicationRect;
        windowPopup.updatesFrameWhileShowing = self.updatesFrameWhileShowing;
        windowPopup.makeKeyWindowOnMouseEvents = self.makeKeyWindowOnMouseEvents;
        windowPopup.shouldRegisterSuperviewObservers = self.shouldRegisterSuperviewObservers;
        windowPopup.shouldChangeSizeWhenApplicationResizes = self.shouldChangeSizeWhenApplicationResizes;
        windowPopup.closesWhenPopoverResignsKey = self.closesWhenPopoverResignsKey;
        windowPopup.closesWhenApplicationBecomesInactive = self.closesWhenApplicationBecomesInactive;
        windowPopup.closesWhenApplicationResizes = self.closesWhenApplicationResizes;
        windowPopup.isMovable = self.isMovable;
        windowPopup.isDetachable = self.isDetachable;
        windowPopup.canBecomeKey = self.canBecomeKey;
        windowPopup.tag = self.tag;
        windowPopup.animatedByMovingFrame = self.animatedByMovingFrame;
        windowPopup.animationDuration = self.animationDuration;
    }
}

#pragma mark - Binding events

- (void)bindEventsForPopover:(NSResponder<FLOPopoverService> *)target {
    __weak typeof(self) wself = self;
    
    target.willShowBlock = ^(NSResponder *popover) {
        if ((popover == target) && [wself.delegate respondsToSelector:@selector(floPopoverWillShow:)]) {
            [wself.delegate floPopoverWillShow:self];
        }
    };
    
    target.didShowBlock = ^(NSResponder *popover) {
        if ((popover == target) && [wself.delegate respondsToSelector:@selector(floPopoverDidShow:)]) {
            [wself.delegate floPopoverDidShow:self];
        }
    };
    
    target.willCloseBlock = ^(NSResponder *popover) {
        if ((popover == target) && [wself.delegate respondsToSelector:@selector(floPopoverWillClose:)]) {
            [wself.delegate floPopoverWillClose:self];
        }
    };
    
    target.didCloseBlock = ^(NSResponder *popover) {
        if ((popover == target) && [wself.delegate respondsToSelector:@selector(floPopoverDidClose:)]) {
            [wself storePopupValues:popover];
            [wself.delegate floPopoverDidClose:self];
        }
    };
    
    target.didMoveBlock = ^(NSResponder *popover) {
        if ((popover == target) && (wself.closesAfterTimeInterval > 0)) {
            wself.closesAfterTimeInterval = 0.0;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:wself selector:@selector(close) object:nil];
        }
    };
    
    target.didDetachBlock = ^(NSResponder *popover) {
        if (popover == target) {
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
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverLevel:level];
    }
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType {
    [self setAnimationBehaviour:animationBehaviour type:animationType animatedInApplicationRect:NO];
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInApplicationRect:(BOOL)animatedInApplicationRect {
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setAnimationBehaviour:animationBehaviour type:animationType animatedInApplicationRect:animatedInApplicationRect];
    } else {
        [self.viewPopup setAnimationBehaviour:animationBehaviour type:animationType animatedInApplicationRect:animatedInApplicationRect];
    }
}

/**
 * Update the popover to new contentView while it's displaying.
 *
 * @param contentView the new content view needs displayed on the popover.
 */
- (void)setPopoverContentView:(NSView *)contentView {
    [self restartPopupIfNeeded];
    
    self.contentView = contentView;
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentView:contentView];
    } else {
        [self.viewPopup setPopoverContentView:contentView];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
    [self restartPopupIfNeeded];
    
    self.contentViewController = contentViewController;
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewController:contentViewController];
    } else {
        [self.viewPopup setPopoverContentViewController:contentViewController];
    }
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewSize:newSize];
    } else {
        [self.viewPopup setPopoverContentViewSize:newSize];
    }
}

- (void)setPopoverPositioningRect:(NSRect)rect {
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverPositioningRect:rect];
    } else {
        [self.viewPopup setPopoverPositioningRect:rect];
    }
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewSize:newSize positioningRect:rect];
    } else {
        [self.viewPopup setPopoverContentViewSize:newSize positioningRect:rect];
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
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    } else {
        [self.viewPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    }
    
    [self closeAfterTimeInterval];
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
    [self restartPopupIfNeeded];
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup showRelativeToView:positioningView withRect:rect sender:sender relativePositionType:relativePositionType edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    } else {
        [self.viewPopup showRelativeToView:positioningView withRect:rect sender:sender relativePositionType:relativePositionType edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    }
    
    [self closeAfterTimeInterval];
}

- (void)closeAfterTimeInterval {
    if (self.closesAfterTimeInterval > 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(close) object:nil];
        [self performSelector:@selector(close) withObject:nil afterDelay:self.closesAfterTimeInterval];
    }
}

- (void)close {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup close];
    } else {
        [self.viewPopup close];
    }
}

@end
