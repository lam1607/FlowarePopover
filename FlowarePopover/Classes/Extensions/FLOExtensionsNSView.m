//
//  FLOExtensionsNSView.m
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "FLOExtensionsNSView.h"

#import "FLOExtensionsCABasicAnimation.h"
#import "FLOExtensionsCAKeyframeAnimation.h"
#import "FLOExtensionsGraphicsContext.h"

#import "FLOPopoverConstants.h"

typedef NS_ENUM(NSInteger, AXIS_XY) {
    axis_x = 1,
    axis_y
};

@implementation NSView (FLOExtensionsNSView)

- (NSImage *)imageRepresentationOffscreen:(NSRect)screenBounds {
    // Grab the image representation of the window, without the shadows.
    CGImageRef windowImageRef;
    windowImageRef = CGWindowListCreateImage(screenBounds, kCGWindowListOptionIncludingWindow, (CGWindowID)self.window.windowNumber, kCGWindowImageBoundsIgnoreFraming);
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(windowImageRef);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(windowImageRef), CGImageGetHeight(windowImageRef));
    
    CGContextRef ctx = FLOExtensionsGraphicsContextCreate(screenBounds.size, colorSpace);
    
    // Draw the window image into the newly-created context.
    CGContextDrawImage(ctx, (CGRect){ .size = imageSize }, windowImageRef);
    
    CGImageRef copiedWindowImageRef = CGBitmapContextCreateImage(ctx);
    NSImage *image = [[NSImage alloc] initWithCGImage:copiedWindowImageRef
                                                 size:imageSize];
    
    CGContextRelease(ctx);
    CGImageRelease(windowImageRef);
    CGImageRelease(copiedWindowImageRef);
    
    return image;
}

- (CALayer *)layerFromVisibleContents {
    CALayer *newLayer = [CALayer layer];
    newLayer.contents = [self imageRepresentationOffscreen:NSZeroRect];
    return newLayer;
}

- (CALayer *)layerFromContents {
    CALayer *newLayer = [CALayer layer];
    newLayer.bounds = self.bounds;
    NSBitmapImageRep *bitmapRep;
    bitmapRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:bitmapRep];
    id layerContents = (id)bitmapRep.CGImage;;
    newLayer.contents = layerContents;
    return newLayer;
}

#pragma mark - Internals

- (CGRect)shadowRect {
    CGRect windowBounds = (CGRect){ .size = self.frame.size };
    CGRect rect = CGRectInset(windowBounds, -JNWAnimatableWindowShadowHorizontalOutset, 0);
    rect.size.height += JNWAnimatableWindowShadowTopOffset;
    
    return rect;
}

- (CGRect)convertWindowFrameToScreenFrame:(CGRect)windowFrame {
    return (CGRect) {
        .size = windowFrame.size,
        .origin.x = windowFrame.origin.x - self.window.screen.frame.origin.x,
        .origin.y = windowFrame.origin.y - self.window.screen.frame.origin.y
    };
}

#pragma mark - View animated

static const CGFloat JNWAnimatableWindowShadowOpacity = 0.58;
static const CGSize JNWAnimatableWindowShadowOffset = (CGSize){ 0, -30.0 };
static const CGFloat JNWAnimatableWindowShadowRadius = 19.0;
static const CGFloat JNWAnimatableWindowShadowHorizontalOutset = 7.0;
static const CGFloat JNWAnimatableWindowShadowTopOffset = 14.0;

static CALayer *subLayer;

