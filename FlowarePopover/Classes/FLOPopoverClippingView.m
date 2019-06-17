//
//  FLOPopoverClippingView.m
//  FlowarePopover
//
//  Created by Lam Nguyen on 6/17/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "FLOPopoverClippingView.h"

static void CGPathCallback(void *info, const CGPathElement *element) {
    NSBezierPath *bezierPath = (__bridge NSBezierPath *)info;
    CGPoint *points = element->points;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            [bezierPath moveToPoint:points[0]];
            break;
        }
        case kCGPathElementAddLineToPoint: {
            [bezierPath lineToPoint:points[0]];
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: {
            NSPoint qp0 = bezierPath.currentPoint, qp1 = points[0], qp2 = points[1], cp1, cp2;
            CGFloat m = 0.67;
            cp1.x = (qp0.x + ((qp1.x - qp0.x) * m));
            cp1.y = (qp0.y + ((qp1.y - qp0.y) * m));
            cp2.x = (qp2.x + ((qp1.x - qp2.x) * m));
            cp2.y = (qp2.y + ((qp1.y - qp2.y) * m));
            [bezierPath curveToPoint:qp2 controlPoint1:cp1 controlPoint2:cp2];
            break;
        }
        case kCGPathElementAddCurveToPoint: {
            [bezierPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
            break;
        }
        case kCGPathElementCloseSubpath: {
            [bezierPath closePath];
            break;
        }
    }
}

static NSBezierPath *bezierPathWithCGPath(CGPathRef cgPath) {
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    CGPathApply(cgPath, (__bridge void *)bezierPath, CGPathCallback);
    
    return bezierPath;
}

@interface FLOPopoverClippingView () {
    NSVisualEffectView *_visualEffectView;
}

@end

@implementation FLOPopoverClippingView

- (void)dealloc {
    [self clearClippingPath];
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return nil;
}

- (void)setClippingPath:(CGPathRef)clippingPath {
    if (clippingPath == _clippingPath) return;
    
    CGPathRelease(_clippingPath);
    _clippingPath = clippingPath;
    CGPathRetain(_clippingPath);
    
    @try {
        self.needsDisplay = YES;
    } @catch (NSException *exception) {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    if (self.clippingPath == NULL) return;
    
    [self drawClippingPath];
}

- (void)setupArrowVisualEffectViewMaterial:(NSVisualEffectMaterial)material blendingMode:(NSVisualEffectBlendingMode)blendingMode state:(NSVisualEffectState)state {
    if (_visualEffectView == nil) {
        _visualEffectView = [[NSVisualEffectView alloc] initWithFrame:self.frame];
        _visualEffectView.state = state;
        _visualEffectView.material = material;
        _visualEffectView.blendingMode = blendingMode;
        
        [self addSubview:_visualEffectView];
    }
}

- (void)setClippingPathColor:(CGColorRef)color {
    if (color != nil) {
        self.pathColor = color;
        
        @try {
            self.needsDisplay = YES;
        } @catch (NSException *exception) {
            NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
        }
    }
}

- (void)drawClippingPath {
    @try {
        if (_visualEffectView != nil) {
            [_visualEffectView setFrameSize:self.frame.size];
            
            _visualEffectView.maskImage = [NSImage imageWithSize:self.frame.size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
                NSBezierPath *path = bezierPathWithCGPath(self.clippingPath);
                [path fill];
                
                return YES;
            }];
        } else {
            CGContextRef currentContext = NSGraphicsContext.currentContext.CGContext;
            
            if (currentContext != nil) {
                self.pathColor = ((self.pathColor != nil) && (self.pathColor != [NSColor.clearColor CGColor])) ? self.pathColor : [NSColor.lightGrayColor CGColor];
                
                CGContextAddPath(currentContext, self.clippingPath);
                CGContextSetFillColorWithColor(currentContext, self.pathColor);
                CGContextFillPath(currentContext);
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%s-[%d] exception - reason = %@, [NSThread callStackSymbols] = %@", __PRETTY_FUNCTION__, __LINE__, exception.reason, [NSThread callStackSymbols]);
    }
}

- (void)clearClippingPath {
    self.clippingPath = NULL;
}

@end
