//
//  NSView+Extensions.h
//  FlowarePopover-Sample
//
//  Created by lam1607 on 12/15/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSView (Extensions)

- (void)changeEffectiveAppearance;

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

/// Class methods
///
+ (BOOL)views:(NSArray *)views contain:(NSView *)view;

@end

NS_ASSUME_NONNULL_END
