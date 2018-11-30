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

- (void)setupPopupView {
    if (!self.viewPopup) {
        self.viewPopup = [[FLOViewPopup alloc] initWithContentView:self.contentViewController.view];
        [self bindEventsForPopover:self.viewPopup];
    }
}

- (void)setupPopupWindow {
    if (!self.windowPopup) {
        self.windowPopup = [[FLOWindowPopup alloc] initWithContentViewController:self.contentViewController];
        [self bindEventsForPopover:self.windowPopup];
    }
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
    _alwaysOnTop = alwaysOnTop;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.alwaysOnTop = alwaysOnTop;
    } else {
        self.viewPopup.alwaysOnTop = alwaysOnTop;
    }
}

- (void)setShouldShowArrow:(BOOL)needed {
    _shouldShowArrow = needed;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.shouldShowArrow = needed;
    } else {
        self.viewPopup.shouldShowArrow = needed;
    }
}

- (void)setAnimated:(BOOL)animated {
    _animated = animated;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animated = animated;
    } else {
        self.viewPopup.animated = animated;
    }
}

- (void)setAnimatedForwarding:(BOOL)animatedForwarding {
    _animatedForwarding = animatedForwarding;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.animatedForwarding = animatedForwarding;
    } else {
        self.viewPopup.animatedForwarding = animatedForwarding;
    }
}

- (void)setShouldChangeSizeWhenApplicationResizes:(BOOL)shouldChangeSizeWhenApplicationResizes {
    _shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    } else {
        self.viewPopup.shouldChangeSizeWhenApplicationResizes = shouldChangeSizeWhenApplicationResizes;
    }
}

- (void)setClosesWhenPopoverResignsKey:(BOOL)closeWhenResign {
    _closesWhenPopoverResignsKey = closeWhenResign;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenPopoverResignsKey = closeWhenResign;
    } else {
        self.viewPopup.closesWhenPopoverResignsKey = closeWhenResign;
    }
}

- (void)setClosesWhenApplicationBecomesInactive:(BOOL)closeWhenInactive {
    _closesWhenApplicationBecomesInactive = closeWhenInactive;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
    } else {
        self.viewPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
    }
}

- (void)setClosesWhenApplicationResizes:(BOOL)closesWhenApplicationResizes {
    _closesWhenApplicationResizes = closesWhenApplicationResizes;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
    } else {
        self.viewPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
    }
}

- (void)setClosesAfterTimeInterval:(NSTimeInterval)closesAfterTimeInterval {
    _closesAfterTimeInterval = closesAfterTimeInterval;
    
    [self closeAfterTimeInterval];
}

- (void)setIsMovable:(BOOL)isMovable {
    _isMovable = isMovable;
    
    if (self.type == FLOWindowPopover) {
        self.windowPopup.isMovable = isMovable;
    } else {
        self.viewPopup.isMovable = isMovable;
    }
}

- (void)setIsDetachable:(BOOL)isDetachable {
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
    if (self.type == FLOWindowPopover) {
        _canBecomeKey = canBecomeKey;
        
        self.windowPopup.canBecomeKey = canBecomeKey;
    }
}

- (void)setTag:(NSInteger)tag {
    if (self.type == FLOWindowPopover) {
        _tag = tag;
        
        self.windowPopup.tag = tag;
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
            [wself.delegate floPopoverDidClose:self];
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
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverLevel:level];
    }
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType {
    [self setAnimationBehaviour:animationBehaviour type:animationType animatedInDisplayRect:NO];
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationType)animationType animatedInDisplayRect:(BOOL)animatedInDisplayRect {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setAnimationBehaviour:animationBehaviour type:animationType animatedInDisplayRect:animatedInDisplayRect];
    } else {
        [self.viewPopup setAnimationBehaviour:animationBehaviour type:animationType animatedInDisplayRect:animatedInDisplayRect];
    }
}

/**
 * Update the popover to new contentView while it's displaying.
 *
 * @param contentView the new content view needs displayed on the popover.
 */
- (void)setPopoverContentView:(NSView *)contentView {
    self.contentView = contentView;
    
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentView:contentView];
    } else {
        [self.viewPopup setPopoverContentView:contentView];
    }
}

- (void)setPopoverContentViewController:(NSViewController *)contentViewController {
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
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewSize:newSize];
    } else {
        [self.viewPopup setPopoverContentViewSize:newSize];
    }
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
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
