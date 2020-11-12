//
//  FLOExtensionsNSView.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (FLOExtensionsNSView)

- (BOOL)containsView:(NSView *)child;
- (BOOL)containsPosition:(NSPoint)position;
- (NSVisualEffectView *)containsVisualEffect;

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)constraintAttribute;
- (void)removeAttribute:(NSLayoutAttribute)constraintAttribute;
- (void)setSizeConstraints:(NSRect)withFrame;
- (void)removeSizeConstraints;
- (void)removeConstraints;
- (void)addAutoResize:(BOOL)isAutoResize toParent:(NSView *)parentView;
- (void)addAutoResize:(BOOL)isAutoResize toParent:(NSView *)parentView contentInsets:(NSEdgeInsets)contentInsets;
- (void)addCenterAutoResize:(BOOL)isCenterAutoResize toParent:(NSView *)parentView;
- (void)updateConstraintsWithInsets:(NSEdgeInsets)contentInsets;
- (NSEdgeInsets)contentInsetsWithFrame:(NSRect)frame;

- (void)displayScaleTransitionWithFactor:(NSPoint)scaleFactor beginAtPoint:(NSPoint)beginPoint endAtPoint:(NSPoint)endedPoint duration:(NSTimeInterval)duration removedOnCompletion:(BOOL)isRemovedOnCompletion completion:(void(^)(void))complete;
- (void)closeScaleTransitionWithFactor:(NSPoint)scaleFactor beginAtPoint:(NSPoint)beginPoint endAtPoint:(NSPoint)endedPoint duration:(NSTimeInterval)duration removedOnCompletion:(BOOL)isRemovedOnCompletion completion:(void(^)(void))complete;

/// Class methods
///
+ (BOOL)views:(NSArray *)views contain:(NSView *)view;

@end
