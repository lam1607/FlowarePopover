//
//  FLOPopoverClippingView.h
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A class which forcably draws `NSClearColor.clearColor` around a given path,
// effectively clipping any views to the path. You can think of it like a
// `maskLayer` on a `CALayer`.
@interface FLOPopoverClippingView : NSView

// The path which the view will clip to. The clippingPath will be retained and
// released automatically.
@property (nonatomic) CGPathRef clippingPath;

@property (nonatomic) CGColorRef pathColor;

- (void)setupArrowVisualEffectViewMaterial:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state;
- (void)setClippingPathColor:(CGColorRef)color;
- (void)drawClippingPath;
- (void)clearClippingPath;

@end
