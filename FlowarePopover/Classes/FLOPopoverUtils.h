//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLOPopoverConstants.h"

@class FLOPopoverBackgroundView;

@interface FLOPopoverUtils : NSObject

#pragma mark - Properties

@property (nonatomic, strong, readonly) NSWindow *appMainWindow;

@property (nonatomic, strong, readonly) NSWindow *topWindow;
@property (nonatomic, strong, readonly) NSView *topView;

@property (nonatomic, assign, readonly) BOOL appMainWindowResized;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign) BOOL popoverMoved;

@property (nonatomic, assign) BOOL staysInApplicationRect;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationType animationType;
@property (nonatomic, assign) BOOL animatedInApplicationRect;

@property (nonatomic, assign) BOOL needAutoresizingMask;

@property (nonatomic, strong) NSView *positioningAnchorView;
@property (nonatomic, strong) NSView *senderView;
@property (nonatomic, assign) FLOPopoverRelativePositionType relativePositionType;
@property (nonatomic, assign) NSRect positioningWindowRect;
@property (nonatomic, strong) NSMutableArray<NSView *> *anchorSuperviews;

@property (nonatomic, strong) FLOPopoverBackgroundView *backgroundView;
@property (nonatomic, assign) NSRect positioningRect;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic) NSRectEdge preferredEdge;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize originalViewSize;
@property (nonatomic, assign) CGFloat verticalMarginOutOfPopover;


+ (FLOPopoverUtils *)sharedInstance;

- (void)setTopmostWindow:(NSWindow *)topmostWindow;
- (void)setTopmostView:(NSView *)topmostView;
- (void)setAppMainWindowResized:(BOOL)appMainWindowResized;

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (void)calculateTransitionFrame:(NSRect *)transitionFrame fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (BOOL)didTheTreeOfView:(NSView *)view containPosition:(NSPoint)position;
- (BOOL)didView:(NSView *)parent contain:(NSView *)child;
- (BOOL)didViews:(NSArray *)views contain:(NSView *)view;
- (BOOL)didWindow:(NSWindow *)parent contain:(NSWindow *)child;
- (BOOL)didWindows:(NSArray *)windows contain:(NSWindow *)window;
- (NSVisualEffectView *)contentViewDidContainVisualEffect;
- (void)addView:(NSView *)view toParent:(NSView *)parentView;
- (void)setupAutoresizingMaskIfNeeded:(BOOL)needed;

#pragma mark - Display utilities

- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType;
- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition;
- (NSRect)popoverRectForEdge:(NSRectEdge)popoverEdge;
- (NSRect)popoverRect;
- (NSRect)_popoverRectForEdge:(NSRectEdge *)popoverEdge;
- (NSRect)_popoverRect;
- (void)_backgroundViewShouldUpdate:(BOOL)updated;

@end