- (void)resizeAnimationWithDuration:(NSTimeInterval)duration fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity {
    subLayer = [CALayer layer];
    subLayer.contentsScale = 1.2;
    
    CGColorRef shadowColor = CGColorCreateGenericRGB(0, 0, 0, JNWAnimatableWindowShadowOpacity);
    subLayer.shadowColor = shadowColor;
    subLayer.shadowOffset = JNWAnimatableWindowShadowOffset;
    subLayer.shadowRadius = JNWAnimatableWindowShadowRadius;
    subLayer.shadowOpacity = 1.0;
    CGColorRelease(shadowColor);
    
    CGPathRef shadowPath = CGPathCreateWithRect(self.shadowRect, NULL);
    subLayer.shadowPath = shadowPath;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animation.fromValue = (id)subLayer.shadowPath;
    animation.toValue = (__bridge id)(shadowPath);
    animation.duration = 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    subLayer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    
    subLayer.contentsGravity = kCAGravityResize;
    subLayer.opaque = YES;
    
    // ensure that the layer's contents are set before we get rid of the real window.
    subLayer.frame = [self convertWindowFrameToScreenFrame:fromFrame];
    
    [self.layer addSublayer:subLayer];
    
    NSImage *originalImg = [self imageRepresentationOffscreen:fromFrame];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    subLayer.contents = originalImg;
    [CATransaction commit];
    
    NSImage *finalImg = [self imageRepresentationOffscreen:toFrame];
    [NSAnimationContext beginGrouping];
    [CATransaction begin];
    [CATransaction setAnimationDuration:5];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [CATransaction setCompletionBlock:^{
        
        [subLayer removeFromSuperlayer];
        subLayer = nil;
    }];
    
    [subLayer addAnimation:animation forKey:@"shadowPath"];
    subLayer.contents = finalImg;
    subLayer.frame = toFrame;
    [CATransaction commit];
    [NSAnimationContext endGrouping];
}

- (void)transformAlongAxis:(NSInteger)axis scaleFactor:(CGFloat)scaleFactor startPoint:(CGFloat)startPoint endPoint:(CGFloat)endPoint onDuration:(CGFloat)duration {
    // ensure that the layer's contents are set before we get rid of the real window.
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction commit];
    
    CAAnimation  *animator;
    if(axis == axis_x) {
        animator = [CABasicAnimation transformAxisXAnimationWithDuration:duration forLayerBeginningOnTop:YES scaleFactor:1.0 fromTransX:startPoint toTransX:endPoint fromOpacity:0.0 toOpacity:1.0];
    } else if(axis == axis_y) {
        animator = [CABasicAnimation transformAxisYAnimationWithDuration:duration forLayerBeginningOnTop:YES scaleFactor:1.0 fromTransY:startPoint toTransY:endPoint fromOpacity:0.0 toOpacity:1.0];
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [CATransaction setCompletionBlock:^{
        self.alphaValue = 1.0;
        [self.layer removeAllAnimations];
    }];
    
    [self.layer addAnimation:animator forKey:@"axis-transform"];
    [CATransaction commit];
}

- (void)transitionAlongAxis:(NSInteger)axis startPoint:(NSPoint)startPoint endPoint:(NSPoint)endPoint onDuration:(CGFloat)duration {
    // ensure that the layer's contents are set before we get rid of the real window.
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction commit];
    
    CABasicAnimation* positionAnim;
    
    if (axis == axis_x) {
        positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnim.fromValue = [NSValue valueWithPoint:startPoint];
        positionAnim.toValue = [NSValue valueWithPoint:endPoint];
    } else if(axis == axis_y) {
        positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnim.fromValue = [NSValue valueWithPoint:startPoint];
        positionAnim.toValue = [NSValue valueWithPoint:endPoint];
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [CATransaction setCompletionBlock:^{
        [self.layer removeAllAnimations];
    }];
    
    [self.layer addAnimation:positionAnim forKey:@"axis-transform"];
    [CATransaction commit];
}

#pragma mark - Utilities

- (void)animatedDisplayWillBeginAtPoint:(NSPoint)beginPoint endedAtPoint:(NSPoint)endedPoint handler:(void(^)(void))handler {
    [self.layer removeAllAnimations];
    // along x-axis / this is
    CABasicAnimation *animationx = [CABasicAnimation animationWithKeyPath:nil];
    
    animationx.toValue = [NSValue valueWithPoint:endedPoint];
    animationx.fromValue = [NSValue valueWithPoint:beginPoint];
    
    CABasicAnimation *topOpacity = [CABasicAnimation animationWithKeyPath:nil];
    topOpacity.fromValue = @(0.0);
    topOpacity.toValue = @(1);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [CATransaction setCompletionBlock:^{
        if(handler != nil) {
            handler();
        }
    }];
    
    [self.layer addAnimation:animationx forKey:@"position.x"];
    [self.layer addAnimation:topOpacity forKey:@"opacity"];
    [CATransaction commit];
}

