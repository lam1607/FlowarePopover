//
//  FLOPopover.h
//  FlowarePopover
//
//  Created by Hung Truong on 8/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FLOPopoverConstants.h"

@protocol FLOPopoverDelegate <NSObject>

@optional
- (void)popoverDidShow:(NSResponder *)popover;
- (void)popoverDidClose:(NSResponder *)popover;

@end

@protocol FLOPopoverDelegate;

@interface FLOPopover : NSResponder

@property (weak, readwrite) id<FLOPopoverDelegate> delegate;

/* @Internal agruments
 */
@property (nonatomic, strong, readonly) NSView *contentView;
@property (nonatomic, strong, readonly) NSViewController *contentViewController;
@property (nonatomic, assign, readonly) FLOPopoverType popupType;

/* @Inits
 */
- (id)initWithContentView:(NSView *)contentView;
- (id)initWithContentView:(NSView *)contentView popoverType:(FLOPopoverType)popoverType;
- (id)initWithContentViewController:(NSViewController *)contentViewController;
- (id)initWithContentViewController:(NSViewController *)contentViewController popoverType:(FLOPopoverType)popoverType;

/* @Properties
 */
@property (nonatomic, readonly, getter = isShown) BOOL shown;

@property (nonatomic, assign) BOOL alwaysOnTop;
@property (nonatomic, assign) BOOL shouldShowArrow;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, assign) BOOL closesWhenPopoverResignsKey;
@property (nonatomic, assign) BOOL closesWhenApplicationBecomesInactive;

@property (nonatomic, assign) BOOL animatedWithContext;

/**
 * Make the popover movable.
 */
@property (nonatomic, assign) BOOL popoverMovable;

/**
 * Make the popover detach from its parent window. Only apply for FLOWindowPopover type.
 */
@property (nonatomic, assign) BOOL popoverShouldDetach;

#pragma mark -
#pragma mark - Display
#pragma mark -
/**
 * Set level for popover. Only used for FLOWindowPopover type.
 *
 * @param level the level of window popover.
 */
- (void)setPopoverLevel:(NSWindowLevel)level;

- (void)setAnimationBehaviour:(FLOPopoverAnimationBehaviour)animationBehaviour type:(FLOPopoverAnimationTransition)animationType;

- (void)rearrangePopoverWithNewContentViewFrame:(NSRect)newFrame;
- (void)rearrangePopoverWithNewContentViewFrame:(NSRect)newFrame positioningRect:(NSRect)rect;

/**
 * Display the popover relative to the rect of positioning view
 *
 * @param rect is the rect that popover will be displayed relatively to.
 * @param positioningView is the view that popover will be displayed relatively to.
 * @param edgeType 'position' that the popover should be displayed.
 */
- (void)showRelativeToRect:(NSRect)rect ofView:(NSView *)positioningView edgeType:(FLOPopoverEdgeType)edgeType;

/**
 * Dipslay the popover at the given rect with selected view.
 *
 * @param positioningView the selected view that popover should be displayed at.
 * @param rect the given rect that popover should be displayed at.
 */
- (void)showRelativeToView:(NSView *)positioningView withRect:(NSRect)rect;


#pragma mark -
#pragma mark - Utilities
#pragma mark -
- (IBAction)closePopover:(FLOPopover *)sender;
- (void)closePopover:(FLOPopover *)sender completion:(void(^)(void))complete;

@end
