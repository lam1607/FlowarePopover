//
//  FLOExtensionsCABasicAnimation.h
//  FlowarePopover
//
//  Created by lamnguyen on 9/20/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface CABasicAnimation (FLOExtensionsCABasicAnimation)

#pragma mark -
#pragma mark - Transformation animation
#pragma mark -
+ (CAAnimation *)transformAxisXAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                          fromTransX:(CGFloat)fromTransX
                                            toTransX:(CGFloat)toTransX
                                         fromOpacity:(CGFloat)fromOpacity
                                           toOpacity:(CGFloat)toOpacity;
+ (CAAnimation *)transformAxisYAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                          fromTransY:(CGFloat)fromTransY
                                            toTransY:(CGFloat)toTransY
                                         fromOpacity:(CGFloat)fromOpacity
                                           toOpacity:(CGFloat)toOpacity;
+ (CAAnimation *)resizeAnimationWithDuration:(NSTimeInterval)aDuration fromFrame:(NSRect)fromFrame toFrame:(NSRect)toFrame fromOpacity:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity;

#pragma mark -
#pragma mark - Animation to disappear a view
#pragma mark -
+ (CAAnimation *)disappearAxisXAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                        translationX:(CGFloat)transX;
+ (CAAnimation *)disappearAxisYAnimationWithDuration:(NSTimeInterval)aDuration
                              forLayerBeginningOnTop:(BOOL)beginsOnTop
                                         scaleFactor:(CGFloat)scaleFactor
                                        translationY:(CGFloat)transY;

#pragma mark -
#pragma mark - Flip Rotation animation
#pragma mark -
+ (CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)duration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor;

#pragma mark -
#pragma mark - Rotation animation
#pragma mark -
+ (void)rotateAnimationForKey:(NSString *)animKey withDuration:(NSTimeInterval)aDuration forButton:(NSButton *)rotateBtn;

@end
