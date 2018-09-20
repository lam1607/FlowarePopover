//
//  CAAnimation+Extensions.m
//  FlowarePopover
//
//  Created by Truong Quang Hung on 12/21/16.
//  Copyright © 2016 Floware Inc. All rights reserved.
//

#import "CABasicAnimation+Extensions.h"

@implementation CABasicAnimation (Extensions)
+ (CAAnimation *)transformAxisXAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                          fromTransX:(CGFloat)fromTransX
                                            toTransX:(CGFloat)toTransX
                                         fromOpacity:(CGFloat)fromOpacity
                                           toOpacity:(CGFloat)toOpacity {
    
    // move X-axis
    CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    translationX.fromValue = @(fromTransX);
    translationX.toValue = @(toTransX);
    
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        
        shrinkAnimation.duration = aDuration;
        shrinkAnimation.autoreverses = NO;
    }
    
    CABasicAnimation *topOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    topOpacity.fromValue = @(fromOpacity);
    topOpacity.toValue = @(toOpacity);
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:translationX, shrinkAnimation, topOpacity, nil];
    
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

+ (CAAnimation *)transformAxisYAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                          fromTransY:(CGFloat)fromTransY
                                            toTransY:(CGFloat)toTransY
                                         fromOpacity:(CGFloat)fromOpacity
                                           toOpacity:(CGFloat)toOpacity {
    
    // move X-axis
    CABasicAnimation *translationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationY.fromValue = @(fromTransY);
    translationY.toValue = @(toTransY);
    
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        
        shrinkAnimation.duration = aDuration;
        shrinkAnimation.autoreverses = YES;
    }
    
    CABasicAnimation *topOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    topOpacity.fromValue = @(fromOpacity);
    topOpacity.toValue = @(toOpacity);
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:translationY, topOpacity, nil];
    
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    return animationGroup;
}

+ (CAAnimation *)resizeAnimationWithDuration:(NSTimeInterval)aDuration fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity {
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    
    return groupAnimation;
}

#pragma mark anim to disappear a view
+ (CAAnimation *)disappearAxisYAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor translationY:(CGFloat)transY {
    
    // move Y-axis
    CABasicAnimation *translationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationY.toValue = @(transY);
    
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        
        shrinkAnimation.duration = aDuration;
        shrinkAnimation.autoreverses = YES;
    }
    
    CABasicAnimation *topOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    topOpacity.fromValue = @1;
    topOpacity.toValue = @0;
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:shrinkAnimation,
                                 translationY, topOpacity, nil];
    
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

+ (CAAnimation *)disappearAxisXAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor translationX:(CGFloat)transX {
    
    // move X-axis
    CABasicAnimation *translationX = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    translationX.toValue = @(transX);
    
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        
        shrinkAnimation.duration = aDuration;
        shrinkAnimation.autoreverses = YES;
    }
    
    CABasicAnimation *topOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    topOpacity.fromValue = @1;
    topOpacity.toValue = @0;
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:shrinkAnimation,
                                 translationX, topOpacity, nil];
    
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

#pragma mark anim flip rotation
+ (CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor {
    
    // Rotating halfway (pi radians) around the Y axis
    // gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    
    CGFloat startValue = beginsOnTop ? 0.0f : M_PI;
    CGFloat endValue = beginsOnTop ? -M_PI : 0.0f;
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    CABasicAnimation *shrinkAnimation = nil;
    if ( scaleFactor != 1.0f ) {
        shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        shrinkAnimation.toValue = [NSNumber numberWithFloat:scaleFactor];
        shrinkAnimation.duration = aDuration * 0.5;
        shrinkAnimation.autoreverses = YES;
    }
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, nil];
    
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

#pragma mark rotate anim
+ (void)rotateAnimationForKey:(NSString *)animKey withDuration:(NSTimeInterval)aDuration forButton:(NSButton *)rotateBtn  {
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    ani.fromValue = [NSNumber numberWithFloat:0];
    ani.toValue = [NSNumber numberWithFloat:-M_PI*2];
    [rotateBtn.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    ani.duration = aDuration; // seconds
    ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    ani.repeatCount = HUGE_VAL;
    rotateBtn.layer.frame = rotateBtn.frame;
    [rotateBtn.layer addAnimation:ani forKey:animKey];
}

@end
