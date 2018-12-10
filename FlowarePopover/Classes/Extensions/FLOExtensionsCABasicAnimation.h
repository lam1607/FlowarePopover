//
//  FLOExtensionsCABasicAnimation.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CABasicAnimation (FLOExtensionsCABasicAnimation)

#pragma mark - Transformation animation

+ (CAAnimation *)transformAxisXAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor
                                          fromTransX:(CGFloat)fromTransX toTransX:(CGFloat)toTransX
                                         fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity;
+ (CAAnimation *)transformAxisYAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor
                                          fromTransY:(CGFloat)fromTransY toTransY:(CGFloat)toTransY
                                         fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity;
+ (CAAnimation *)resizeAnimationWithDuration:(NSTimeInterval)aDuration fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame
                                 fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity;

#pragma mark - Animation to disappear a view

+ (CAAnimation *)disappearAxisXAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor
                                        translationX:(CGFloat)transX;
+ (CAAnimation *)disappearAxisYAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor
                                        translationY:(CGFloat)transY;

#pragma mark - Flip Rotation animation

+ (CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)duration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor;


#pragma mark - Rotation animation

+ (void)rotateAnimationForKey:(NSString *)animKey withDuration:(NSTimeInterval)aDuration forButton:(NSButton *)rotateBtn;

@end
