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
@property (nonatomic, assign, readwrite) FLOPopoverType popupType;

@end

@implementation FLOPopover

@synthesize popupType = _popupType;

#pragma mark - Inits

- (instancetype)initWithContentView:(NSView *)contentView {
    return [self initWithContentView:contentView popoverType:FLOViewPopover];
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController {
    return [self initWithContentViewController:contentViewController popoverType:FLOViewPopover];
}

- (instancetype)initWithContentView:(NSView *)contentView popoverType:(FLOPopoverType)popoverType {
    if (self = [super init]) {
        self.contentView = contentView;
        self.popupType = popoverType;
    }
    
    return self;
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController popoverType:(FLOPopoverType)popoverType {
    if (self = [super init]) {
        self.contentViewController = contentViewController;
        self.popupType = popoverType;
    }
    
    return self;
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

- (BOOL)isShown {
    if (self.popupType == FLOWindowPopover) {
        return [self.windowPopup isShown];
    }
    
    return [self.viewPopup isShown];
}

- (NSView *)contentView {
    return _contentView;
}

- (NSViewController *)contentViewController {
    return _contentViewController;
}

- (FLOPopoverType)popupType {
    return _popupType;
}

- (void)setPopupType:(FLOPopoverType)popupType {
    _popupType = popupType;
    
    switch (popupType) {
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
    
    self.viewPopup.alwaysOnTop = alwaysOnTop;
    self.windowPopup.alwaysOnTop = alwaysOnTop;
}

- (void)setShouldShowArrow:(BOOL)needed {
    _shouldShowArrow = needed;
    
    self.viewPopup.shouldShowArrow = needed;
    self.windowPopup.shouldShowArrow = needed;
}

- (void)setAnimated:(BOOL)animated {
    _animated = animated;
    
    self.viewPopup.animated = animated;
    self.windowPopup.animated = animated;
}

- (void)setAnimatedForwarding:(BOOL)animatedForwarding {
    _animatedForwarding = animatedForwarding;
    
    self.viewPopup.animatedForwarding = animatedForwarding;
    self.windowPopup.animatedForwarding = animatedForwarding;
}

- (void)setShouldChangeFrameWhenApplicationResizes:(BOOL)shouldChangeFrameWhenApplicationResizes {
    _shouldChangeFrameWhenApplicationResizes = shouldChangeFrameWhenApplicationResizes;
    
    self.viewPopup.shouldChangeFrameWhenApplicationResizes = shouldChangeFrameWhenApplicationResizes;
    self.windowPopup.shouldChangeFrameWhenApplicationResizes = shouldChangeFrameWhenApplicationResizes;
}

- (void)setClosesWhenPopoverResignsKey:(BOOL)closeWhenResign {
    _closesWhenPopoverResignsKey = closeWhenResign;
    
    self.viewPopup.closesWhenPopoverResignsKey = closeWhenResign;
    self.windowPopup.closesWhenPopoverResignsKey = closeWhenResign;
}

- (void)setClosesWhenApplicationBecomesInactive:(BOOL)closeWhenInactive {
    _closesWhenApplicationBecomesInactive = closeWhenInactive;
    
    self.viewPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
    self.windowPopup.closesWhenApplicationBecomesInactive = closeWhenInactive;
}

- (void)setClosesWhenApplicationResizes:(BOOL)closesWhenApplicationResizes {
    _closesWhenApplicationResizes = closesWhenApplicationResizes;
    
    self.viewPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
    self.windowPopup.closesWhenApplicationResizes = closesWhenApplicationResizes;
}

- (void)setPopoverMovable:(BOOL)popoverMovable {
    _popoverMovable = popoverMovable;
    
    self.viewPopup.popoverMovable = popoverMovable;
    self.windowPopup.popoverMovable = popoverMovable;
}

- (void)setPopoverShouldDetach:(BOOL)popoverShouldDetach {
    if (self.popupType == FLOWindowPopover) {
        _popoverShouldDetach = popoverShouldDetach;
        
        self.windowPopup.popoverMovable = popoverShouldDetach;
        self.windowPopup.popoverShouldDetach = popoverShouldDetach;
    }
}

- (void)setCanBecomeKey:(BOOL)canBecomeKey {
    if (self.popupType == FLOWindowPopover) {
        _canBecomeKey = canBecomeKey;
        
        self.windowPopup.canBecomeKey = canBecomeKey;
    }
}

#pragma mark - Binding events

- (void)bindEventsForPopover:(NSResponder<FLOPopoverService> *)popover {
    __weak typeof(self) wSelf = self;
    
    popover.popoverDidShowCallback = ^(NSResponder *popover) {
        if ([wSelf.delegate respondsToSelector:@selector(floPopoverDidShow:)]) {
            [wSelf.delegate floPopoverDidShow:self];
        }
    };
    
    popover.popoverDidCloseCallback = ^(NSResponder *popover) {
        if ([wSelf.delegate respondsToSelector:@selector(floPopoverDidClose:)]) {
            [wSelf.delegate floPopoverDidClose:self];
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
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup setPopoverLevel:level];
    }
}

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType {
    [self.viewPopup setAnimationBehaviour:animationBehaviour type:animationType];
    [self.windowPopup setAnimationBehaviour:animationBehaviour type:animationType];
}

/**
 * Re-arrange the popover with new content view size.
 *
 * @param newSize new size of content view.
 */
- (void)setPopoverContentViewSize:(NSSize)newSize {
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewSize:newSize];
    } else {
        [self.viewPopup setPopoverContentViewSize:newSize];
    }
}

- (void)setPopoverContentViewSize:(NSSize)newSize positioningRect:(NSRect)rect {
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup setPopoverContentViewSize:newSize positioningRect:rect];
    } else {
        [self.viewPopup setPopoverContentViewSize:newSize positioningRect:rect];
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
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    } else {
        [self.viewPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    }
}

/**
 * Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed at.
 * @param rect the given rect that popover should be displayed at.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect {
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup showRelativeToView:positioningView withRect:rect edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    } else {
        [self.viewPopup showRelativeToView:positioningView withRect:rect edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    }
}

- (void)close {
    if (self.popupType == FLOWindowPopover) {
        [self.windowPopup close];
    } else {
        [self.viewPopup close];
    }
}

@end
