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
@property (nonatomic, assign, readwrite) FLOPopoverType type;

@end

@implementation FLOPopover

@synthesize type = _type;

#pragma mark - Inits

- (instancetype)initWithContentView:(NSView *)contentView {
    return [self initWithContentView:contentView type:FLOViewPopover];
}

- (instancetype)initWithContentViewController:(NSViewController *)contentViewController {
    return [self initWithContentViewController:contentViewController type:FLOViewPopover];
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
    if (self.type == FLOWindowPopover) {
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

- (FLOPopoverType)type {
    return _type;
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

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup setAnimationBehaviour:animationBehaviour type:animationType];
    } else {
        [self.viewPopup setAnimationBehaviour:animationBehaviour type:animationType];
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
 * Sticker rect: Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    } else {
        [self.viewPopup showRelativeToRect:rect ofView:positioningView edgeType:edgeType];
    }
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup showRelativeToView:positioningView withRect:rect anchorType:FLOPopoverAnchorTopPositiveLeadingPositive edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    } else {
        [self.viewPopup showRelativeToView:positioningView withRect:rect anchorType:FLOPopoverAnchorTopPositiveLeadingPositive edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    }
}

/**
 * Given rect: Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed relatively at.
 * @param rect the given rect that popover should be displayed at.
 * @param anchorType type of anchor that the anchor view will stick to the positioningView ((top, leading) | (top, trailing), (bottom, leading), (bottom, trailing)).
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect anchorType:(FLOPopoverAnchorType)anchorType {
    if (self.type == FLOWindowPopover) {
        [self.windowPopup showRelativeToView:positioningView withRect:rect anchorType:anchorType edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
    } else {
        [self.viewPopup showRelativeToView:positioningView withRect:rect anchorType:anchorType edgeType:FLOPopoverEdgeTypeBelowLeftEdge];
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