- (void)animatedCloseWillBeginAtPoint:(NSPoint)beginPoint endedAtPoint:(NSPoint)endedPoint handler:(void(^)(void))handler {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:nil];
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:nil];
    opacityAnim.fromValue = @(0.5);
    opacityAnim.toValue = @(0.0);
    
    animation.toValue = [NSValue valueWithPoint:endedPoint];
    animation.fromValue = [NSValue valueWithPoint:beginPoint];
    
    self.alphaValue = 0.0;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [CATransaction setCompletionBlock:^{
        self.alphaValue = 1.0;
        [self .layer removeAllAnimations];
        if(handler != nil) {
            handler();
        }
    }];
    [self.layer addAnimation:opacityAnim forKey:@"opacity"];
    [self.layer addAnimation:animation forKey:@"position.x"];
    [CATransaction commit];
}

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame {
    [self showingAnimated:showing fromFrame:fromFrame toFrame:toFrame source:nil];
}

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame source:(id)source {
    [self showingAnimated:showing fromFrame:fromFrame toFrame:toFrame duration:FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD source:source];
}

- (void)showingAnimated:(BOOL)showing fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame duration:(NSTimeInterval)duration source:(id)source {
    self.wantsLayer = YES;
    [self setFrame:fromFrame];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:showing ? 0.0 : 1.0];
    fadeAnimation.toValue = [NSNumber numberWithFloat:showing ? 1.0 : 0.0];
    fadeAnimation.duration = duration;
    
    NSString *fadeEffect = showing ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect;
    
    NSDictionary *effectAttr = [[NSDictionary alloc] initWithObjectsAndKeys: self, NSViewAnimationTargetKey,
                                [NSValue valueWithRect:fromFrame], NSViewAnimationStartFrameKey,
                                [NSValue valueWithRect:toFrame], NSViewAnimationEndFrameKey,
                                fadeEffect, NSViewAnimationEffectKey, nil];
    
    NSArray *effects = [[NSArray alloc] initWithObjects:effectAttr, nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:effects];
    
    animation.animationBlockingMode = NSAnimationBlocking;
    animation.animationCurve = NSAnimationEaseInOut;
    animation.frameRate = 0.0;
    animation.duration = duration;
    animation.delegate = source;
    
    [self.layer addAnimation:fadeAnimation forKey:@"FLOExtensionsNSView.opacity"];
    
    [animation startAnimation];
    
    // Change the actual data value in the layer to the final value.
    self.layer.opacity = showing ? 1.0 : 0.0;
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition {
    [self showingAnimated:showing fromPosition:fromPosition toPosition:toPosition completionHandler:nil];
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition completionHandler:(void(^)(void))complete {
    [self showingAnimated:showing fromPosition:fromPosition toPosition:toPosition duration:FLO_CONST_ANIMATION_TIME_INTERVAL_STANDARD completionHandler:complete];
}

- (void)showingAnimated:(BOOL)showing fromPosition:(NSPoint)fromPosition toPosition:(NSPoint)toPosition duration:(NSTimeInterval)duration completionHandler:(void(^)(void))complete {
    [[self animator] setFrameOrigin:fromPosition];
    [[self animator] setAlphaValue:showing ? 0.0 : 1.0];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [[self animator] setFrameOrigin:toPosition];
        
        if (complete != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:complete];
        }
    }];
    
    [[self animator] setFrameOrigin:toPosition];
    [[self animator] setAlphaValue:showing ? 1.0 : 0.0];
    [NSAnimationContext endGrouping];
}

@end
