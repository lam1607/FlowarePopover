//
//  FLOKeyframeAnimation.h
//  FlowarePopover
//
//  Created by Floware Team on 3/6/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface FLOKeyframeAnimation : CAKeyframeAnimation

@property (nonatomic, assign) CGFloat stiffness;

// Defaults to 30.
@property (nonatomic, assign) CGFloat damping;

// Defaults to 5.
@property (nonatomic, assign) CGFloat mass;

// Both must be non-nil.
@property (nonatomic, strong) id _Nullable fromValue;
@property (nonatomic, strong) id _Nullable toValue;

// Defaults to 0 if no from or to values have been set.
@property (nonatomic, assign, readonly) CFTimeInterval duration;

@end
