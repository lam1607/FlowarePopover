//
//  FLOPopoverUtils.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/10/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLOPopoverConstants.h"

@protocol FLOPopoverProtocols;
@class FLOPopoverView;

@interface FLOPopoverUtils : NSObject

#pragma mark - Properties

@property (nonatomic, weak) id<FLOPopoverProtocols> popover;

@property (nonatomic, strong, readonly) NSWindow *mainWindow;

@property (nonatomic, strong, readonly) NSWindow *topWindow;
@property (nonatomic, strong, readonly) NSView *topView;

@property (nonatomic, assign, readonly) BOOL mainWindowResized;

@property (nonatomic, strong) NSView *contentView;
@property (nonatomic, strong) NSViewController *contentViewController;

@property (nonatomic, assign) BOOL userInteractionEnable;

/**
 * The target window that the popover will be added on.
 */
@property (nonatomic, strong) NSWindow *presentedWindow;
@property (nonatomic, assign) FLOPopoverStyle popoverStyle;

@property (nonatomic, assign) BOOL popoverMoved;

@property (nonatomic, assign) BOOL shouldShowArrowWithVisualEffect;
@property (nonatomic, assign) NSVisualEffectMaterial arrowVisualEffectMaterial;
@property (nonatomic, assign) NSVisualEffectBlendingMode arrowVisualEffectBlendingMode;
@property (nonatomic, assign) NSVisualEffectState arrowVisualEffectState;

@property (nonatomic, assign) BOOL staysInApplicationFrame;

@property (nonatomic, assign) FLOPopoverAnimationBehaviour animationBehaviour;
@property (nonatomic, assign) FLOPopoverAnimationType animationType;
@property (nonatomic, assign) BOOL animatedInAppFrame;

@property (nonatomic, assign) BOOL needAutoresizingMask;

@property (nonatomic, strong) NSView *positioningAnchorView;
@property (nonatomic, strong) NSView *senderView;
@property (nonatomic, assign) FLOPopoverRelativePositionType relativePositionType;
@property (nonatomic, assign) NSRect positioningWindowFrame;
@property (nonatomic, strong) NSMutableArray<NSView *> *anchorSuperviews;

@property (nonatomic, strong) FLOPopoverView *backgroundView;
@property (nonatomic, assign) NSRect positioningFrame;
@property (nonatomic, strong) NSView *positioningView;
@property (nonatomic, assign) NSRectEdge preferredEdge;
@property (nonatomic, assign) NSRectEdge originalEdge;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGPoint anchorPoint;
@property (nonatomic, assign) CGSize originalViewSize;
@property (nonatomic, assign) CGFloat verticalMarginOutOfPopover;
@property (nonatomic, assign) BOOL observerViewBoundsDidChange;


+ (FLOPopoverUtils *)sharedInstance;
- (instancetype)initWithPopover:(id<FLOPopoverProtocols>)popover;

- (void)setTopmostWindow:(NSWindow *)topmostWindow;
- (void)setTopmostView:(NSView *)topmostView;
- (void)setMainWindowResized:(BOOL)mainWindowResized;

#pragma mark - Utilities

- (void)calculateFromFrame:(NSRect *)fromFrame toFrame:(NSRect *)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (void)calculateTransitionFrame:(NSRect *)transitionFrame fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame animationType:(FLOPopoverAnimationType)animationType forwarding:(BOOL)forwarding showing:(BOOL)showing;
- (BOOL)treeOfView:(NSView *)view containsPosition:(NSPoint)position;
- (BOOL)view:(NSView *)parent contains:(NSView *)child;
- (BOOL)views:(NSArray *)views contain:(NSView *)view;
- (BOOL)window:(NSWindow *)parent contains:(NSWindow *)child;
- (BOOL)windows:(NSArray *)windows contain:(NSWindow *)window;
- (NSVisualEffectView *)contentViewDidContainVisualEffect;
- (void)addView:(NSView *)view toParent:(NSView *)parentView;
- (void)addView:(NSView *)view toParent:(NSView *)parentView autoresizingMask:(BOOL)isAutoresizingMask;
- (void)addView:(NSView *)view toParent:(NSView *)parentView centerAutoresizingMask:(BOOL)isCenterAutoresizingMask;
- (void)setupAutoresizingMaskIfNeeded:(BOOL)needed;
- (void)resetObserverViewBoundsDidChange;

- (void)addSuperviewObserversForView:(NSView *)view selector:(SEL)selector source:(id)source;
- (BOOL)popoverShouldCloseByCheckingView:(NSView *)changedView;
- (void)handleObserverViewBoundsDidChange:(NSNotification *)notification popoverShowing:(BOOL)popoverShowing popoverClosing:(BOOL)popoverClosing;
- (void)handleObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context popoverShowing:(BOOL)popoverShowing popoverClosing:(BOOL)popoverClosing;
- (NSRect)popoverFrameWithResizingWindow:(NSWindow *)resizedWindow;
- (void)handleObserverWindowDidResize:(NSNotification *)notification popoverShowing:(BOOL)popoverShowing popoverClosing:(BOOL)popoverClosing;
- (void)updatePopoverContentSizeWhenWindowResizing;

#pragma mark - Display utilities

- (void)setUserInteractionEnable:(BOOL)isEnable;
- (void)setPopoverEdgeType:(FLOPopoverEdgeType)edgeType;
- (void)setupPositioningAnchorWithView:(NSView *)positioningView positioningRect:(NSRect)positioningRect shouldUpdatePosition:(BOOL)shouldUpdatePosition;
- (NSRect)popoverFrameForEdge:(NSRectEdge)popoverEdge;
- (NSRect)popoverFrame;
- (NSRect)p_popoverFrameForEdge:(NSRectEdge *)popoverEdge;
- (NSRect)p_popoverFrame;
- (void)p_backgroundViewShouldUpdate:(BOOL)updated;

@end
