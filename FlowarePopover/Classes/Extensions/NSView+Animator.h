//
//  NSView+Animator.h
//  FlowarePopover
//
//  Created by Truong Quang Hung on 12/21/16.
//  Copyright © 2016 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, AXIS_XY) {
    axis_x              = 1,
    axis_y
};

@interface NSView (Animator)
- (CALayer *)layerFromContents;

#pragma mark transform animator
- (void)transformAlongAxis:(NSInteger)axis scaleFactor:(CGFloat)scaleFactor startPoint:(CGFloat)startPoint endPoint:(CGFloat)endPoint onDuration:(CGFloat)duration;
- (void)transitionAlongAxis:(NSInteger)axis startPoint:(NSPoint)startPoint endPoint:(NSPoint)endPoint onDuration:(CGFloat)duration;

#pragma mark utilities
- (void)animatedDisplayWillBeginAtPoint:(NSPoint)beginPoint endedAtPoint:(NSPoint)endedPoint handler:(void(^)(void))handler;
- (void)animatedCloseWillBeginAtPoint:(NSPoint)beginPoint endedAtPoint:(NSPoint)endedPoint handler:(void(^)(void))handler;

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame;
- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame source:(id)source;
- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame duration:(NSTimeInterval)duration source:(id)source;

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition;
- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition completionHandler:(void(^)(void))complete;
- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition duration:(NSTimeInterval)duration completionHandler:(void(^)(void))complete;

@end
